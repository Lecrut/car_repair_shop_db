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


CREATE OR REPLACE PACKAGE BODY EmployeesPackage AS

    PROCEDURE ShowEmployeesList IS
        employee_count NUMBER;
    BEGIN
        SELECT COUNT (*) INTO employee_count FROM EmployeesTable;

        IF employee_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Brak pracowników.');
        ELSE
            FOR r IN (SELECT EmployeeID, First_name, Last_name, Salary, Professional_degree, Employment_date FROM EmployeesTable) LOOP
                DBMS_OUTPUT.PUT_LINE('EmployeeID: ' || r.EmployeeID);
                DBMS_OUTPUT.PUT_LINE('First_name: ' || r.First_name);
                DBMS_OUTPUT.PUT_LINE('Last_name: ' || r.Last_name);
                DBMS_OUTPUT.PUT_LINE('Salary: ' || r.Salary);
                DBMS_OUTPUT.PUT_LINE('Professional_degree: ' || r.Professional_degree);
                DBMS_OUTPUT.PUT_LINE('Employment_date: ' || r.Employment_date);
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

commit;