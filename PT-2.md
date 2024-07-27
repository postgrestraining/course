### Basic Join with Filtering

SELECT b.account_id,
       a.login,
       p.last_name,
       p.first_name
FROM passenger p
JOIN booking b USING(booking_id)
JOIN account a ON a.account_id = b.account_id
WHERE lower(p.last_name) = 'smith'
AND lower(login) LIKE 'smith%';

### Aggregate Join with Filtering (Order of Joins)

```

SELECT a.account_id,
       a.login,
       f.last_name,
       f.first_name,
       COUNT(*) AS num_bookings
FROM frequent_flyer f
JOIN account a USING(frequent_flyer_id)
JOIN booking b USING(account_id)
WHERE lower(f.last_name) = 'smith'
AND lower(login) LIKE 'smith%'
GROUP BY 1,2,3,4;

[or]

SELECT a.account_id,
       a.login,
       f.last_name,
       f.first_name,
       COUNT(*) AS num_bookings
FROM booking b
JOIN account a ON b.account_id = a.account_id
JOIN frequent_flyer f ON a.frequent_flyer_id = f.frequent_flyer_id
WHERE LOWER(f.last_name) = 'smith'
AND LOWER(a.login) LIKE 'smith%'
GROUP BY a.account_id, a.login, f.last_name, f.first_name;
```

### Differences

#### Join Order:

Query 1: Joins are performed in the order frequent_flyer, then account, then booking. This order of joins doesn't affect the result but can affect performance based on the data distribution and indexes.
Query 2: Joins are performed in the order booking, then account, then frequent_flyer. This order might be closer to how you would logically think about the relationships between the tables (e.g., starting with bookings and moving to accounts and frequent flyers).

#### Join Syntax

Query 1: Uses USING clauses for joining. The USING clause simplifies the join condition by using the common column name directly, assuming that columns with the same name in both tables are used for the join.
Query 2: Uses ON clauses for joining, specifying the exact join conditions. This is more explicit and can be clearer, especially when dealing with multiple join conditions or non-matching column names.

### with CTE

```
WITH booking_first AS (
    SELECT 
        b.account_id 
    FROM 
        booking b
)
SELECT
    a.account_id,
    a.login,
    f.last_name,
    f.first_name,
    COUNT(*) AS num_bookings
FROM
    booking_first bf
JOIN
    account a ON bf.account_id = a.account_id
JOIN
    frequent_flyer f ON a.frequent_flyer_id = f.frequent_flyer_id
WHERE
    LOWER(f.last_name) = 'smith'
    AND LOWER(a.login) LIKE 'smith%'
GROUP BY
    a.account_id, a.login, f.last_name, f.first_name;
```
