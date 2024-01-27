CREATE OR REPLACE PACKAGE TasksPackage AS
    PROCEDURE ShowTasks;
END TasksPackage;

CREATE OR REPLACE PACKAGE BODY TasksPackage AS

    PROCEDURE ShowTasks IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Available tasks');

        FOR r IN (SELECT TaskID, Name, Price, Time_in_hours FROM TASKSTABLE) LOOP
            DBMS_OUTPUT.PUT_LINE('TaskID: ' || r.TaskID);
            DBMS_OUTPUT.PUT_LINE('Name: ' || r.Name);
            DBMS_OUTPUT.PUT_LINE('Price: ' || r.Price);
            DBMS_OUTPUT.PUT_LINE('Time in hours: ' || r.Time_in_hours);
            DBMS_OUTPUT.PUT_LINE('---------------------');
        END LOOP;

    END ShowTasks;

END TasksPackage;

commit;