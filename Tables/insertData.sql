INSERT INTO TasksTable VALUES (Task_type(1, 'Oil Change', 150.0, 1.5));
INSERT INTO TasksTable VALUES (Task_type(2, 'Engine Repair', 1200.0, 10.5));
INSERT INTO TasksTable VALUES (Task_type(3, 'Tire Replacement', 200.0, 2.5));
INSERT INTO TasksTable VALUES (Task_type(4, 'Brake Inspection', 100.0, 0.5));
INSERT INTO TasksTable VALUES (Task_type(5, 'Battery Replacement', 180.0, 1.0));
INSERT INTO TasksTable VALUES (Task_type(6, 'Air Filter Change', 80.0, 0.5));
INSERT INTO TasksTable VALUES (Task_type(7, 'Coolant Flush', 120.0, 1.5));
INSERT INTO TasksTable VALUES (Task_type(8, 'Transmission Flush', 300.0, 3.5));
COMMIT;

select * from TasksTable



DECLARE
    v_first_name VARCHAR2(100) := 'Jan';
    v_last_name VARCHAR2(100) := 'Kowalski';
    v_salary NUMBER := 5000;
    v_professional_degree VARCHAR2(50) := 'Inżynier';
    v_employment_date DATE := TO_DATE('2022-01-01', 'YYYY-MM-DD');
BEGIN
    EmployeesPackage.AddEmployee(v_first_name, v_last_name, v_salary, v_professional_degree, v_employment_date);
END;

select * from EMPLOYEESTABLE;

DECLARE
    v_name VARCHAR2(100) := 'Jan';
    v_surname VARCHAR2(100) := 'Kowalski';
    v_phone VARCHAR2(15) := '123456789';
BEGIN
    OWNERPACKAGE.AddOwner(v_name, v_surname, v_phone);
END;

select * from CLIENTTABLE;

