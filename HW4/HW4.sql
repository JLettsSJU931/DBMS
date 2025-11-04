
-- Table Constraits

ALTER TABLE address
ADD CONSTRAINT FK_address FOREIGN KEY (city_id) REFERENCES city(city_id);

ALTER TABLE city
ADD CONSTRAINT FK_city FOREIGN KEY (country_id) REFERENCES country(country_id);

ALTER TABLE category
ADD CONSTRAINT CHK_category CHECK (name ='Animation' OR name = 'Comedy' OR name = 'Family' OR name = 'Foreign' OR name = 'Sci-Fi' OR name = 'Travel' OR name = 'Children' OR name = 'Drama' OR name = 'Horror' OR name = 'Action' OR name = 'Classics' OR name = 'Games' OR name = 'New' OR name = 'Documentary' OR name = 'Sports' OR name = 'Music');

ALTER TABLE customer
ADD CONSTRAINT FK_customer1 FOREIGN KEY (store_id) REFERENCES store(store_id),
ADD CONSTRAINT FK_customer2 FOREIGN KEY (address_id) REFERENCES address(address_id);

ALTER TABLE film
ADD CONSTRAINT FK_film FOREIGN KEY (language_id) REFERENCES language(language_id),
ADD CONSTRAINT CHK_film1 CHECK (release_year >= 1888 and release_year <= 2025),
ADD CONSTRAINT CHK_film2 CHECK (rental_duration >= 2 and rental_duration <= 8),
ADD CONSTRAINT CHK_film3 CHECK (rental_rate >= 0.99 and rental_rate <= 6.99),
ADD CONSTRAINT CHK_film4 CHECK (length >= 30 and length <= 200),
ADD CONSTRAINT CHK_film5 CHECK (rating = 'PG ' OR rating = 'G ' OR rating = 'NC-17 ' OR rating = 'NC-17' OR rating = 'PG-13 ' OR rating = 'R '),
ADD CONSTRAINT CHK_film6 CHECK (replacement_cost >= 5.00 and replacement_cost <= 100.00);

ALTER TABLE film_actor
ADD CONSTRAINT FK_film_actor1 FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
ADD CONSTRAINT FK_film_actor2 FOREIGN KEY (film_id) REFERENCES film(film_id),
ADD CONSTRAINT PK_film_actor PRIMARY KEY (actor_id, film_id);

ALTER TABLE film_category
ADD CONSTRAINT FK_film_category1 FOREIGN KEY (category_id) REFERENCES category(category_id),
ADD CONSTRAINT FK_film_category2 FOREIGN KEY (film_id) REFERENCES film(film_id),
ADD CONSTRAINT PK_film_category PRIMARY KEY (category_id, film_id);

ALTER TABLE inventory
ADD CONSTRAINT FK_inventory1 FOREIGN KEY (film_id) REFERENCES film(film_id),
ADD CONSTRAINT FK_inventory2 FOREIGN KEY (store_id) REFERENCES store(store_id);

ALTER TABLE payment
ADD CONSTRAINT FK_payment1 FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
ADD CONSTRAINT FK_payment2 FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
ADD CONSTRAINT FK_payment3 FOREIGN KEY (rental_id) REFERENCES rental(rental_id),
ADD CONSTRAINT valid_p_date CHECK (payment_date IS NOT NULL),
ADD CONSTRAINT CHK_payment CHECK (amount >= 0.00);

ALTER TABLE rental
ADD CONSTRAINT FK_rental1 FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
ADD CONSTRAINT FK_rental2 FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
ADD CONSTRAINT UC_rental1 UNIQUE (rental_date),
ADD CONSTRAINT UC_rental2 UNIQUE (inventory_id),
ADD CONSTRAINT UC_rental3 UNIQUE (customer_id),
ADD CONSTRAINT valid_r_date1 CHECK (rental_date IS NOT NULL),
ADD CONSTRAINT valid_r_date2 CHECK (return_date IS NOT NULL);

ALTER TABLE staff
ADD CONSTRAINT FK_staff1 FOREIGN KEY (address_id) REFERENCES address(address_id),
ADD CONSTRAINT FK_staff2 FOREIGN KEY (store_id) REFERENCES store(store_id);

ALTER TABLE store
ADD CONSTRAINT FK_store FOREIGN KEY (address_id) REFERENCES address(address_id);


-- 1.

SELECT DISTINCT ct.name, AVG(f.length) AS Average_Film_Length
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category ct ON fc.category_id = ct.category_id
GROUP BY ct.name
ORDER BY ct.name;

-- 2.

SELECT DISTINCT ct.name, AVG(f.length) AS Average_Film_Length
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category ct ON fc.category_id = ct.category_id
GROUP BY ct.name
ORDER BY Average_Film_Length
LIMIT 1;

SELECT DISTINCT ct.name, AVG(f.length) AS Average_Film_Length
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category ct ON fc.category_id = ct.category_id
GROUP BY ct.name
ORDER BY Average_Film_Length desc
LIMIT 1;

-- 3.

SELECT DISTINCT c.first_name, c.last_name
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film_category fc ON i.film_id = fc.film_id
LEFT JOIN category ct ON fc.category_id = ct.category_id
WHERE ct.name LIKE '%action%'
AND c.last_name NOT IN(
SELECT DISTINCT c.last_name
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film_category fc ON i.film_id = fc.film_id
LEFT JOIN category ct ON fc.category_id = ct.category_id
WHERE ct.name LIKE '%comedy%'
)
AND c.last_name NOT IN(
SELECT DISTINCT c.last_name
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film_category fc ON i.film_id = fc.film_id
LEFT JOIN category ct ON fc.category_id = ct.category_id
WHERE ct.name LIKE '%classic%'
)
ORDER BY c.first_name;

-- 4

SELECT a.first_name, a.last_name, COUNT(fa.film_id) AS English_Film_Count
FROM actor a 
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN film f ON fa.film_id = f.film_id
LEFT JOIN language l ON f.language_id = l.language_id
WHERE f.language_id = 1
GROUP BY a.first_name, a.last_name
ORDER BY English_Film_Count desc
LIMIT 1;

-- 5

SELECT COUNT(DISTINCT f.title) AS Movies_From_Mike_For_10
FROM rental r
LEFT JOIN staff s ON r.staff_id = s.staff_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
WHERE DATEDIFF(r.return_date, r.rental_date) = 10
AND s.first_name LIKE '%Mike%';

-- 6

SELECT DISTINCT fa.film_id, COUNT(fa.actor_id)
FROM film_actor fa
GROUP BY fa.film_id
ORDER BY COUNT(fa.actor_id) desc
LIMIT 1;

SELECT a.first_name, a.last_name
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN film f ON fa.film_id = f.film_id
WHERE fa.film_id = 508
GROUP BY fa.film_id, a.first_name, a.last_name
HAVING COUNT(DISTINCT fa.actor_id) >= 1
ORDER BY a.first_name;
