CREATE TYPE TasksArray_type AS VARRAY(10) OF TASK_TYPE;

CREATE TYPE Service_type AS OBJECT (
    ServiceID NUMBER,
    tasks TasksArray_type,
    employee REF Employees,
    owner REF OWNER_TYPE,
    car REF CAR_TYPE,
    position NUMBER,
    hour DATE
);
