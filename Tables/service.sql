CREATE TYPE TasksArray AS VARRAY(10) OF Task;

CREATE TYPE Service AS OBJECT (
    ID NUMBER,
    tasks TasksArray,
    employee REF Employees,
    position NUMBER,
    hour DATE
);