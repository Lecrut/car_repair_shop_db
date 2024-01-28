CREATE OR REPLACE PACKAGE CarPackage AS
    PROCEDURE ShowCars;
    PROCEDURE AddCar(
        p_Brand VARCHAR2,
        p_Model VARCHAR2,
        p_Year_of_production NUMBER,
        p_Registration_number VARCHAR2,
        p_Mileage NUMBER,
        p_VIN VARCHAR2
    );
    PROCEDURE EditMileageForCar(p_VIN VARCHAR2, p_Mileage NUMBER);
    FUNCTION GetCarRefByVin(vin_number IN VARCHAR2) RETURN REF CAR_TYPE;
END CarPackage;

CREATE OR REPLACE PACKAGE BODY CarPackage AS

    PROCEDURE ShowCars IS
        cars_count Number;
    begin
        select count(*) into cars_count from CARTABLE;

        if cars_count = 0 then
            DBMS_OUTPUT.PUT_LINE('No cars to show');
        else
            FOR r IN (SELECT CarID, Brand, Model, Year_of_production, Registration_number, Mileage, VIN FROM CARTABLE)
                LOOP
                    DBMS_OUTPUT.PUT_LINE('CarID: ' || r.CarID);
                    DBMS_OUTPUT.PUT_LINE('Brand: ' || r.Brand);
                    DBMS_OUTPUT.PUT_LINE('Model: ' || r.Model);
                    DBMS_OUTPUT.PUT_LINE('Year_of_production: ' || r.Year_of_production);
                    DBMS_OUTPUT.PUT_LINE('Registration_number: ' || r.Registration_number);
                    DBMS_OUTPUT.PUT_LINE('Mileage: ' || r.Mileage);
                    DBMS_OUTPUT.PUT_LINE('VIN: ' || r.VIN);
                    DBMS_OUTPUT.PUT_LINE('---------------------');
                END LOOP;
        end if;
    end ShowCars;

    PROCEDURE AddCar(
        p_Brand VARCHAR2,
        p_Model VARCHAR2,
        p_Year_of_production NUMBER,
        p_Registration_number VARCHAR2,
        p_Mileage NUMBER,
        p_VIN VARCHAR2
    ) IS
        next_id NUMBER;
    BEGIN
        SELECT COUNT(*) INTO next_id FROM CarTable;
        next_id := next_id + 1;
        INSERT INTO CarTable
        VALUES (Car_type(next_id, p_Brand, p_Model, p_Year_of_production, p_Registration_number, p_Mileage, p_VIN));
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Added car ' || p_Brand || ' ' || p_Model || ' on id: ' || next_id || '.');
    END AddCar;

    PROCEDURE EditMileageForCar(p_VIN VARCHAR2, p_Mileage NUMBER) IS
        v_old_mileage NUMBER;

        PROCEDURE CheckMileage(p_VIN VARCHAR2, p_NewMileage NUMBER) IS
        BEGIN
            SELECT Mileage
            INTO v_old_mileage
            FROM CarTable
            WHERE VIN = p_VIN;

            IF p_NewMileage < v_old_mileage THEN
                RAISE_APPLICATION_ERROR(-20001, 'New mileage cannot be less than the current mileage.');
            END IF;
        END CheckMileage;

    BEGIN
        CheckMileage(p_VIN, p_Mileage);

        UPDATE CarTable
        SET Mileage = p_Mileage
        WHERE VIN = p_VIN;

        DBMS_OUTPUT.PUT_LINE('Mileage for VIN ' || p_VIN || ' has been updated to: ' || p_Mileage);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Car with the specified VIN was not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
    END EditMileageForCar;

    FUNCTION GetCarRefByVin(vin_number IN VARCHAR2) RETURN REF CAR_TYPE AS
        car_ref REF CAR_TYPE;
    BEGIN
        SELECT REF(c) INTO car_ref FROM CARTABLE c WHERE c.VIN = vin_number;
        RETURN car_ref;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GetCarRefByVin;

end CarPackage;