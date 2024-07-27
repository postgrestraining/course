### Push grouping inside

```
SELECT * FROM
(SELECT bl.flight_id,
departure_airport,
(avg(price))::numeric (7,2) AS avg_price,
count(DISTINCT passenger_id) AS num_passengers
FROM booking b
JOIN booking_leg bl USING (booking_id)
JOIN flight f USING (flight_id)
JOIN passenger p USING (booking_id)
GROUP BY 1,2) a
WHERE flight_id=222183;

[or]

SELECT bl.flight_id,
departure_airport,
(avg(price))::numeric (7,2) AS avg_price,
count(DISTINCT passenger_id) AS num_passengers
FROM booking b
JOIN booking_leg bl USING (booking_id)
JOIN flight f USING (flight_id)
JOIN passenger p USING (booking_id)
WHERE flight_id=222183
GROUP BY 1,2;
```

### Key Differences


#### Subquery vs. Direct Query:

Query 1: Uses a subquery to perform the aggregation and then applies a WHERE clause on the results of that subquery.
The subquery calculates avg_price and num_passengers for all flights, and then the outer query filters to get results for flight_id = 222183.
Query 2: Performs the aggregation and filtering directly in a single query.
It filters records for flight_id = 222183 before performing the aggregation.

#### Performance:

Query 1: The subquery calculates aggregate values for all flights first and then applies the filter. Depending on the data volume, this may result in less efficient execution since the subquery computes aggregates for all flights before filtering.
Query 2: Filters the data first (i.e., only records for flight_id = 222183 are aggregated). This can be more efficient, especially if there are many flights, because it reduces the amount of data to be aggregated.

#### Readability and Complexity:

Query 1: The use of a subquery adds an extra layer of complexity and might be harder to read and understand, especially for those not familiar with subqueries.
Query 2: More straightforward as it combines filtering and aggregation in a single step, making it easier to follow.

### Query output

```

postgres=# SELECT * FROM
(SELECT bl.flight_id,
departure_airport,
(avg(price))::numeric (7,2) AS avg_price,
count(DISTINCT passenger_id) AS num_passengers
FROM booking b
JOIN booking_leg bl USING (booking_id)
JOIN flight f USING (flight_id)
JOIN passenger p USING (booking_id)
GROUP BY 1,2) a
WHERE flight_id=222183;
 flight_id | departure_airport | avg_price | num_passengers
-----------+-------------------+-----------+----------------
    222183 | ORD               |   1054.33 |            292
(1 row)

Time: 4333.464 ms (00:04.333)

postgres=# SELECT bl.flight_id,
departure_airport,
(avg(price))::numeric (7,2) AS avg_price,
count(DISTINCT passenger_id) AS num_passengers
FROM booking b
JOIN booking_leg bl USING (booking_id)
JOIN flight f USING (flight_id)
JOIN passenger p USING (booking_id)
WHERE flight_id=222183
GROUP BY 1,2;
 flight_id | departure_airport | avg_price | num_passengers
-----------+-------------------+-----------+----------------
    222183 | ORD               |   1054.33 |            292
(1 row)

Time: 1316.465 ms (00:01.316)
postgres=#
postgres=#
```
