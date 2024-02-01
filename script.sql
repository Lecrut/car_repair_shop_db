CREATE SEQUENCE Car_sequence START WITH 1 INCREMENT BY 1;

CREATE or replace TYPE Car_type force AS OBJECT
(
    CarID               NUMBER,
    Brand               VARCHAR2(50),
    Model               VARCHAR2(50),
    Year_of_production  NUMBER,
    Registration_number VARCHAR2(15),
    Mileage             NUMBER,
    VIN                 VARCHAR2(20)
);

CREATE SEQUENCE Employee_sequence START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TYPE Employee_type AS OBJECT
(
    EmployeeID          NUMBER,
    First_name          VARCHAR2(100),
    Last_name           VARCHAR2(100),
    Salary              NUMBER,
    Professional_degree VARCHAR2(50),
    Employment_date     DATE,
    CONSTRUCTOR FUNCTION Employee_type RETURN SELF AS RESULT
) NOT FINAL;

CREATE OR REPLACE TYPE BODY Employee_type AS
    CONSTRUCTOR FUNCTION Employee_type RETURN SELF AS RESULT IS
    BEGIN
        SELF.EmployeeID := Employee_sequence.NEXTVAL;
        RETURN;
    END;
END;

CREATE or replace TYPE Owner_type force AS OBJECT
(
    OwnerID NUMBER,
    Name    VARCHAR2(100),
    Surname VARCHAR2(100),
    Phone   VARCHAR2(15)
);

CREATE or replace TYPE TasksArray_type force AS VARRAY(10) OF TASK_TYPE;

CREATE or replace TYPE Task_type force AS OBJECT
(
    TaskID        NUMBER,
    Name          Varchar2(100),
    Price         NUMBER,
    Time_in_hours NUMBER
);
/

CREATE or replace TYPE Workshop force AS OBJECT
(
    opening_hour       NUMBER,
    closing_hour       NUMBER,
    number_of_stations NUMBER
);
/

CREATE SEQUENCE SERVICE_SEQUENCE START WITH 1 INCREMENT BY 1;

CREATE or replace TYPE Service_type force AS OBJECT
(
    ServiceID NUMBER,
    tasks     TasksArray_type,
    employee  REF EMPLOYEE_TYPE,
    owner     REF OWNER_TYPE,
    car       REF CAR_TYPE,
    position  NUMBER,
    hour      DATE,
    endTime   DATE,

    MEMBER FUNCTION displayTimeInHours RETURN NUMBER,
    MEMBER FUNCTION calculateCost RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Service_type AS
    MEMBER FUNCTION displayTimeInHours RETURN NUMBER IS
        v_result Number := 0;
        v_task   TASK_TYPE;
    BEGIN
        FOR i IN 1..self.tasks.COUNT
            LOOP
                v_task := self.TASKS(i);
                v_result := v_result + v_task.TIME_IN_HOURS;
            END LOOP;

        RETURN v_result;
    END displayTimeInHours;

    MEMBER FUNCTION calculateCost RETURN NUMBER IS
        v_cost NUMBER := 0;
        v_task TASK_TYPE;
    BEGIN
        FOR i IN 1..self.tasks.COUNT
            LOOP
                v_task := self.TASKS(i);
                v_cost := v_cost + v_task.PRICE;
            END LOOP;

        RETURN v_cost;
    END calculateCost;
END;
/

CREATE TABLE WorkshopTable OF Workshop;
/

CREATE TABLE TasksTable OF Task_type
(
    PRIMARY KEY (TaskID)
);
/

CREATE TABLE EmployeesTable OF Employee_type
(
    PRIMARY KEY (EmployeeID)
);
/

CREATE TABLE ClientTable OF Owner_type
(
    PRIMARY KEY (OwnerID)
);
/

CREATE TABLE CarTable OF Car_type
(
    PRIMARY KEY (CarID)
);
/

CREATE TABLE ServiceTable OF Service_type
(
    PRIMARY KEY (ServiceID)
);
/

CREATE OR REPLACE TRIGGER check_vin
    BEFORE INSERT
    ON CARTABLE
    FOR EACH ROW
DECLARE
    car_exists EXCEPTION;
    vin_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO vin_exists FROM CarTable WHERE VIN = :NEW.VIN;
    IF vin_exists > 0 THEN
        RAISE car_exists;
    END IF;
EXCEPTION
    WHEN car_exists THEN
        RAISE_APPLICATION_ERROR(-20004, 'Current car is already in base.');
END;

CREATE OR REPLACE TRIGGER CheckServiceReservation
    BEFORE INSERT
    ON SERVICETABLE
    FOR EACH ROW
DECLARE
    car_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO car_count FROM SERVICETABLE WHERE Car = :NEW.Car AND TRUNC(HOUR) = TRUNC(:NEW.HOUR);
    IF car_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'This car already has a repair reserved on this day.');
    END IF;
END;
/

CREATE OR REPLACE PACKAGE CarPackage AS
    PROCEDURE ShowCars;
    PROCEDURE AddCar(
        p_Brand VARCHAR2,
        p_Model VARCHAR2,
        p_Year_of_production NUMBER,
        p_Registration_number VARCHAR2,
        p_Mileage NUMBER,
        p_VIN VARCHAR2
    );
    PROCEDURE EditMileageForCar(p_VIN VARCHAR2, p_Mileage NUMBER);
    FUNCTION GetCarRefByVin(vin_number IN VARCHAR2) RETURN REF CAR_TYPE;
END CarPackage;
/

CREATE OR REPLACE PACKAGE BODY CarPackage AS

    PROCEDURE ShowCars IS
        cars_count Number;
    begin
        select count(*) into cars_count from CARTABLE;

        if cars_count = 0 then
            DBMS_OUTPUT.PUT_LINE('No cars to show');
        else
            FOR r IN (SELECT CarID, Brand, Model, Year_of_production, Registration_number, Mileage, VIN FROM CARTABLE)
                LOOP
                    DBMS_OUTPUT.PUT_LINE('CarID: ' || r.CarID);
                    DBMS_OUTPUT.PUT_LINE('Brand: ' || r.Brand);
                    DBMS_OUTPUT.PUT_LINE('Model: ' || r.Model);
                    DBMS_OUTPUT.PUT_LINE('Year_of_production: ' || r.Year_of_production);
                    DBMS_OUTPUT.PUT_LINE('Registration_number: ' || r.Registration_number);
                    DBMS_OUTPUT.PUT_LINE('Mileage: ' || r.Mileage);
                    DBMS_OUTPUT.PUT_LINE('VIN: ' || r.VIN);
                    DBMS_OUTPUT.PUT_LINE('---------------------');
                END LOOP;
        end if;
    end ShowCars;

    PROCEDURE AddCar(
        p_Brand VARCHAR2,
        p_Model VARCHAR2,
        p_Year_of_production NUMBER,
        p_Registration_number VARCHAR2,
        p_Mileage NUMBER,
        p_VIN VARCHAR2
    ) IS
        next_id NUMBER;
    BEGIN
        next_id := CAR_SEQUENCE.NEXTVAL;
        INSERT INTO CarTable
        VALUES (Car_type(next_id, p_Brand, p_Model, p_Year_of_production, p_Registration_number, p_Mileage, p_VIN));
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Added car ' || p_Brand || ' ' || p_Model || ' on id: ' || next_id || '.');
    END AddCar;

    PROCEDURE EditMileageForCar(p_VIN VARCHAR2, p_Mileage NUMBER) IS
        v_old_mileage NUMBER;

        PROCEDURE CheckMileage(p_VIN VARCHAR2, p_NewMileage NUMBER) IS
        BEGIN
            SELECT Mileage
            INTO v_old_mileage
            FROM CarTable
            WHERE VIN = p_VIN;

            IF p_NewMileage < v_old_mileage THEN
                RAISE_APPLICATION_ERROR(-20001, 'New mileage cannot be less than the current mileage.');
            END IF;
        END CheckMileage;

    BEGIN
        CheckMileage(p_VIN, p_Mileage);

        UPDATE CarTable
        SET Mileage = p_Mileage
        WHERE VIN = p_VIN;

        DBMS_OUTPUT.PUT_LINE('Mileage for VIN ' || p_VIN || ' has been updated to: ' || p_Mileage);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Car with the specified VIN was not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
    END EditMileageForCar;

    FUNCTION GetCarRefByVin(vin_number IN VARCHAR2) RETURN REF CAR_TYPE AS
        car_ref REF CAR_TYPE;
    BEGIN
        SELECT REF(c) INTO car_ref FROM CARTABLE c WHERE c.VIN = vin_number;
        RETURN car_ref;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GetCarRefByVin;

end CarPackage;
/

CREATE OR REPLACE PACKAGE EmployeesPackage AS
    PROCEDURE ShowEmployeesList;
    PROCEDURE AddEmployee(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_professional_degree VARCHAR2,
        p_employment_date DATE
    );
    FUNCTION GetEmployeeRefById(employee_id IN NUMBER) RETURN REF EMPLOYEE_TYPE;
END EmployeesPackage;
/

CREATE OR REPLACE PACKAGE BODY EmployeesPackage AS

    PROCEDURE ShowEmployeesList IS
        employee_count      NUMBER;
        emp_cursor          SYS_REFCURSOR;
        EmployeeID          EmployeesTable.EmployeeID%TYPE;
        First_name          EmployeesTable.First_name%TYPE;
        Last_name           EmployeesTable.Last_name%TYPE;
        Salary              EmployeesTable.Salary%TYPE;
        Professional_degree EmployeesTable.Professional_degree%TYPE;
        Employment_date     EmployeesTable.Employment_date%TYPE;
    BEGIN
        SELECT COUNT(*) INTO employee_count FROM EmployeesTable;

        IF employee_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No employees founded.');
        ELSE
            OPEN emp_cursor FOR
                SELECT EmployeeID, First_name, Last_name, Salary, Professional_degree, Employment_date
                FROM EmployeesTable;

            LOOP
                FETCH emp_cursor INTO EmployeeID, First_name, Last_name, Salary, Professional_degree, Employment_date;
                EXIT WHEN emp_cursor%NOTFOUND;

                DBMS_OUTPUT.PUT_LINE('EmployeeID: ' || EmployeeID);
                DBMS_OUTPUT.PUT_LINE('First_name: ' || First_name);
                DBMS_OUTPUT.PUT_LINE('Last_name: ' || Last_name);
                DBMS_OUTPUT.PUT_LINE('Salary: ' || Salary);
                DBMS_OUTPUT.PUT_LINE('Professional_degree: ' || Professional_degree);
                DBMS_OUTPUT.PUT_LINE('Employment_date: ' || Employment_date);
                DBMS_OUTPUT.PUT_LINE('---------------------');
            END LOOP;

            CLOSE emp_cursor;
        END IF;
    END ShowEmployeesList;


    PROCEDURE AddEmployee(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_professional_degree VARCHAR2,
        p_employment_date DATE
    ) IS
        next_id NUMBER;
        invalid_data_exception EXCEPTION;
    BEGIN
        IF p_employment_date > SYSDATE OR p_salary < 0 THEN
            RAISE invalid_data_exception;
        ELSE
            SELECT Employee_sequence.NEXTVAL INTO next_id FROM dual;
            INSERT INTO EmployeesTable
            VALUES (Employee_type(next_id, p_first_name, p_last_name, p_salary, p_professional_degree,
                                  p_employment_date));
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Added employee ' || p_first_name || ' ' || p_last_name || ' with ID ' || next_id ||
                                 '.');
        END IF;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Incorrect employee data.');
    END AddEmployee;

    FUNCTION GetEmployeeRefById(employee_id IN NUMBER) RETURN REF EMPLOYEE_TYPE AS
        employee_ref REF EMPLOYEE_TYPE;
    BEGIN
        SELECT REF(e) INTO employee_ref FROM EMPLOYEESTABLE e WHERE e.EMPLOYEEID = employee_id;
        return employee_ref;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GetEmployeeRefById;

END EmployeesPackage;
/

CREATE OR REPLACE PACKAGE OwnerPackage AS
    PROCEDURE ShowAllOwners;
    PROCEDURE ShowOwnerByPhone(phone_number IN VARCHAR2);
    PROCEDURE AddOwner(
        p_name VARCHAR2,
        p_surname VARCHAR2,
        p_phone VARCHAR2
    );
    FUNCTION GetOwnerRefByPhone(phone_number IN VARCHAR2) RETURN REF OWNER_TYPE;
END OwnerPackage;
/

CREATE OR REPLACE PACKAGE BODY OwnerPackage AS
    PROCEDURE ShowAllOwners IS
        CURSOR c IS SELECT OwnerID, Name, Surname, Phone
                    FROM ClientTable;
        cnt NUMBER;
    Begin
        SELECT COUNT(*) INTO cnt FROM ClientTable;
        IF cnt = 0 THEN
            dbms_output.put_line('No clients founded');
        ELSE
            FOR r IN (SELECT DISTINCT OwnerID, Name, Surname, Phone FROM ClientTable)
                LOOP
                    dbms_output.put_line('OwnerID: ' || r.OwnerID || ', Name: ' || r.Name || ', Surname: ' ||
                                         r.Surname || ', Phone: ' || r.Phone);
                END LOOP;
        END IF;
    end ShowAllOwners;

    PROCEDURE ShowOwnerByPhone(phone_number IN VARCHAR2) AS
        cnt NUMBER;
    Begin
        SELECT COUNT(*) INTO cnt FROM ClientTable WHERE Phone = phone_number;
        IF cnt = 0 THEN
            dbms_output.put_line('No clients founded');
        ELSE
            FOR r IN (SELECT DISTINCT OwnerID, Name, Surname, Phone FROM ClientTable WHERE Phone = phone_number)
                LOOP
                    dbms_output.put_line('OwnerID: ' || r.OwnerID || ', Name: ' || r.Name || ', Surname: ' ||
                                         r.Surname || ', Phone: ' || r.Phone);
                END LOOP;
        END IF;
    END ShowOwnerByPhone;

    PROCEDURE AddOwner(
        p_name VARCHAR2,
        p_surname VARCHAR2,
        p_phone VARCHAR2
    ) IS
        next_id      NUMBER;
        phone_exists NUMBER;
        phone_exception EXCEPTION;
    Begin
        SELECT COUNT(*) INTO phone_exists FROM ClientTable WHERE phone = p_phone;
        IF phone_exists > 0 THEN
            RAISE phone_exception;
        END IF;
        SELECT COUNT(*) INTO next_id FROM ClientTable;
        next_id := next_id + 1;
        INSERT INTO CLIENTTABLE VALUES (OWNER_TYPE(next_id, p_name, p_surname, p_phone));
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Added new client ' || p_name || ' ' || p_surname || ' tel. ' || p_phone || ' with ID ' ||
                             next_id || '.');
    EXCEPTION
        WHEN phone_exception THEN
            RAISE_APPLICATION_ERROR(-20001, 'Client with this phone number already exists');
    end AddOwner;

    FUNCTION GetOwnerRefByPhone(phone_number IN VARCHAR2) RETURN REF OWNER_TYPE AS
        client_ref REF OWNER_TYPE;
    BEGIN
        SELECT REF(c) INTO client_ref FROM ClientTable c WHERE c.Phone = phone_number;
        RETURN client_ref;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GetOwnerRefByPhone;

END OwnerPackage;
/


CREATE OR REPLACE PACKAGE TasksPackage AS
    PROCEDURE ShowTasks;
    FUNCTION createTasksArray(p_ids SYS.ODCINUMBERLIST) RETURN TasksArray_type;
END TasksPackage;

CREATE OR REPLACE PACKAGE BODY TasksPackage AS

    PROCEDURE ShowTasks IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Available tasks');

        FOR r IN (SELECT TaskID, Name, Price, Time_in_hours FROM TASKSTABLE)
            LOOP
                DBMS_OUTPUT.PUT_LINE('TaskID: ' || r.TaskID);
                DBMS_OUTPUT.PUT_LINE('Name: ' || r.Name);
                DBMS_OUTPUT.PUT_LINE('Price: ' || r.Price);
                DBMS_OUTPUT.PUT_LINE('Time in hours: ' || r.Time_in_hours);
                DBMS_OUTPUT.PUT_LINE('---------------------');
            END LOOP;

    END ShowTasks;

    FUNCTION createTasksArray(p_ids SYS.ODCINUMBERLIST) RETURN TasksArray_type AS
        tasks      TasksArray_type := TasksArray_type();
        task       TASK_TYPE;
        task_id    NUMBER;
        task_name  VARCHAR2(100);
        task_price NUMBER;
        task_time  NUMBER;
    BEGIN
        tasks.EXTEND(p_ids.count);
        for i in 1 .. p_ids.count
            loop
                SELECT TASKID, NAME, PRICE, TIME_IN_HOURS
                INTO task_id, task_name, task_price, task_time
                FROM taskstable
                WHERE TASKID = p_ids(i);
                task := TASK_TYPE(task_id, task_name, task_price, task_time);
                tasks(i) := task;
            end loop;
        IF tasks.count = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
        RETURN tasks;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Task not found');
    END createTasksArray;

END TasksPackage;
/

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
/

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
/

INSERT INTO TasksTable
VALUES (Task_type(1, 'Oil Change', 150.0, 1.5));
/

INSERT INTO TasksTable
VALUES (Task_type(2, 'Engine Repair', 1200.0, 10.5));
/

INSERT INTO TasksTable
VALUES (Task_type(3, 'Tire Replacement', 200.0, 2.5));
/

INSERT INTO TasksTable
VALUES (Task_type(4, 'Brake Inspection', 100.0, 0.5));
/

INSERT INTO TasksTable
VALUES (Task_type(5, 'Battery Replacement', 180.0, 1.0));
/

INSERT INTO TasksTable
VALUES (Task_type(6, 'Air Filter Change', 80.0, 0.5));
/

INSERT INTO TasksTable
VALUES (Task_type(7, 'Coolant Flush', 120.0, 1.5));
/

INSERT INTO TasksTable
VALUES (Task_type(8, 'Transmission Flush', 300.0, 3.5));
/

INSERT INTO WORKSHOPTABLE
VALUES (Workshop(8, 18, 2));
/
