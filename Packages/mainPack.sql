CREATE PACKAGE MainPackage AS
    PROCEDURE BookVisitForNearestDate(newService SERVICE_TYPE);
END MainPackage;
/

CREATE OR REPLACE PACKAGE BODY MainPackage AS
    PROCEDURE BookVisitForNearestDate(newService SERVICE_TYPE) IS
        CURSOR service_cursor IS
            SELECT serviceid, tasks, employee, owner, car, position, hour
            FROM ServiceTable
            ORDER BY hour;
        v_min_date Date;
    BEGIN
        SELECT min(hour) INTO v_min_date FROM SERVICETABLE WHERE hour >= sysdate ;
        select * from SERVICETABLE;
    END BookVisitForNearestDate;
END MainPackage;
/
