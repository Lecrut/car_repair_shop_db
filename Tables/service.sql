CREATE or replace TYPE TasksArray_type force AS VARRAY(10) OF TASK_TYPE;

CREATE or replace TYPE Service_type force AS OBJECT (
    ServiceID NUMBER,
    tasks TasksArray_type,
    employee REF EMPLOYEE_TYPE,
    owner REF OWNER_TYPE,
    car REF CAR_TYPE,
    position NUMBER,
    hour DATE
);
