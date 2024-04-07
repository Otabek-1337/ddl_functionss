CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT 
    c.name AS category,
    SUM(p.amount) AS total_sales_revenue
FROM 
    film_category fc
JOIN 
    category c ON fc.category_id = c.category_id
JOIN 
    film f ON fc.film_id = f.film_id
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    payment p ON r.rental_id = p.rental_id
WHERE 
    EXTRACT(QUARTER FROM p.payment_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
GROUP BY 
    c.name
HAVING 
    SUM(p.amount) > 0;


CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_quarter INT)
RETURNS TABLE(category VARCHAR, total_sales_revenue DECIMAL) AS
$$
BEGIN
    RETURN QUERY
    SELECT 
        c.name AS category,
        SUM(p.amount) AS total_sales_revenue
    FROM 
        film_category fc
    JOIN 
        category c ON fc.category_id = c.category_id
    JOIN 
        film f ON fc.film_id = f.film_id
    JOIN 
        inventory i ON f.film_id = i.film_id
    JOIN 
        rental r ON i.inventory_id = r.inventory_id
    JOIN 
        payment p ON r.rental_id = p.rental_id
    WHERE 
        EXTRACT(QUARTER FROM p.payment_date) = current_quarter
    GROUP BY 
        c.name
    HAVING 
        SUM(p.amount) > 0;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION new_movie(movie_title VARCHAR)
RETURNS VOID AS
$$
DECLARE
    new_film_id INT;
BEGIN

    SELECT COALESCE(MAX(film_id), 0) + 1 INTO new_film_id FROM film;


    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), 
        (SELECT language_id FROM language WHERE name = 'Klingon'));

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Language not found';
    END IF;
END;
$$ LANGUAGE plpgsql;