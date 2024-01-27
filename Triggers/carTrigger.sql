CREATE OR REPLACE TRIGGER check_vin
    BEFORE INSERT ON CARTABLE
    FOR EACH ROW
    DECLARE
        lower_mileage_exception EXCEPTION;
        car_exists EXCEPTION;
        vin_exists NUMBER;
        new_mileage NUMBER;
    BEGIN
        SELECT COUNT (*) INTO vin_exists FROM CarTable WHERE VIN = :NEW.VIN;
        IF vin_exists > 0 THEN
            SELECT Mileage into  new_mileage FROM CarTable WHERE VIN = :NEW.VIN;
            IF :NEW.Mileage < new_mileage THEN
                RAISE lower_mileage_exception;
            ELSE
                UPDATE CarTable
                SET Mileage = :NEW.Mileage
                WHERE VIN = :NEW.VIN;
            END IF;
--             RAISE car_exists;
        END IF;
    EXCEPTION
        WHEN lower_mileage_exception THEN
            RAISE_APPLICATION_ERROR(-20003, 'Nowy przebieg jest mniejszy niż stary przebieg.');
        WHEN car_exists THEN
            RAISE_APPLICATION_ERROR(-20004, 'Dany samochód już jest w bazie.');
    END;
