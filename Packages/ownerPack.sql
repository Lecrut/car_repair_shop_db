CREATE OR REPLACE PACKAGE OwnerPackage AS
    PROCEDURE ShowAllOwners;
    PROCEDURE ShowOwnerByPhone(phone_number IN VARCHAR2);
    PROCEDURE AddOwner(
        p_name VARCHAR2,
        p_surname VARCHAR2,
        p_phone VARCHAR2
    );
    FUNCTION GetOwnerRefByPhone(phone_number IN VARCHAR2) RETURN REF OWNER_TYPE;
END OwnerPackage;


CREATE OR REPLACE PACKAGE BODY OwnerPackage AS
    PROCEDURE ShowAllOwners IS
        CURSOR c IS SELECT OwnerID, Name, Surname, Phone FROM ClientTable;
        cnt NUMBER;
    Begin
         SELECT COUNT(*) INTO cnt FROM ClientTable;
        IF cnt = 0 THEN
            dbms_output.put_line('No clients founded');
        ELSE
            FOR r IN (SELECT DISTINCT OwnerID, Name, Surname, Phone FROM ClientTable) LOOP
                dbms_output.put_line('OwnerID: ' || r.OwnerID || ', Name: ' || r.Name || ', Surname: ' || r.Surname || ', Phone: ' || r.Phone);
            END LOOP;
        END IF;
    end ShowAllOwners;

    PROCEDURE ShowOwnerByPhone(phone_number IN VARCHAR2) AS
        cnt NUMBER;
    Begin
        SELECT COUNT(*) INTO cnt FROM ClientTable WHERE Phone = phone_number;
        IF cnt = 0 THEN
            dbms_output.put_line('No clients founded');
        ELSE
            FOR r IN (SELECT DISTINCT OwnerID, Name, Surname, Phone FROM ClientTable WHERE Phone = phone_number) LOOP
                dbms_output.put_line('OwnerID: ' || r.OwnerID || ', Name: ' || r.Name || ', Surname: ' || r.Surname || ', Phone: ' || r.Phone);
            END LOOP;
        END IF;
    END ShowOwnerByPhone;

    PROCEDURE AddOwner(
        p_name VARCHAR2,
        p_surname VARCHAR2,
        p_phone VARCHAR2
    ) IS
        next_id NUMBER;
        phone_exists NUMBER;
        phone_exception EXCEPTION;
    Begin
        SELECT COUNT(*) INTO phone_exists FROM ClientTable WHERE phone = p_phone;
        IF phone_exists > 0 THEN
            RAISE phone_exception;
        END IF;
        SELECT COUNT(*) INTO next_id FROM ClientTable;
        next_id := next_id + 1;
        INSERT INTO CLIENTTABLE VALUES (OWNER_TYPE(next_id, p_name, p_surname, p_phone));
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Added new client ' || p_name || ' ' || p_surname || ' tel. ' || p_phone || ' with ID ' || next_id || '.');
    EXCEPTION
        WHEN phone_exception THEN
            RAISE_APPLICATION_ERROR(-20001, 'Client with this phone number already exists');
    end AddOwner;

    FUNCTION GetOwnerRefByPhone(phone_number IN VARCHAR2) RETURN REF OWNER_TYPE AS
      client_ref REF OWNER_TYPE;
    BEGIN
      SELECT REF(c) INTO client_ref FROM ClientTable c WHERE c.Phone = phone_number;
      RETURN client_ref;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END GetOwnerRefByPhone;

END OwnerPackage;
