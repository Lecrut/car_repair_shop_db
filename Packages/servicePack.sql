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
    FUNCTION IsTimeAllowed(position_number NUMBER, v_hour DATE) RETURN BOOLEAN;
END ServicePackage;


CREATE OR REPLACE PACKAGE BODY ServicePackage AS

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
                DBMS_OUTPUT.PUT_LINE('-----------------------------' || 'Station ' || i || '-----------------------------');

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

