-- Definicja typu tabeli obiektowej
CREATE OR REPLACE TYPE TasksTable_TYPE AS TABLE OF Task_type;

-- Definicja pakietu
CREATE OR REPLACE PACKAGE TasksPackage AS
    -- Deklaracja procedury wyświetlającej dane
    PROCEDURE ShowTasks;
END TasksPackage;

-- Definicja ciała pakietu
CREATE OR REPLACE PACKAGE BODY TasksPackage AS
    -- Definicja zmiennej przechowującej dane z tabeli
    v_tasks TasksTable_TYPE;

    -- Definicja procedury wyświetlającej dane
    PROCEDURE ShowTasks IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Available tasks');
        SELECT Task_type(TaskID, Name, Price, Time_in_hours)
        BULK COLLECT INTO v_tasks
        FROM TasksTable;

        FOR i IN 1..v_tasks.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('TaskID: ' || v_tasks(i).TaskID);
            DBMS_OUTPUT.PUT_LINE('Name: ' || v_tasks(i).Name);
            DBMS_OUTPUT.PUT_LINE('Price: ' || v_tasks(i).Price);
            DBMS_OUTPUT.PUT_LINE('Time in hours: ' || v_tasks(i).Time_in_hours);
            DBMS_OUTPUT.PUT_LINE('---------------------');
        END LOOP;
    END ShowTasks;
END TasksPackage;