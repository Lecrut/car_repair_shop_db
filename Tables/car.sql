CREATE TYPE Car AS OBJECT (
    ID NUMBER,
    Brand VARCHAR2(50),
    Model VARCHAR2(50),
    Year_of_production NUMBER,
    Registration_number VARCHAR2(15),
    Mileage NUMBER,
    VIN VARCHAR2(20),
    Owner REF Owner
);