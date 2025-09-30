-- 1.

SELECT r.name AS restaurant,
       AVG(f.price) AS avg_price
FROM serves s
JOIN restaurants r ON s.restID = r.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.restID, r.name;

-- 2.

SELECT r.name AS restaurant,
       MAX(f.price) AS max_price
FROM serves s
JOIN restaurants r ON s.restID = r.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.restID, r.name;

-- 3.

SELECT r.name AS restaurant,
       COUNT(DISTINCT f.type) AS food_type_count
FROM serves s
JOIN restaurants r ON s.restID = r.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.restID, r.name;

-- 4. 

SELECT c.name AS chef,
       AVG(f.price) AS avg_price
FROM works w
JOIN chefs c ON w.chefID = c.chefID
JOIN serves s ON w.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY c.chefID, c.name;

-- 5. 

SELECT r.name AS restaurant,
       AVG(f.price) AS avg_price
FROM serves s
JOIN restaurants r ON s.restID = r.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.restID, r.name
ORDER BY avg_price desc
LIMIT 1;