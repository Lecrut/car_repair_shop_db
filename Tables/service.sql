CREATE or replace TYPE TasksArray_type force AS VARRAY(10) OF TASK_TYPE;

CREATE SEQUENCE SERVICE_SEQUENCE START WITH 1 INCREMENT BY 1;

CREATE or replace TYPE Service_type force AS OBJECT (
    ServiceID NUMBER,
    tasks TasksArray_type,
    employee REF EMPLOYEE_TYPE,
    owner REF OWNER_TYPE,
    car REF CAR_TYPE,
    position NUMBER,
    hour DATE,

    MEMBER FUNCTION displayTimeInHours RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY Service_type AS
    MEMBER FUNCTION displayTimeInHours RETURN NUMBER IS
        v_result Number := 0;
        v_task TASK_TYPE;
    BEGIN
        FOR i IN 1..self.tasks.COUNT LOOP
            v_task := self.TASKS(i);
            v_result := v_result + v_task.TIME_IN_HOURS;
        END LOOP;

        RETURN v_result;
    END displayTimeInHours;
END;
