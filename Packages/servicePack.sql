CREATE OR REPLACE PACKAGE ServicePackage AS
    PROCEDURE PrintServiceDataByDate (service_date DATE);
    PROCEDURE PrintFreeHours (service_date DATE);
    PROCEDURE AddService(
        car_vin VARCHAR2,
        employee_id NUMBER,
        owner_phone VARCHAR2,
        service_date DATE,
        tasks_ids SYS.ODCINUMBERLIST,
        position_number NUMBER
    );
    FUNCTION IsTimeAllowed (position_number NUMBER, v_hour DATE) RETURN BOOLEAN;
END ServicePackage;


CREATE OR REPLACE PACKAGE BODY ServicePackage AS

    FUNCTION IsTimeAllowed (position_number NUMBER, v_hour DATE) RETURN BOOLEAN IS
        counter number;
    Begin
        SELECT COUNT(*) into counter FROM SERVICETABLE WHERE v_hour >= HOUR AND v_hour < ENDTIME and POSITION = position_number;
        IF counter > 0 then
            return false;
        end if;
        return true;
    end IsTimeAllowed;

    PROCEDURE PrintServiceDataByDate (service_date DATE) IS
        cnt NUMBER;
    Begin
        SELECT COUNT(*) INTO cnt FROM SERVICETABLE WHERE hour >= service_date AND hour < service_date + 1;
        IF cnt = 0 THEN
            dbms_output.put_line('No services for date ' || service_date);
        ELSE
            FOR r IN (SELECT ServiceID, tasks, deref(employee), deref(owner), deref(car), position, hour FROM SERVICETABLE WHERE hour >= service_date AND hour < service_date + 1) LOOP
              dbms_output.put_line('ServiceID: ' || r.ServiceID);
              dbms_output.put_line('Tasks number: ' || r.tasks.COUNT);
--               todo: usunąć referencję i to wypisac poprawnie
--               dbms_output.put_line('Employee: ' || r.emp.NAME);
--               dbms_output.put_line('Owner: ' || r.owner);
--               dbms_output.put_line('Car: ' || r.car);
              dbms_output.put_line('Position: ' || r.position);
              dbms_output.put_line('Hour: ' || r.hour);
              dbms_output.put_line('----------------------');
            END LOOP;
        END IF;
    end PrintServiceDataByDate;

    PROCEDURE PrintFreeHours (service_date DATE) AS
        v_positions INT;
        v_hour DATE;
        start_hour NUMBER;
        end_hour NUMBER;
        invalid_data_exception EXCEPTION;
        v_available_hours VARCHAR2(100);
    BEGIN
        IF service_date < SYSDATE THEN
            RAISE invalid_data_exception;
        END IF;

        select opening_hour into start_hour from WORKSHOPTABLE;
        select CLOSING_HOUR into  end_hour from WORKSHOPTABLE;
        SELECT NUMBER_OF_STATIONS INTO v_positions FROM WORKSHOPTABLE;
        v_hour := service_date + start_hour/24;
        FOR i IN 1..v_positions LOOP
            v_available_hours := 'Position ' || i || ' free hours: ';
            WHILE v_hour < service_date + end_hour/24 LOOP
                IF ISTIMEALLOWED(i, v_hour) THEN
                    v_available_hours := v_available_hours || TO_CHAR(v_hour, 'HH24') || ' ';
                END IF;
                v_hour := v_hour + 1/24;
            END LOOP;
            dbms_output.put_line(v_available_hours);
            v_hour := service_date + start_hour/24;
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
        tasks_list TASKSARRAY_TYPE;
        car_ref REF CAR_TYPE;
        employee_ref REF EMPLOYEE_TYPE;
        owner_ref REF OWNER_TYPE;
        next_id NUMBER;
        start_hour NUMBER;
        end_hour NUMBER;
        invalid_data_exception EXCEPTION;
        service SERVICE_TYPE;
        v_duration NUMBER;
        temp_date DATE;
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
        service := SERVICE_TYPE(next_id, tasks_list, employee_ref, owner_ref, car_ref, position_number, service_date, service_date);

        IF TO_CHAR(service_date, 'HH24') < start_hour THEN
            RAISE invalid_data_exception;
        END IF;

        v_duration := CEIL(service.DISPLAYTIMEINHOURS());

        IF TO_CHAR(service_date, 'HH24') + v_duration > end_hour THEN
            RAISE invalid_data_exception;
        END IF;

        temp_date := service_date;
        WHILE temp_date < (service_date+(v_duration/24)) LOOP
            IF ISTIMEALLOWED(position_number, temp_date) = FALSE THEN
                raise invalid_time_exception;
            end if;
            temp_date := temp_date + 1/24;
        end loop;

        service := SERVICE_TYPE(next_id, tasks_list, employee_ref, owner_ref, car_ref, position_number, service_date, (service_date+(v_duration/24)));
        insert into SERVICETABLE VALUES (service);
        COMMIT;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid repair date.');
        WHEN invalid_time_exception THEN
            raise_application_error(-20005, 'The position is already taken.');
    END AddService;

END ServicePackage;

