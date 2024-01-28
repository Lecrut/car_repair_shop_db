SELECT * FROM USER_TABLES;

SELECT * FROM USER_TYPES;

SELECT * FROM USER_OBJECTS;

DROP TABLE SERVICETABLE


select * from CARTABLE;
drop table CARTABLE;
commit;
drop table SERVICETABLE;
delete  from SERVICETABLE;
delete from CARTABLE;
commit;
select * from WORKSHOPTABLE;
select * from CLIENTTABLE;
begin
    OWNERPACKAGE.ShowAllOwners();
    OWNERPACKAGE.SHOWOWNERBYPHONE(123456789);
end;

DECLARE
  client_ref REF OWNER_TYPE;
  client_obj OWNER_TYPE;
BEGIN
  -- Wywołujemy funkcję z numerem telefonu
  client_ref := OWNERPACKAGE.GETOWNERREFBYPHONE('123456789');
  -- Jeśli funkcja zwróciła referencję, wyłuskujemy obiekt z referencji
  IF client_ref IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('success');
--     client_obj := DEREF(client_ref);
    SELECT DEREF(client_ref) INTO client_obj FROM DUAL;
    -- Wypisujemy atrybuty obiektu
    dbms_output.put_line('OwnerID: ' || client_obj.OwnerID || ', Name: ' || client_obj.Name || ', Surname: ' || client_obj.Surname || ', Phone: ' || client_obj.Phone);
  ELSE
    -- Jeśli funkcja zwróciła NULL, wypisujemy komunikat
    dbms_output.put_line('Brak klientów');
  END IF;
END;


begin
    TASKSPACKAGE.SHOWTASKS();
end;

begin
    SERVICEPACKAGE.PRINTSERVICEDATABYDATE(TO_DATE('2024-03-01', 'YYYY-MM-DD'));
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

begin
    SERVICEPACKAGE.PRINTFREEHOURS(TO_DATE('2024-03-01', 'YYYY-MM-DD'));
end;


DECLARE
  tasks TasksArray_type;
BEGIN
--     tasks := TASKSPACKAGE.CREATETASKSARRAY(SYS.ODCINUMBERLIST(5, 4 ,3 ,2 ,1));
  -- Wypisujemy elementy tablicy

    SERVICEPACKAGE.ADDSERVICE('1234567890', 1, '123456789', TO_DATE('2024-03-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), SYS.ODCINUMBERLIST(1), 2);

--   TASKSPACKAGE.SHOWTASKS();
END;

select TASKS, deref(EMPLOYEE), deref(OWNER), POSITION, HOUR  from SERVICETABLE;
select * from SERVICETABLE;