CREATE OR REPLACE PACKAGE ServicePackage AS
    PROCEDURE PrintServiceDataByDate (service_date DATE);
    PROCEDURE PrintFreeHours (service_date DATE);
END ServicePackage;


CREATE OR REPLACE PACKAGE BODY ServicePackage AS

    PROCEDURE PrintServiceDataByDate (service_date DATE) IS
        cnt NUMBER;
    Begin
        SELECT COUNT(*) INTO cnt FROM SERVICETABLE WHERE hour >= service_date AND hour < service_date + 1;
        IF cnt = 0 THEN
            dbms_output.put_line('Brak usług dla daty ' || service_date);
        ELSE
            FOR r IN (SELECT ServiceID, tasks, employee, owner, car, position, hour FROM SERVICETABLE WHERE hour >= service_date AND hour < service_date + 1) LOOP
              dbms_output.put_line('ServiceID: ' || r.ServiceID);
              dbms_output.put_line('Tasks: ' || r.tasks.COUNT);
--               dbms_output.put_line('Employee: ' || r.employee);
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
    BEGIN
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
    END PrintFreeHours;

--
--     CREATE OR REPLACE PROCEDURE get_car_ref (p_car_id INT) AS
--         v_car REF CAR_TYPE;
--     BEGIN
--         SELECT REF(c) INTO v_car FROM CARTABLE c WHERE CarID = p_car_id;
--         dbms_output.put_line('Referencja do samochodu: ' || v_car);
--     END;

END ServicePackage;





-- -- Tworzę procedurę, która dodaje dane do tabeli serviceTable
-- CREATE OR REPLACE PROCEDURE add_service (
--     p_serviceid IN NUMBER,
--     p_tasks IN TasksArray_type,
--     p_employee IN EMPLOYEE_TYPE,
--     p_owner IN OWNER_TYPE,
--     p_car IN CAR_TYPE,
--     p_position IN NUMBER,
--     p_hour IN DATE
-- ) AS
-- BEGIN
--   -- Używam klauzuli VALUES, aby dodać dane do tabeli serviceTable
--   INSERT INTO serviceTable VALUES (
--     p_serviceid,
--     p_tasks,
--     (SELECT REF(e) FROM employeeTable e WHERE e.employeeID = p_employee.employeeID),
--     (SELECT REF(o) FROM ownerTable o WHERE o.ownerID = p_owner.ownerID),
--     (SELECT REF(c) FROM carTable c WHERE c.carID = p_car.carID),
--     p_position,
--     p_hour
--   );
-- END;
-- /
--
-- -- Wywołuję procedurę z przykładowymi danymi
-- DECLARE
--   v_tasks TasksArray_type := TasksArray_type('Oil change', 'Tire rotation', 'Brake inspection');
--   v_employee EMPLOYEE_TYPE := EMPLOYEE_TYPE(1, 'Jan', 'Kowalski', 'Mechanic');
--   v_owner OWNER_TYPE := OWNER_TYPE(2, 'Anna', 'Nowak', '123-456-789');
--   v_car CAR_TYPE := CAR_TYPE(3, 'Toyota', 'Corolla', 2010, 'ABC-123', 100000, '1234567890');
--   v_position NUMBER := 1;
--   v_hour DATE := SYSDATE;
-- BEGIN
--   add_service(v_serviceid, v_tasks, v_employee, v_owner, v_car, v_position, v_hour);
-- END;
-- /

