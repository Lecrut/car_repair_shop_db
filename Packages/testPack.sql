delete from SERVICETABLE;
delete from CARTABLE;
delete from CLIENTTABLE;
delete from EMPLOYEESTABLE;



select * from WORKSHOPTABLE;
select * from TASKSTABLE;

commit;

begin
    TASKSPACKAGE.SHOWTASKS();
end;

begin
    EMPLOYEESPACKAGE.ADDEMPLOYEE('Jan', 'Kowalski', 2000, 'Senior', TO_DATE('1994-01-01', 'YYYY-MM-DD'));
    EMPLOYEESPACKAGE.ADDEMPLOYEE('Zygmunt', 'Nowacki', 1000, 'Junior', TO_DATE('2024-01-01', 'YYYY-MM-DD'));
end;

begin
    EMPLOYEESPACKAGE.SHOWEMPLOYEESLIST();
end;

DECLARE
    v_Brand VARCHAR2(50) := 'Ford';
    v_Model VARCHAR2(50) := 'Mondeo';
    v_Year_of_production NUMBER := 2010;
    v_Registration_number VARCHAR2(15) := 'ABC 1333';
    v_Mileage NUMBER := 2300;
    v_VIN VARCHAR2(20) := '12341234';
BEGIN
    CARPACKAGE.AddCar(v_Brand, v_Model, v_Year_of_production, v_Registration_number, v_Mileage, v_VIN);
END;

DECLARE
    v_Brand VARCHAR2(50) := 'Opel';
    v_Model VARCHAR2(50) := 'Astra';
    v_Year_of_production NUMBER := 2020;
    v_Registration_number VARCHAR2(15) := 'WPI 1333';
    v_Mileage NUMBER := 230000;
    v_VIN VARCHAR2(20) := '987987';
BEGIN
    CARPACKAGE.AddCar(v_Brand, v_Model, v_Year_of_production, v_Registration_number, v_Mileage, v_VIN);
END;

DECLARE
    v_Brand VARCHAR2(50) := 'Toyota';
    v_Model VARCHAR2(50) := 'Prius';
    v_Year_of_production NUMBER := 2014;
    v_Registration_number VARCHAR2(15) := 'WPI 8WM1';
    v_Mileage NUMBER := 13000;
    v_VIN VARCHAR2(20) := 'T1234';
BEGIN
    CARPACKAGE.AddCar(v_Brand, v_Model, v_Year_of_production, v_Registration_number, v_Mileage, v_VIN);
END;

DECLARE
    v_Brand VARCHAR2(50) := 'Audi';
    v_Model VARCHAR2(50) := 'A6';
    v_Year_of_production NUMBER := 2004;
    v_Registration_number VARCHAR2(15) := 'WX 12345';
    v_Mileage NUMBER := 13000;
    v_VIN VARCHAR2(20) := 'A12345';
BEGIN
    CARPACKAGE.AddCar(v_Brand, v_Model, v_Year_of_production, v_Registration_number, v_Mileage, v_VIN);
END;

begin
    CARPACKAGE.SHOWCARS();
end;

begin
    OWNERPACKAGE.ADDOWNER('Jan', 'Nowacki', '123456789');
    OWNERPACKAGE.ADDOWNER('Szymon', 'Nowak', '987654321');
end;

begin
    OWNERPACKAGE.SHOWALLOWNERS();
end;

begin
    OWNERPACKAGE.SHOWOWNERBYPHONE('blad');
end;

begin
    OWNERPACKAGE.SHOWOWNERBYPHONE('987654321');
end;

begin
    SERVICEPACKAGE.PRINTFREEHOURS( TO_DATE('2024-02-03', 'YYYY-MM-DD'));
end;

begin
    SERVICEPACKAGE.PRINTSERVICEDATABYDATE(TO_DATE('2024-02-03', 'YYYY-MM-DD'));
end;

begin
    SERVICEPACKAGE.PRINTNEARESTDATE(SYS.ODCINUMBERLIST(1, 3, 6));
end;

BEGIN
    SERVICEPACKAGE.ADDSERVICE('987987', 1, '123456789', TO_DATE('2024-02-03 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), SYS.ODCINUMBERLIST(1, 3, 6), 2);
END;

BEGIN
    SERVICEPACKAGE.ADDSERVICE('12341234', 2, '987654321', TO_DATE('2024-02-03 8:00:00', 'YYYY-MM-DD HH24:MI:SS'), SYS.ODCINUMBERLIST(1, 3, 6), 1);
END;

BEGIN
    SERVICEPACKAGE.ADDSERVICEFORNEARESTDATE('T1234', 1, '123456789', SYS.ODCINUMBERLIST(3,6));
END;

BEGIN
    SERVICEPACKAGE.ADDSERVICEFORNEARESTDATE('A12345', 1, '123456789', SYS.ODCINUMBERLIST(3,6));
END;

begin
    SERVICEPACKAGE.PRINTCLIENTHISTORY('123456789');
end;

begin
    SERVICEPACKAGE.PRINTSERVICEDATABYDATE(TO_DATE('2024-02-03', 'YYYY-MM-DD'));
end;
