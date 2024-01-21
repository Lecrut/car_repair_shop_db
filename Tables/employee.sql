CREATE or replace TYPE Employee_type force AS OBJECT (
    EmployeeID NUMBER,
    First_name VARCHAR2(100),
    Last_name VARCHAR2(100),
    Salary NUMBER,
    Professional_degree VARCHAR2(50),
    Employment_date DATE
);