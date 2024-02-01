CREATE or replace TYPE Task_type force AS OBJECT (
    TaskID NUMBER,
    Name Varchar2(100),
    Price NUMBER,
    Time_in_hours NUMBER
);
