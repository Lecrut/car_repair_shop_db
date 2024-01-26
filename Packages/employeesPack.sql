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

-- TODO: poprawic AddEmployee
    PROCEDURE AddEmployee(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_professional_degree VARCHAR2,
        p_employment_date DATE
    ) IS
        v_employee Employee_type;
    BEGIN
        v_employee := Employee_type(
            p_first_name,
            p_last_name,
            p_salary,
            p_professional_degree,
            p_employment_date
        );

        IF v_employee.Employment_date > SYSDATE OR v_employee.Salary < 0 THEN
            DBMS_OUTPUT.PUT_LINE('Niepoprawne dane pracownika.');
        ELSE
            INSERT INTO EmployeesTable VALUES v_employee;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Dodano pracownika ' || p_first_name || ' ' || p_last_name || ' pod id ' || v_employee.EmployeeID || '.');
        END IF;
    END AddEmployee;

END EmployeesPackage;

    commit