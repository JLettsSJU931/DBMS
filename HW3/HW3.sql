
-- Table Keys
ALTER TABLE customers
ADD CONSTRAINT PK_customers PRIMARY KEY (cid);

ALTER TABLE merchants
ADD CONSTRAINT PK_merchants PRIMARY KEY (mid);

ALTER TABLE orders
ADD CONSTRAINT PK_orders PRIMARY KEY (oid);

ALTER TABLE products
ADD CONSTRAINT PK_products PRIMARY KEY (pid);

ALTER TABLE contain
ADD CONSTRAINT FK_contain FOREIGN KEY (oid) REFERENCES orders(oid);

ALTER TABLE contain
ADD CONSTRAINT FK2_contain FOREIGN KEY (pid) REFERENCES products(pid);

ALTER TABLE place
ADD CONSTRAINT FK_place FOREIGN KEY (cid) REFERENCES customers(cid),
ADD CONSTRAINT FK2_place FOREIGN KEY (oid) REFERENCES orders(oid);

ALTER TABLE sell
ADD CONSTRAINT FK_sell FOREIGN KEY (mid) REFERENCES merchants(mid),
ADD CONSTRAINT FK2_sell FOREIGN KEY (pid) REFERENCES products(pid);

-- Table Constraints
ALTER TABLE products
ADD CONSTRAINT CHK_product CHECK (name = 'Printer' OR name = 'Ethernet Adapter' OR name = 'Desktop' OR name = 'Hard Drive' OR name = 'Laptop' OR name = 'Router' OR name = 'Network Card' OR name = 'Super Drive' OR name = 'Monitor'),
ADD CONSTRAINT CHK2_product CHECK (category = 'Peripheral' OR category = 'Networking' OR category = 'Computer');

ALTER TABLE sell
ADD CONSTRAINT CHK_sell CHECK (price>=0 AND price<=100000),
ADD CONSTRAINT CHK2_sell CHECK (quantity_available>=0 AND quantity_available<=1000);

ALTER TABLE orders
ADD CONSTRAINT CHK_orders CHECK (shipping_method = 'UPS' OR shipping_method = 'FedEx' OR shipping_method = 'USPS'),
ADD CONSTRAINT CHK2_orders CHECK (shipping_cost>=0 AND shipping_cost<=500);

ALTER TABLE place
ADD CONSTRAINT valid_date CHECK (order_date IS NOT NULL);

-- 1
SELECT p.name AS product_name, m.name AS merchant_name
FROM products p 
LEFT JOIN sell s ON p.pid = s.pid
LEFT JOIN merchants m ON s.mid = m.mid
WHERE s.quantity_available = 0;

-- 2
SELECT p.name AS product_name, p.description
FROM products p
LEFT JOIN sell s on p.pid = s.pid
WHERE s.pid IS NULL;

-- 3
SELECT COUNT(DISTINCT c.cid) AS num_customers
FROM customers c
LEFT JOIN place pl ON c.cid = pl.cid
LEFT JOIN contain co ON pl.oid = co.oid
LEFT JOIN products p ON co.pid = p.pid
WHERE p.name LIKE '%SATA%'  
AND c.cid NOT IN (
    SELECT DISTINCT c2.cid
    FROM customers c2
    LEFT JOIN place pl2 ON c2.cid = pl2.cid
    LEFT JOIN contain co2 ON pl2.oid = co2.oid
    LEFT JOIN products p2 ON co2.pid = p2.pid
    WHERE p2.name LIKE '%Router%' 
);

-- 4
SELECT m.name AS merchant, p.name AS product, p.category, s.price
FROM sell s
LEFT JOIN products p ON s.pid = p.pid
LEFT JOIN merchants m ON s.mid = m.mid
WHERE p.category = 'Networking'
  AND m.name = 'HP';

  
UPDATE sell s
LEFT JOIN products p ON s.pid = p.pid
LEFT JOIN merchants m ON s.mid = m.mid
SET s.price = ROUND(s.price * 0.8, 2)
WHERE p.category = 'Networking'
  AND m.name = 'HP';

-- 5
SELECT o.oid, p.name AS product_name, p.description AS product_description, s.price
FROM sell s
LEFT JOIN products p ON s.pid = p.pid
LEFT JOIN contain co ON p.pid = co.pid
LEFT JOIN orders o ON co.oid = o.oid
LEFT JOIN place pl ON o.oid = pl.oid
LEFT JOIN customers c ON pl.cid = c.cid
WHERE pl.cid = '1';

-- 6
SELECT distinct m.name AS company_name, YEAR(pl.order_date) AS fiscal_year, ROUND(SUM(s.price*s.quantity_available), 2) AS annual_earnings
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain co ON s.pid = co.pid
JOIN place pl ON co.oid = pl.oid
group by m.name, fiscal_year
order by m.name;

-- 7
SELECT distinct m.name AS company_name, YEAR(pl.order_date) AS fiscal_year, ROUND(SUM(s.price*s.quantity_available), 2) AS annual_earnings
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain co ON s.pid = co.pid
JOIN place pl ON co.oid = pl.oid
group by m.name, fiscal_year
order by annual_earnings desc
LIMIT 1;

-- 8
SELECT DISTINCT o.shipping_method, round(avg(o.shipping_cost), 2) as average_price
FROM orders o 
group by o.shipping_method
order by average_price desc
LIMIT 1;

-- 9
SELECT company_name, category, earnings
FROM(
SELECT distinctrow m.name AS company_name, p.category, ROUND(SUM(s.price*s.quantity_available), 2) AS earnings, RANK() OVER (PARTITION BY m.name ORDER BY SUM(s.price * s.quantity_available) DESC) AS rank_num
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain co ON s.pid = co.pid
JOIN products p ON co.pid = p.pid
JOIN place pl ON co.oid = pl.oid
group by m.name, p.category
) AS subquery
WHERE rank_num=1
order by company_name;

-- 10
SELECT company_name, customer_name, amount_spent
FROM(
SELECT distinct m.name AS company_name, c.fullname AS customer_name, ROUND(SUM(s.price), 2) AS amount_spent,  RANK() OVER (PARTITION BY m.name ORDER BY SUM(s.price) DESC) AS rank_num
FROM customers c
JOIN place pl ON c.cid = pl.cid
JOIN contain co ON pl.oid = co.oid
JOIN sell s ON co.pid = s.pid
JOIN merchants m ON s.mid = m.mid
group by m.name, c.fullname
)AS subquery
WHERE rank_num=1
order by amount_spent desc;

SELECT company_name, customer_name, amount_spent
FROM(
SELECT distinct m.name AS company_name, c.fullname AS customer_name, ROUND(SUM(s.price), 2) AS amount_spent,  RANK() OVER (PARTITION BY m.name ORDER BY SUM(s.price)) AS rank_num
FROM customers c
JOIN place pl ON c.cid = pl.cid
JOIN contain co ON pl.oid = co.oid
JOIN sell s ON co.pid = s.pid
JOIN merchants m ON s.mid = m.mid
group by m.name, c.fullname
)AS subquery
WHERE rank_num=1
order by amount_spent;