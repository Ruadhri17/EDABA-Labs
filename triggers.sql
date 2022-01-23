-- Krzysztof Piotrowski 
-- Index: 300175         
-- EDABA Task 3

-- Trigger 1
-- This trigger runs when there is change in trip price.
-- It returns message whether price increased, decrease or there is no change
-- additionaly it prints value by which the price is changed.
CREATE OR REPLACE TRIGGER CALCULATE_PRICE_INCREASE
BEFORE UPDATE ON TRIP
FOR EACH ROW
WHEN (NEW.TRIP_ID > 0)
DECLARE
PRICE_DIFFERENCE NUMBER;
BEGIN
    IF :OLD.PRICE > :NEW.PRICE THEN
        PRICE_DIFFERENCE := :OLD.PRICE - :NEW.PRICE;
        DBMS_OUTPUT.PUT_LINE(' PRICE IS LOWER BY : ' || PRICE_DIFFERENCE);
    ELSIF :OLD.PRICE < :NEW.PRICE THEN
        PRICE_DIFFERENCE := :NEW.PRICE - :OLD.PRICE;
        DBMS_OUTPUT.PUT_LINE(' PRICE IS HIGHER BY: ' || PRICE_DIFFERENCE);
    ELSE
        PRICE_DIFFERENCE := 0;
        DBMS_OUTPUT.PUT_LINE('NO PRICE DIFFERENCE');
    END IF;  
END;
--Trigger 1 test
SET SERVEROUTPUT ON; -- make the trigger ouput display in script output

-- check price of trip with id 1  
SELECT PRICE FROM TRIP
WHERE TRIP.TRIP_ID = 1;

-- update price (30000 to make sure it will be higher)
UPDATE TRIP T
SET T.PRICE = 30000
WHERE T.TRIP_ID = 1;

-- trigger output that price is higher

-- update price (10000 to get output that price is lower)
UPDATE TRIP T
SET T.PRICE = 10000
WHERE T.TRIP_ID = 1;

-- update price with the same amount to get output that is no change in price
UPDATE TRIP T
SET T.PRICE = 10000
WHERE T.TRIP_ID = 1;

--Triger 2
-- this trigger change trip destination whenever new hotel to trip is assigned
-- it check location of hotel and update destination of trip according to that 
CREATE OR REPLACE TRIGGER CHANGE_DESTINATION
AFTER UPDATE ON TRIPHOTELRELATION
FOR EACH ROW
BEGIN
UPDATE TRIP T
SET T.DESTINATION = TO_CHAR((SELECT CITY.COUNTRY
            FROM HOTEL
            JOIN ADDRESS ON HOTEL.ADDRESS_ID = ADDRESS.ADDRESS_ID
            JOIN CITY ON ADDRESS.CITY_ID = CITY.CITY_ID
            WHERE HOTEL_ID = :NEW.HOTEL_ID))
WHERE T.TRIP_ID = :OLD.TRIP_ID;
END;
-- Triger 2 test
-- show all hotel - trip relations
SELECT * FROM TRIPHOTELRELATION;
--show desstination of the trip with ID = 2
SELECT DESTINATION FROM TRIP
WHERE TRIP_ID = 2;
-- update hotel for the trip with ID = 2 
UPDATE TRIPHOTELRELATION
SET HOTEL_ID = 5
WHERE
TRIP_ID = 2;
-- show again destination of the trip with ID = 2 
SELECT DESTINATION FROM TRIP
WHERE TRIP_ID = 2;

-- Triger 3
-- this trigger is activated when trip is cancelled
-- It casues canceling of all transactions associated with trip and make hotel free (cancel connections of trip and hotel)
CREATE OR REPLACE TRIGGER CANCEL_TRIP
BEFORE DELETE ON TRIP
FOR EACH ROW
BEGIN
DELETE FROM TRIPHOTELRELATION 
WHERE TRIPHOTELRELATION.TRIP_ID = :OLD.TRIP_ID;
DELETE FROM TRANSACTION 
WHERE TRANSACTION.TRIP_ID = :OLD.TRIP_ID;
END;