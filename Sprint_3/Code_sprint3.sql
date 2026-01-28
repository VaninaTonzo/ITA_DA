-- SPRINT 3 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Vanina Tonzo
-- Usamos la base de datos
USE transactions;

 -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );

-- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15), -- REFERENCES credit_card(id),  
        company_id VARCHAR(20), 
        user_id INT, -- REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
-- LEVEL 1 
-- Exercise 1
-- We create the table Credit Card
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(255) PRIMARY KEY,
    iban VARCHAR(255),
    pan VARCHAR(255),  
    pin VARCHAR(255),   
    cvv VARCHAR(255),
    expiring_date VARCHAR(255));
    
DESCRIBE credit_card;

-- The fk creation is not possible yet due to some id card values at the child table (transaction) do not exist at the parent table (credit_card).
-- To detect these missing values we left join both tables. This will show the card IDs in transaction table that are NULL in the credit_card table
SELECT t.credit_card_id 
FROM transaction t
LEFT JOIN credit_card cc ON t.credit_card_id = cc.id
WHERE cc.id IS NULL;

-- Example
SELECT c.id
FROM credit_card c
WHERE c.id = "CcU-3792";

-- Now we insert these NULL values at the parent table credit_card
INSERT INTO credit_card (id)
SELECT DISTINCT t.credit_card_id -- unique values
FROM transaction t
LEFT JOIN credit_card cc ON t.credit_card_id = cc.id
WHERE cc.id IS NULL AND t.credit_card_id IS NOT NULL;

-- We add a new fk at the transaction table
ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_ccard
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

-- Exercise 2
-- First we demonstrate that Iban does not exist
SELECT iban 
FROM credit_card 
WHERE iban = 'TR323456312213576817699999' ; 

UPDATE credit_card 
SET iban = 'TR323456312213576817699999' 
WHERE id = 'CcU-2938';

SELECT id, iban 
FROM credit_card 
WHERE id = 'CcU-2938';

-- Exercise 3
-- Code that gives an error message (1452):
-- INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
-- VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, 111.11, 0);

-- >>>>>> Problems with company table
-- We check the existence of the company id at the parent table company
SELECT c.id
FROM company c
WHERE c.id = 'b-9999';

-- We insert the compny id in the company table
INSERT INTO company (id, company_name) 
VALUES ('b-9999', 'IT_academy');

-- >>>>>> Problems with credit_card table
-- We check the existence of the credit card id at the parent table credit_card
SELECT cc.id
FROM credit_card cc
WHERE cc.id = 'CcU-9999';

-- We insert the credit card id in the credit_card table
INSERT INTO credit_card (id) 
VALUES ('CcU-9999');

-- we confirm the existence of cc id
SELECT cc.id
FROM credit_card cc
WHERE cc.id = 'CcU-9999';

-- Now we can insert the values for the rest of the columns in transaction 
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, 111.11, 0);

-- Exercise 4
-- we drop column pan from credit_card table
ALTER TABLE credit_card 
DROP COLUMN pan;

DESCRIBE credit_card;

-- LEVEL 2
-- Exercise 1
-- Before removing the record, we confirm its existence 
SELECT t.id 
FROM transaction t 
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT t.id 
FROM transaction t 
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Exercise 2
CREATE OR REPLACE VIEW VistaMarketing AS
	SELECT c.id AS "Company Id",
		   c.company_name AS "Company Name",
		   c.phone AS Phone,
		   c.country AS Country,
		   ROUND(AVG(t.amount),2) AS "Average Expenses"
	FROM company c
	JOIN transaction t ON c.id=t.company_id
	GROUP BY
		c.id;

SELECT * FROM VistaMarketing
ORDER BY "Average Expenses" DESC; 
    
-- Exercise 3
SELECT * FROM VistaMarketing
WHERE Country = "Germany"
ORDER BY "Average Expenses" DESC;

-- LEVEL 3
-- Exercise 1
-- estructura_dades_user.sql:
CREATE TABLE IF NOT EXISTS user (
	id INT PRIMARY KEY, -- a. Datatype manual modification to keep the reference integrity with transaction
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- b. Code modifications in table user
ALTER TABLE user RENAME TO data_user, -- Table rename
                 MODIFY COLUMN id INT, -- col change datatype
                 RENAME COLUMN email TO personal_email; -- column rename
-- c. Code modifications in table company
ALTER TABLE company
                 DROP COLUMN website; -- delete column website
                 
-- d. Code modifications in table credit_card
ALTER TABLE credit_card
                 ADD fecha_actual DATE, -- add new column + datatype
                 MODIFY COLUMN cvv INT;
               

-- Exercise 2
CREATE OR REPLACE VIEW InformeTecnico AS 
	SELECT t.id AS ID_Transaction,
		   u.name AS User_Name,
		   u.surname AS User_Surname,
		   cc.iban AS IBAN,
		   c.company_name AS Company_Name,
           t.declined AS Declined,
           t.amount AS Amount
	FROM 
		transaction t
	JOIN 
		company c ON t.company_id=c.id
	JOIN 
		data_user u ON t.user_id = u.id
	JOIN 
		credit_card cc ON t.credit_card_id=cc.id;

SELECT * FROM InformeTecnico
ORDER BY ID_Transaction DESC;

