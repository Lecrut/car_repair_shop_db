delete from SERVICETABLE;
delete from CARTABLE;
delete from CLIENTTABLE;
delete from EMPLOYEESTABLE;



select * from WORKSHOPTABLE;
select * from TASKSTABLE;

commit;

begin
    EMPLOYEESPACKAGE.ADDEMPLOYEE('Jan1', 'Kowalski2', 2000, 'Majster', TO_DATE('2024-01-01', 'YYYY-MM-DD'));
end;

begin
    EMPLOYEESPACKAGE.SHOWEMPLOYEESLIST();
end;

DECLARE
    v_Brand VARCHAR2(50) := 'Seat';
    v_Model VARCHAR2(50) := 'Ibiza';
    v_Year_of_production NUMBER := 2010;
    v_Registration_number VARCHAR2(15) := 'ABC 1333';
    v_Mileage NUMBER := 2300;
    v_VIN VARCHAR2(20) := '3254323';
BEGIN
    CARPACKAGE.AddCar(v_Brand, v_Model, v_Year_of_production, v_Registration_number, v_Mileage, v_VIN);
END;

begin
    CARPACKAGE.SHOWCARS();
end;

begin
    OWNERPACKAGE.ADDOWNER('Jan', 'Nowacki', '503127642');
end;

begin
--     OWNERPACKAGE.SHOWALLOWNERS();
--     OWNERPACKAGE.SHOWOWNERBYPHONE('blad');
    OWNERPACKAGE.SHOWOWNERBYPHONE('503976322');
end;

begin
    SERVICEPACKAGE.PRINTFREEHOURS( TO_DATE('2024-03-01', 'YYYY-MM-DD'));
end;


begin
    SERVICEPACKAGE.PRINTSERVICEDATABYDATE(TO_DATE('2024-03-01', 'YYYY-MM-DD'));
end;

BEGIN
    SERVICEPACKAGE.ADDSERVICE('ABC1234', 3, '503976322', TO_DATE('2024-03-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), SYS.ODCINUMBERLIST(1), 2);
END;

begin
    SERVICEPACKAGE.PRINTCLIENTHISTORY('503976322');
end;