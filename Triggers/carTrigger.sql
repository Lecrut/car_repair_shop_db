CREATE OR REPLACE TRIGGER check_vin
    BEFORE INSERT ON CARTABLE
    FOR EACH ROW
    DECLARE
        car_exists EXCEPTION;
        vin_exists NUMBER;
    BEGIN
        SELECT COUNT (*) INTO vin_exists FROM CarTable WHERE VIN = :NEW.VIN;
        IF vin_exists > 0 THEN
            RAISE car_exists;
        END IF;
    EXCEPTION
        WHEN car_exists THEN
            RAISE_APPLICATION_ERROR(-20004, 'Current car is already in base.');
    END;
