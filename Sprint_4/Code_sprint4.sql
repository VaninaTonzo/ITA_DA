-- SPRINT 4 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Vanina Tonzo

-- We create the data base
CREATE DATABASE task4;
-- We use the DB task4
USE task4;
-- SHOW VARIABLES LIKE "secure_file_priv"; >>>> NULL

-- Para poder cargar datos de csv con path locales
-- Modifocamos la conexion MySQL Workbench:
-- Click derecho -> Edit Connection).
-- Pestaña Connection -> Advanced.
-- En el cuadro "Others", escribimos: OPT_LOCAL_INFILE=1.

-- Activate local_infile so we can add csv from local
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = ON;
SET PERSIST local_infile = ON;
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- We create table american_users
CREATE TABLE IF NOT EXISTS american_users (
	id VARCHAR(255),
	name VARCHAR(15),  
	surname VARCHAR(20),
	phone VARCHAR (200),
	email VARCHAR(255),
	birth_date VARCHAR(255),
	country VARCHAR (255),
	city VARCHAR(255), 
	postal_code VARCHAR(20),
	address VARCHAR(255)
    );

-- Load the data from csv
LOAD DATA LOCAL INFILE '/Users/tonzo/Desktop/IT_ACADEMY/sprint4_SQL/american_users.csv'
INTO TABLE american_users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"' -- birth_date is enclosed by ""
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- We create table european_users
    CREATE TABLE IF NOT EXISTS european_users (
        id VARCHAR(255),
        name VARCHAR(15),  
        surname VARCHAR(20),
        phone VARCHAR (200),
        email VARCHAR(255),
        birth_date VARCHAR(255),
        country VARCHAR (255),
        city VARCHAR(255), 
        postal_code VARCHAR(20),
        address VARCHAR(255)
    );

-- Load the data from csv
LOAD DATA LOCAL INFILE '/Users/tonzo/Desktop/IT_ACADEMY/sprint4_SQL/european_users.csv'
INTO TABLE european_users 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- We create table company
    CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15),
        company_name VARCHAR(255),
        phone VARCHAR (200),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );

-- Load the data from csv
LOAD DATA LOCAL INFILE '/Users/tonzo/Desktop/IT_ACADEMY/sprint4_SQL/companies.csv'
INTO TABLE companies 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- We create table Credit Card
CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(255),
    user_id VARCHAR(255),
    iban VARCHAR(255),
    pan VARCHAR(255),  
    pin VARCHAR(255),   
    cvv VARCHAR(255),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(255));
    
    
-- Load the data from csv
LOAD DATA LOCAL INFILE '/Users/tonzo/Desktop/IT_ACADEMY/sprint4_SQL/credit_cards.csv'
INTO TABLE credit_cards 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- We create table products
    CREATE TABLE IF NOT EXISTS products (
        id VARCHAR(15),
        product_name VARCHAR(255),
        price VARCHAR(100),
        colour VARCHAR(100),
        weight VARCHAR(100),
        warehouse_id VARCHAR(255)
    );

-- Load the data from csv
LOAD DATA LOCAL INFILE '/Users/tonzo/Desktop/IT_ACADEMY/sprint4_SQL/products.csv'
INTO TABLE products 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- We create table transactions
    CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(255),
        card_id VARCHAR(15), 
        business_id VARCHAR(20),
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        product_ids VARCHAR (255), 
        user_id INT,
        lat FLOAT, -- mirar si es decimal o float
        longitude FLOAT -- mirar si es decimal o float
    );

-- Load the data from csv
LOAD DATA LOCAL INFILE '/Users/tonzo/Desktop/IT_ACADEMY/sprint4_SQL/transactions.csv'
INTO TABLE transactions 
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


SELECT * FROM transactions
LIMIT 2;

-- LEVEL 1
-- Exercise 1

-- SELECT * FROM european_users
-- LIMIT 2;

ALTER TABLE european_users 
ADD COLUMN Continent VARCHAR(50) DEFAULT 'Europe';

SELECT * FROM european_users
LIMIT 2;

-- SELECT * FROM american_users
-- LIMIT 2;

ALTER TABLE american_users 
ADD COLUMN Continent VARCHAR(50) DEFAULT 'America';

SELECT * FROM american_users
LIMIT 2;

-- jusrificar la creacion de la variable continente
-- We create a new table adding together european_users and american_users
CREATE TABLE all_users AS
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address, Continent FROM european_users
UNION ALL
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address, Continent FROM american_users;

-- DESCRIBE transactions;
-- DESCRIBE all_users;
-- DESCRIBE products;
-- DESCRIBE credit_cards;

-- We set the primary keys in each dimensional and the fact tables:
ALTER TABLE all_users
MODIFY COLUMN id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_users_id PRIMARY KEY (id);

ALTER TABLE products
MODIFY COLUMN id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_products_id PRIMARY KEY (id);

ALTER TABLE companies
MODIFY COLUMN company_id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_company_id PRIMARY KEY (company_id);

ALTER TABLE credit_cards
MODIFY COLUMN id VARCHAR(100) NOT NULL,
MODIFY COLUMN user_id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_credit_cards_id PRIMARY KEY (id);
-- ADD CONSTRAINT fk_credit_cards_user_id FOREIGN KEY (user_id) REFERENCES all_users(id);


ALTER TABLE transactions
	MODIFY COLUMN id VARCHAR(100) NOT NULL,
	MODIFY COLUMN user_id VARCHAR(100) NOT NULL,
	MODIFY COLUMN product_ids VARCHAR(100) NOT NULL,
    MODIFY COLUMN card_id VARCHAR(100) NOT NULL,
ADD CONSTRAINT pk_transactions_id PRIMARY KEY (id),
ADD CONSTRAINT fk_transactions_users_id FOREIGN KEY (user_id) REFERENCES all_users(id),
ADD CONSTRAINT fk_transactions_business_id FOREIGN KEY (business_id) REFERENCES companies(company_id),
ADD CONSTRAINT fk_transactions_credit_cards_id FOREIGN KEY (card_id) REFERENCES credit_cards(id);

-- DROP TABLES american_users, european_users;

-- User with more than 80 transactions
-- USING JOIN

-- SELECT 
-- 	au.id AS "User Id",
--     au.Continent AS "Continent", 
--     COUNT(t.id) AS "Number of Transactions"
-- FROM transactions t
-- LEFT JOIN all_users au 
-- 	ON t.user_id = au.id
-- GROUP BY au.id
-- HAVING COUNT(t.id) > 80
-- ORDER BY COUNT(t.id) DESC;

-- Using Subquerie 
SELECT 
    t.user_id AS "User Id",
    COUNT(t.id) AS "Number of Transactions"
FROM transactions t
WHERE EXISTS (
    SELECT 1 
    FROM all_users au
    WHERE au.id = t.user_id
)
GROUP BY t.user_id
HAVING COUNT(t.id) > 80
ORDER BY COUNT(t.id) DESC;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Exercise 2
-- Using JOING
SELECT
    ROUND(AVG(t.amount),2) AS "Avg amount",
    cc.iban AS "Iban num"
FROM transactions t
INNER JOIN credit_cards cc
	ON t.card_id = cc.id
INNER JOIN companies c 
	ON t.business_id = c.company_id
WHERE 
    c.company_name = "Donec Ltd"
GROUP BY
	cc.iban
ORDER BY
	AVG(t.amount) DESC; 


-- Using subqueries
SELECT
    (SELECT cc.iban
    FROM credit_cards cc
    WHERE cc.id = t.card_id) AS "Iban", -- we select Iban from the credit card table where id btw t and cc is the same
    ROUND(AVG(t.amount),2) AS "Avg Amount"
FROM 
    transactions t
WHERE
	t.business_id = (
		SELECT c.company_id
        FROM companies c
        WHERE c.company_name = "Donec Ltd")
GROUP BY 
	t.card_id
ORDER BY
	AVG(t.amount) DESC;
    
-- LEVEL 2
-- Exercise 1
#Following steps from: https://www.baeldung.com/sql/with-clause-table-creation
-- ROW_NUMBER() OVER(PARTITION BY...) row number enumera cada transaction, partition by, parte los row en grupos dentro del table
-- PARTITION BY is always used inside OVER() clause.

-- We create a new table 
CREATE TABLE active_ccards AS
	WITH 
        ranked_transactions AS -- First temporal table in WITH
		(SELECT card_id AS Card_id, 
				declined AS Declined,
                timestamp AS Transaction_time,
			ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS row_num
		FROM transactions
		),
		last3_transactions AS -- second temporal table in WITH
        (SELECT *
		FROM ranked_transactions
		WHERE row_num <= 3
		)
-- now we filter the temporary tables to create active_ccards table
	SELECT card_id,
		CASE WHEN SUM(declined) = 3 THEN 'Inactive' -- declined is a boolean arg
		ELSE 'Active'
		END AS cc_state
	FROM last3_transactions
	GROUP BY card_id;
    
SELECT * FROM active_ccards;

SELECT 
	cc_state AS "Credit card state",
	COUNT(card_id) AS Active_ccards 
FROM active_ccards
WHERE cc_state = 'Active';

-- LEVEL 3
-- Exercise 1

DESCRIBE transactions;
DESCRIBE products;
SELECT *
FROM transactions;

-- Create a new table to store the relationship between transactions and products
CREATE TABLE transaction_products AS
SELECT 
    t.id AS transaction_id, 
    jt.product_id AS Product_id
FROM transactions t
CROSS JOIN JSON_TABLE( -- CROSS JOIN: for each row in transactions generates as many rows as elements in the array in the new table
    -- JSON TABLE generates an array that is treated as a temporary table 
    CONCAT('[', t.product_ids, ']'), 
    '$[*]' COLUMNS ( -- $[*] moves through every element in the arraytransaction_products
        product_id VARCHAR(100) PATH '$'
    )
) AS jt;

-- DESCRIBE transaction_products;

-- We add Primary and Foreign Keys to the table transaction_products 
ALTER TABLE transaction_products
ADD CONSTRAINT pk_trans_prod_id PRIMARY KEY (transaction_id, product_id),
ADD CONSTRAINT fk_tp_to_transactions FOREIGN KEY (transaction_id) REFERENCES transactions(id),
ADD CONSTRAINT fk_tp_to_products FOREIGN KEY (product_id) REFERENCES products(id);

DESCRIBE transaction_products;

-- we count the number that each product has been sold and transaction not declined
SELECT 
    p.id AS product_id, 
    p.product_name, 
    COUNT(tp.transaction_id) AS times_sold
FROM 
    products p
LEFT JOIN 
    transaction_products tp ON p.id = tp.product_id
LEFT JOIN 
    transactions t ON tp.transaction_id = t.id AND t.declined = 0
GROUP BY 
    p.id, p.product_name
ORDER BY 
    times_sold DESC;

