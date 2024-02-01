CREATE OR REPLACE PACKAGE ServicePackage AS
    PROCEDURE PrintServiceDataByDate(service_date DATE);
    PROCEDURE PrintFreeHours(service_date DATE);
    PROCEDURE PrintClientHistory(phoneNumber VARCHAR2);
    PROCEDURE AddService(
        car_vin VARCHAR2,
        employee_id NUMBER,
        owner_phone VARCHAR2,
        service_date DATE,
        tasks_ids SYS.ODCINUMBERLIST,
        position_number NUMBER
    );
    PROCEDURE AddServiceForNearestDate(
        car_vin VARCHAR2,
        employee_id NUMBER,
        owner_phone VARCHAR2,
        tasks_ids SYS.ODCINUMBERLIST
    );
    FUNCTION IsTimeAllowed(position_number NUMBER, v_hour DATE) RETURN BOOLEAN;
    FUNCTION FindPositionAndDate(
        from_date Date,
        days_range NUMBER,
        tasks TasksArray_type,
        stations_count NUMBER,
        starting_hour NUMBER,
        closing_hour NUMBER,
        needed_time NUMBER,
        employee_ref REF EMPLOYEE_TYPE,
        owner_ref REF OWNER_TYPE,
        car_ref REF CAR_TYPE
    )
        RETURN SERVICE_TYPE;
    FUNCTION calculateTimeOfTasksInHours(tasks TASKSARRAY_TYPE) RETURN NUMBER;
END ServicePackage;


CREATE OR REPLACE PACKAGE BODY ServicePackage AS

    FUNCTION calculateTimeOfTasksInHours(tasks TASKSARRAY_TYPE) RETURN NUMBER IS
        v_result NUMBER := 0;
        v_task   TASK_TYPE;
    BEGIN
        FOR i IN 1..tasks.COUNT
            LOOP
                v_task := tasks(i);
                v_result := v_result + v_task.TIME_IN_HOURS;
            END LOOP;

        RETURN v_result;
    END calculateTimeOfTasksInHours;

    PROCEDURE AddServiceForNearestDate(
        car_vin VARCHAR2,
        employee_id NUMBER,
        owner_phone VARCHAR2,
        tasks_ids SYS.ODCINUMBERLIST
    ) IS
        start_hour   NUMBER;
        end_hour     NUMBER;
        stations     NUMBER;
        car_ref      REF CAR_TYPE;
        employee_ref REF EMPLOYEE_TYPE;
        owner_ref    REF OWNER_TYPE;
        tasks_list   TASKSARRAY_TYPE;
        new_service  SERVICE_TYPE;
    BEGIN
        select opening_hour into start_hour from WORKSHOPTABLE;
        select closing_hour into end_hour from WORKSHOPTABLE;
        select number_of_stations into stations from WORKSHOPTABLE;

        car_ref := CARPACKAGE.GETCARREFBYVIN(car_vin);
        employee_ref := EMPLOYEESPACKAGE.GETEMPLOYEEREFBYID(employee_id);
        owner_ref := OWNERPACKAGE.GETOWNERREFBYPHONE(owner_phone);
        tasks_list := TASKSPACKAGE.CREATETASKSARRAY(tasks_ids);

        new_service := FindPositionAndDate(SYSDATE, 5, tasks_list, stations, start_hour,
                                           end_hour, calculateTimeOfTasksInHours(tasks_list), employee_ref, owner_ref,
                                           car_ref);

        DBMS_OUTPUT.PUT_LINE('Founded available service date: station ' || new_service.POSITION || ' ,start hour: ' ||
                             to_char(new_service.HOUR, 'YYYY-MM-DD HH24') ||
                             ', end hour: ' || to_char(new_service.ENDTIME, 'YYYY-MM-DD HH24'));
        insert into SERVICETABLE VALUES (new_service);

    END AddServiceForNearestDate;

    FUNCTION FindPositionAndDate(
        from_date Date,
        days_range NUMBER,
        tasks TasksArray_type,
        stations_count NUMBER,
        starting_hour NUMBER,
        closing_hour NUMBER,
        needed_time NUMBER,
        employee_ref REF EMPLOYEE_TYPE,
        owner_ref REF OWNER_TYPE,
        car_ref REF CAR_TYPE
    )
        RETURN SERVICE_TYPE IS

        current_hour      DATE;
        closing_hour_date DATE;
        current_date      DATE := from_date;
        hour_counter      NUMBER;
    Begin

        FOR day IN 1..days_range
            LOOP
                FOR station in 1..stations_count
                    LOOP
                        --                     TODO zmienic inicjalizacje
                        current_hour := trunc(current_date) + starting_hour / 24;
                        closing_hour_date := trunc(current_date) + closing_hour / 24;

                        hour_counter := 0;
                        WHILE current_hour < closing_hour_date
                            LOOP
                                EXIT WHEN current_hour >= closing_hour_date;

                                IF NOT IsTimeAllowed(station, current_hour) THEN
                                    hour_counter := 0;
                                    current_hour := current_hour + 1 / 24;
                                    continue;
                                end if;

                                hour_counter := hour_counter + 1;
                                current_hour := current_hour + 1 / 24;

                                if hour_counter = ceil(needed_time) then
                                    return SERVICE_TYPE(SERVICE_SEQUENCE.nextval, tasks, employee_ref,
                                                        owner_ref, car_ref, station,
                                                        current_hour - hour_counter / 24, current_hour);
                                end if;
                            END LOOP;
                    END LOOP;
                current_date := current_date + 1;
            END LOOP;
        RAISE_APPLICATION_ERROR(-20002, 'No available date');
    end FindPositionAndDate;

    FUNCTION IsTimeAllowed(position_number NUMBER, v_hour DATE) RETURN BOOLEAN IS
        counter number;
    Begin
        SELECT COUNT(*)
        into counter
        FROM SERVICETABLE
        WHERE v_hour >= HOUR
          AND v_hour < ENDTIME
          and POSITION = position_number;
        IF counter > 0 then
            return false;
        end if;
        return true;
    end IsTimeAllowed;

    PROCEDURE PrintClientHistory(phoneNumber VARCHAR2) IS
        CURSOR service_cursor IS
            SELECT *
            FROM SERVICETABLE
            ORDER BY HOUR;
        service_record    service_cursor%ROWTYPE;
        service           SERVICE_TYPE;
        record_found      BOOLEAN;
        emp_ref           REF EMPLOYEE_TYPE;
        emp               EMPLOYEE_TYPE;
        car_ref           REF CAR_TYPE;
        car               CAR_TYPE;
        current_owner_ref REF OWNER_TYPE;
        current_owner     OWNER_TYPE;
        task              TASK_TYPE;
        task_str          VARCHAR(1000) := ' ';
        cost              NUMBER;
        owner             OWNER_TYPE    := OWNER_TYPE(NULL, NULL, NULL, NULL);

    BEGIN
        SELECT OWNERID, NAME, SURNAME, PHONE
        INTO owner.OWNERID, owner.NAME, owner.SURNAME, owner.PHONE
        FROM CLIENTTABLE
        WHERE phoneNumber = PHONE;

        OPEN service_cursor;
        dbms_output.put_line('History for owner: ' || owner.NAME || ' ' || owner.SURNAME ||
                             ', phone number: ' ||
                             owner.PHONE);

        LOOP
            FETCH service_cursor INTO service_record;
            EXIT WHEN service_cursor%NOTFOUND;

            current_owner_ref := service_record.OWNER;
            SELECT DEREF(current_owner_ref) INTO current_owner FROM dual;

            IF current_owner.PHONE <> phoneNumber THEN
                continue;
            END IF;

            record_found := TRUE;

            car_ref := service_record.CAR;
            SELECT DEREF(car_ref) INTO car FROM dual;

            emp_ref := service_record.EMPLOYEE;
            SELECT DEREF(emp_ref) INTO emp FROM dual;

            service := SERVICE_TYPE(service_record.ServiceID, service_record.tasks, service_record.employee,
                                    service_record.owner, service_record.car, service_record.position,
                                    service_record.hour, service_record.ENDTIME);

            cost := service.calculateCost();


            FOR i IN 1..service_record.tasks.COUNT
                LOOP
                    task := service_record.tasks(i);
                    task_str := task_str || ' | ' || task.NAME;
                END LOOP;


            dbms_output.put_line('----------------------');
            dbms_output.put_line('Date: ' || TO_CHAR(service_record.hour, 'DD-MM-YYYY HH24:MI'));
            dbms_output.put_line('Tasks:' || task_str || ' | ');
            dbms_output.put_line('Cost: ' || cost || ' PLN');
            dbms_output.put_line('Employee: ' || emp.First_name || ' ' || emp.Last_name || ', ' ||
                                 emp.Professional_degree);

            dbms_output.put_line('Car: ' || car.BRAND || ' ' || car.MODEL || ' ' ||
                                 car.YEAR_OF_PRODUCTION || ', mileage: ' || car.MILEAGE || ', vin: ' || car.VIN);

            dbms_output.put_line('----------------------');
        END LOOP;

        CLOSE service_cursor;

        IF NOT record_found THEN
            dbms_output.put_line('No history for this owner.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('No client with this phone number.');
    END PrintClientHistory;

    PROCEDURE PrintServiceDataByDate(service_date DATE) IS
        cursor service_cursor(pos number) is
            SELECT *
            FROM SERVICETABLE
            WHERE hour >= service_date
              AND hour < service_date + 1
              AND position = pos;
        service_record service_cursor%ROWTYPE;
        service        SERVICE_TYPE;
        record_found   BOOLEAN       := FALSE;
        emp_ref        REF EMPLOYEE_TYPE;
        emp            EMPLOYEE_TYPE;
        car_ref        REF CAR_TYPE;
        car            CAR_TYPE;
        owner_ref      REF OWNER_TYPE;
        owner          OWNER_TYPE;
        task           TASK_TYPE;
        task_str       VARCHAR(1000) := ' ';
        needed_time    NUMBER;
        cost           NUMBER;
        all_stations   NUMBER;
    BEGIN
        SELECT NUMBER_OF_STATIONS INTO all_stations FROM WORKSHOPTABLE;

        FOR i IN 1..all_stations
            LOOP
                DBMS_OUTPUT.PUT_LINE('-----------------------------' || 'Station ' || i ||
                                     '-----------------------------');

                OPEN service_cursor(i);

                LOOP
                    FETCH service_cursor INTO service_record;
                    EXIT WHEN service_cursor%NOTFOUND;

                    record_found := TRUE;

                    emp_ref := service_record.EMPLOYEE;
                    SELECT DEREF(emp_ref) INTO emp FROM dual;

                    car_ref := service_record.CAR;
                    SELECT DEREF(car_ref) INTO car FROM dual;

                    owner_ref := service_record.OWNER;
                    SELECT DEREF(owner_ref) INTO owner FROM dual;

                    service := SERVICE_TYPE(service_record.ServiceID, service_record.tasks, service_record.employee,
                                            service_record.owner, service_record.car, service_record.position,
                                            service_record.hour, service_record.ENDTIME);

                    needed_time := service.displayTimeInHours();
                    cost := service.calculateCost();


                    FOR i IN 1..service_record.tasks.COUNT
                        LOOP
                            task := service_record.tasks(i);
                            task_str := task_str || ' | ' || task.NAME;
                        END LOOP;

                    dbms_output.put_line('ServiceID: ' || service_record.ServiceID);
                    dbms_output.put_line('Tasks number: ' || service_record.tasks.COUNT);
                    dbms_output.put_line('Tasks:' || task_str || ' | ');
                    dbms_output.put_line('Cost: ' || cost || ' PLN');
                    dbms_output.put_line('Needed hours: ' || needed_time);

                    dbms_output.put_line('Employee: ' || emp.First_name || ' ' || emp.Last_name || ', ' ||
                                         emp.Professional_degree);

                    dbms_output.put_line('Car: ' || car.BRAND || ' ' || car.MODEL || ' ' ||
                                         car.YEAR_OF_PRODUCTION || ', mileage: ' || car.MILEAGE || ', vin: ' ||
                                         car.VIN);

                    dbms_output.put_line('Owner: ' || owner.NAME || ' ' || owner.SURNAME || ', phone number: ' ||
                                         owner.PHONE);

                    dbms_output.put_line('Station: ' || service_record.position);
                    dbms_output.put_line('Hour: ' || TO_CHAR(service_record.hour, 'HH24:MI'));
                    dbms_output.put_line('----------------------');
                END LOOP;

                CLOSE service_cursor;
            END LOOP;

        IF NOT record_found THEN
            dbms_output.put_line('No services for date ' || service_date);
        END IF;
    END PrintServiceDataByDate;


    PROCEDURE PrintFreeHours(service_date DATE) AS
        v_positions INT;
        v_hour      DATE;
        start_hour  NUMBER;
        end_hour    NUMBER;
        invalid_data_exception EXCEPTION;
        v_available_hours VARCHAR2(100);
    BEGIN
        IF service_date < SYSDATE THEN
            RAISE invalid_data_exception;
        END IF;

        select opening_hour into start_hour from WORKSHOPTABLE;
        select CLOSING_HOUR into end_hour from WORKSHOPTABLE;
        SELECT NUMBER_OF_STATIONS INTO v_positions FROM WORKSHOPTABLE;
        v_hour := service_date + start_hour / 24;
        FOR i IN 1..v_positions
            LOOP
                v_available_hours := 'Position ' || i || ' free hours: ';
                WHILE v_hour < service_date + end_hour / 24
                    LOOP
                        IF ISTIMEALLOWED(i, v_hour) THEN
                            v_available_hours := v_available_hours || TO_CHAR(v_hour, 'HH24') || ' ';
                        END IF;
                        v_hour := v_hour + 1 / 24;
                    END LOOP;
                dbms_output.put_line(v_available_hours);
                v_hour := service_date + start_hour / 24;
            END LOOP;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid date');
    END PrintFreeHours;

    PROCEDURE AddService(
        car_vin VARCHAR2,
        employee_id NUMBER,
        owner_phone VARCHAR2,
        service_date DATE,
        tasks_ids SYS.ODCINUMBERLIST,
        position_number NUMBER
    ) AS
        tasks_list   TASKSARRAY_TYPE;
        car_ref      REF CAR_TYPE;
        employee_ref REF EMPLOYEE_TYPE;
        owner_ref    REF OWNER_TYPE;
        next_id      NUMBER;
        start_hour   NUMBER;
        end_hour     NUMBER;
        invalid_data_exception EXCEPTION;
        service    SERVICE_TYPE;
        v_duration NUMBER;
        temp_date  DATE;
        invalid_time_exception EXCEPTION;
    BEGIN
        IF service_date < SYSDATE THEN
            RAISE invalid_data_exception;
        END IF;

        select opening_hour into start_hour from WORKSHOPTABLE;
        select CLOSING_HOUR into end_hour from WORKSHOPTABLE;

        car_ref := CARPACKAGE.GETCARREFBYVIN(car_vin);
        employee_ref := EMPLOYEESPACKAGE.GETEMPLOYEEREFBYID(employee_id);
        owner_ref := OWNERPACKAGE.GETOWNERREFBYPHONE(owner_phone);
        tasks_list := TASKSPACKAGE.CREATETASKSARRAY(tasks_ids);

        --         FindPositionAndDate(TO_DATE('2024-02-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, tasks_list, 2, start_hour,
--                             end_hour, 5.5);

        select SERVICE_SEQUENCE.nextval into next_id from dual;
        service := SERVICE_TYPE(next_id, tasks_list, employee_ref, owner_ref, car_ref, position_number, service_date,
                                service_date);

        IF TO_CHAR(service_date, 'HH24') < start_hour THEN
            RAISE invalid_data_exception;
        END IF;

        v_duration := CEIL(service.DISPLAYTIMEINHOURS());

        IF TO_CHAR(service_date, 'HH24') + v_duration > end_hour THEN
            RAISE invalid_data_exception;
        END IF;

        temp_date := service_date;
        WHILE temp_date < (service_date + (v_duration / 24))
            LOOP
                IF ISTIMEALLOWED(position_number, temp_date) = FALSE THEN
                    raise invalid_time_exception;
                end if;
                temp_date := temp_date + 1 / 24;
            end loop;

        service := SERVICE_TYPE(next_id, tasks_list, employee_ref, owner_ref, car_ref, position_number, service_date,
                                (service_date + (v_duration / 24)));
        insert into SERVICETABLE VALUES (service);
        COMMIT;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid repair date.');
        WHEN invalid_time_exception THEN
            raise_application_error(-20005, 'The position is already taken.');
    END AddService;

END ServicePackage;

