CREATE OR REPLACE TRIGGER CheckServiceReservation
BEFORE INSERT ON SERVICETABLE
FOR EACH ROW
DECLARE
    car_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO car_count FROM SERVICETABLE WHERE Car = :NEW.Car AND TRUNC(HOUR) = TRUNC(:NEW.HOUR);
    IF car_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'This car already has a repair reserved on this day.');
    END IF;
END;
