SELECT * FROM USER_TABLES;

SELECT * FROM USER_TYPES;

SELECT * FROM USER_OBJECTS;

DROP TABLE SERVICETABLE


select * from CARTABLE;
drop table CARTABLE;
commit;
drop table SERVICETABLE;
delete from CARTABLE;
commit;

begin
    OWNERPACKAGE.ShowAllOwners();
end;

begin
    TASKSPACKAGE.SHOWTASKS();
end;

begin
    EMPLOYEESPACKAGE.SHOWEMPLOYEESLIST();
end;

begin
    CARPACKAGE.SHOWCARS();
end;


DECLARE
    v_Brand VARCHAR2(50) := 'Toyota';
    v_Model VARCHAR2(50) := 'Corolla';
    v_Year_of_production NUMBER := 2010;
    v_Registration_number VARCHAR2(15) := 'ABC 123';
    v_Mileage NUMBER := 2300;
    v_VIN VARCHAR2(20) := '1234567890';
BEGIN
    CARPACKAGE.AddCar(v_Brand, v_Model, v_Year_of_production, v_Registration_number, v_Mileage, v_VIN);
END;
