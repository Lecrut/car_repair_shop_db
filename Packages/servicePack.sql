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
END ServicePackage;


CREATE OR REPLACE PACKAGE BODY ServicePackage AS

    PROCEDURE PrintServiceDataByDate (service_date DATE) IS
        cnt NUMBER;
    Begin
        SELECT COUNT(*) INTO cnt FROM SERVICETABLE WHERE hour >= service_date AND hour < service_date + 1;
        IF cnt = 0 THEN
            dbms_output.put_line('Brak usług dla daty ' || service_date);
        ELSE
            FOR r IN (SELECT ServiceID, tasks, deref(employee), deref(owner), deref(car), position, hour FROM SERVICETABLE WHERE hour >= service_date AND hour < service_date + 1) LOOP
              dbms_output.put_line('ServiceID: ' || r.ServiceID);
              dbms_output.put_line('Tasks: ' || r.tasks.COUNT);
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
        v_count NUMBER;
        invalid_data_exception EXCEPTION;
    BEGIN
        IF service_date < SYSDATE THEN
            RAISE invalid_data_exception;
        END IF;

        select opening_hour into start_hour from WORKSHOPTABLE;
        select CLOSING_HOUR into  end_hour from WORKSHOPTABLE;
        SELECT NUMBER_OF_STATIONS INTO v_positions FROM WORKSHOPTABLE;
        v_hour := service_date + start_hour/24;
        WHILE v_hour < service_date + end_hour/24 LOOP
            dbms_output.put_line('Godzina: '  || TO_CHAR(v_hour, 'HH24:MI'));
            FOR i IN 1..v_positions LOOP
                SELECT COUNT(*) INTO v_count FROM SERVICETABLE WHERE hour = v_hour AND position = i;
                IF v_count = 0 THEN
                  dbms_output.put_line('Wolne stanowisko: ' || i);
                END IF;
            END LOOP;
            v_hour := v_hour + 1/24;
        END LOOP;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Niepoprawna data.');
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
    BEGIN
        IF service_date < SYSDATE THEN
            RAISE invalid_data_exception;
        END IF;

        select opening_hour into start_hour from WORKSHOPTABLE;
        select CLOSING_HOUR into  end_hour from WORKSHOPTABLE;



--         todo: walidacja
        car_ref := CARPACKAGE.GETCARREFBYVIN(car_vin);
        employee_ref := EMPLOYEESPACKAGE.GETEMPLOYEEREFBYID(employee_id);
        owner_ref := OWNERPACKAGE.GETOWNERREFBYPHONE(owner_phone);
        tasks_list := TASKSPACKAGE.CREATETASKSARRAY(tasks_ids);

        select SERVICE_SEQUENCE.nextval into next_id from dual;
        insert into SERVICETABLE VALUES (SERVICE_TYPE(next_id, tasks_list, employee_ref, owner_ref, car_ref, position_number, service_date));
        COMMIT;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Niepoprawna data.');
    END AddService;

END ServicePackage;

