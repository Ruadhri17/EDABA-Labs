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