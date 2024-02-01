CREATE or replace TYPE Owner_type force AS OBJECT (
    OwnerID NUMBER,
    Name VARCHAR2(100),
    Surname VARCHAR2(100),
    Phone VARCHAR2(15)
);