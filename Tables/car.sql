CREATE SEQUENCE Car_sequence START WITH 1 INCREMENT BY 1;

CREATE or replace TYPE Car_type force AS OBJECT (
    CarID NUMBER,
    Brand VARCHAR2(50),
    Model VARCHAR2(50),
    Year_of_production NUMBER,
    Registration_number VARCHAR2(15),
    Mileage NUMBER,
    VIN VARCHAR2(20)
);
