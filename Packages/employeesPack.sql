CREATE OR REPLACE TYPE EmployeesTable_type AS TABLE OF Employee_type;

CREATE OR REPLACE PACKAGE EmployeesPackage AS
    PROCEDURE ShowEmployeesList;
    PROCEDURE AddEmployee(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_professional_degree VARCHAR2,
        p_employment_date DATE
    );
END EmployeesPackage;


CREATE OR REPLACE PACKAGE BODY EmployeesPackage AS

    PROCEDURE ShowEmployeesList IS
        v_employees EmployeesTable_type;
    BEGIN
        SELECT Employee_type(EmployeeID, First_name, Last_name, Salary, Professional_degree, Employment_date)
        BULK COLLECT INTO v_employees
        FROM EmployeesTable;

        IF v_employees.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Brak pracowników.');
        ELSE
            FOR i IN 1..v_employees.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('EmployeeID: ' || v_employees(i).EmployeeID);
                DBMS_OUTPUT.PUT_LINE('First_name: ' || v_employees(i).First_name);
                DBMS_OUTPUT.PUT_LINE('Last_name: ' || v_employees(i).Last_name);
                DBMS_OUTPUT.PUT_LINE('Salary: ' || v_employees(i).Salary);
                DBMS_OUTPUT.PUT_LINE('Professional_degree: ' || v_employees(i).Professional_degree);
                DBMS_OUTPUT.PUT_LINE('Employment_date: ' || v_employees(i).Employment_date);
                DBMS_OUTPUT.PUT_LINE('---------------------');
            END LOOP;
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
            INSERT INTO EmployeesTable VALUES (Employee_type(next_id, p_first_name, p_last_name, p_salary, p_professional_degree, p_employment_date));
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Dodano pracownika ' || p_first_name || ' ' || p_last_name || ' pod id ' || next_id || '.');
        END IF;
    EXCEPTION
        WHEN invalid_data_exception THEN
            RAISE_APPLICATION_ERROR(-20002, 'Niepoprawne dane pracownika.');
    END AddEmployee;


END EmployeesPackage;

    commit