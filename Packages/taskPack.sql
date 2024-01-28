CREATE OR REPLACE PACKAGE TasksPackage AS
    PROCEDURE ShowTasks;
    FUNCTION createTasksArray (p_ids SYS.ODCINUMBERLIST) RETURN TasksArray_type;
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

    FUNCTION createTasksArray (p_ids SYS.ODCINUMBERLIST) RETURN TasksArray_type AS
        tasks TasksArray_type := TasksArray_type();
        task TASK_TYPE;
        task_id NUMBER;
        task_name VARCHAR2(100);
        task_price NUMBER;
        task_time NUMBER;
    BEGIN
        tasks.EXTEND(p_ids.count);
        for i in 1 .. p_ids.count loop
            SELECT TASKID, NAME, PRICE, TIME_IN_HOURS  INTO task_id, task_name, task_price, task_time FROM taskstable WHERE TASKID = p_ids(i);
            task := TASK_TYPE(task_id, task_name, task_price, task_time);
            tasks(i) := task;
        end loop;
        IF tasks.count = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
        RETURN tasks;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono danego taska');
    END createTasksArray;

END TasksPackage;

commit;