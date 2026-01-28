-- Sprint 2 Bases de datos Relacionales e Introducción a SQL
-- Vanina Tonzo
-- Creamos la base de datos y las tablas
CREATE DATABASE IF NOT EXISTS transactions;
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

    
-- Nivel 1
-- Ejercicio 1
SHOW TABLES;

DESCRIBE company;
DESCRIBE transaction;

SHOW CREATE TABLE company;
SHOW CREATE TABLE transaction;

-- Ejercicio 2
-- 1. Listado de los países que están generando ventas
SELECT 
	DISTINCT c.country AS Country,
    COUNT(t.id) AS 'Num of transactions'
FROM company c
JOIN transaction t
  ON c.id = t.company_id
GROUP BY c.country
ORDER BY 'Num of transactions' DESC;
  
-- 2. Desde cuántos países se generan las ventas   
SELECT COUNT(DISTINCT c.country) AS 'Total num countries with sales'
FROM company c
JOIN transaction t
  ON c.id = t.company_id;

-- 3. Compañía con la media más alta de ventas
SELECT c.company_name AS 'Company Name', ROUND(AVG(t.amount),2) AS 'Average Sales'
FROM company c
JOIN transaction t
  ON c.id = t.company_id
GROUP BY c.id
ORDER BY 'Average Sales' DESC
LIMIT 1;


-- Ejercicio 3
-- 1. Transacciones realizadas por empresas de Alemania
SELECT 
	t.id  AS 'Transaction Id', 
    t.company_id AS 'Company Id', 
    t.amount AS 'Amount' 
FROM transaction t
WHERE EXISTS (
    SELECT c.id
    FROM company c
    WHERE c.id = t.company_id
    AND c.country = 'Germany'
);

-- 2. Empresas con transacciones por encima de la media global
SELECT 
	c.id AS 'Company Id', 
	c.company_name AS 'Company Name'
FROM company c
WHERE c.id IN (
	SELECT t.company_id
    FROM transaction t
    WHERE t.amount > (SELECT AVG(transaction.amount) FROM transaction));


-- 3.Empresas sin transacciones (listado antes de eliminar)
SELECT 
	c.company_name AS 'Company Name', 
	c.id AS 'Company Id', 
    c.country AS 'Country'
FROM company c
WHERE c.id  NOT IN (
	SELECT t.company_id
    FROM transaction t);


-- Nivel 2
-- Ejercicio 1
-- Identificar los cinco días con mayor ingreso total
SELECT 
    DATE_FORMAT(t.timestamp, '%d.%m.%Y') AS Date,
    SUM(t.amount) AS 'Total Sales'
FROM transaction t
GROUP BY Date
ORDER BY 'Total Sales' DESC
LIMIT 5;

-- Exercici 2
-- Media de ventas por país (orden descendente)
SELECT 
	c.country AS 'Country', 
    ROUND(AVG(t.amount),2) AS 'Average sales'
FROM company c
JOIN transaction t
  ON c.id = t.company_id
GROUP BY c.country
ORDER BY 'Average sales' DESC;

-- Exercici 3
-- Transacciones de empresas del mismo país que "Non Institute"
-- Usando JOIN y SUBCONSULTAS
SELECT 
    t.id AS 'Transaction id', 
    c.company_name AS 'Company name', 
    c.country AS 'Country',
    c.email AS Email,
    t.amount AS 'Amount',
    t.declined AS Declined
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE c.country = (
    SELECT c.country 
    FROM company c
    WHERE c.company_name = 'Non Institute'
);

-- Usando SUBCONSULTAS
SELECT 
    t.id AS 'Transaction id', 
    c.company_name AS 'Company name', 
    c.country AS 'Country',
    c.email AS Email,
    t.amount AS 'Amount',
    t.declined AS Declined
FROM transaction t, company c  
WHERE t.company_id = c.id      
  AND c.country = (
      SELECT country 
      FROM company 
      WHERE company_name = 'Non Institute'
  );
  
-- Nivel 3
-- Ejercicio 1
-- Empresas con transacciones entre 350 y 400 euros en fechas específicas
-- Fechas seleccionadas  nom, telèfon, país, data i amount
SELECT
	c.company_name AS 'Company name',
    c.phone AS 'Phone',
    c.country AS 'Country',
    DATE(t.timestamp) AS 'Date',
	t.amount AS 'Amount'
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.amount BETWEEN 350 AND 400
	AND DATE(t.timestamp) IN ('2015-04-29','2018-07-20','2024-03-23') 
ORDER BY 'Amount' DESC;

-- Exercici 2
-- Clasificación de empresas según número de transacciones
SELECT
    c.company_name AS 'Company name',
    COUNT(t.id) AS 'Num of Transactions',
    CASE
        WHEN COUNT(t.id) > 400 THEN 'Plus Client'
        ELSE 'Basic Client'
    END AS Category
FROM company c
JOIN transaction t
    ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY Category DESC;


