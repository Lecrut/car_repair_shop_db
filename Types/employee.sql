CREATE SEQUENCE Employee_sequence START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TYPE Employee_type AS OBJECT (
    EmployeeID NUMBER,
    First_name VARCHAR2(100),
    Last_name VARCHAR2(100),
    Salary NUMBER,
    Professional_degree VARCHAR2(50),
    Employment_date DATE,
    CONSTRUCTOR FUNCTION Employee_type RETURN SELF AS RESULT
) NOT FINAL;

CREATE OR REPLACE TYPE BODY Employee_type AS
    CONSTRUCTOR FUNCTION Employee_type RETURN SELF AS RESULT IS
    BEGIN
        SELF.EmployeeID := Employee_sequence.NEXTVAL;
        RETURN;
    END;
END;

commit;
