### Group first select last

```
SELECT
city,
date_trunc('month', scheduled_departure) AS month,
count(*) passengers
FROM airport a
JOIN flight f ON airport_code = departure_airport
JOIN booking_leg l ON f.flight_id =l.flight_id
JOIN boarding_pass b ON b.booking_leg_id = l.booking_leg_id
GROUP BY 1,2
ORDER BY 3 DESC;

SELECT
city,
date_trunc('month', scheduled_departure),
sum(passengers) passengers
FROM airport a
JOIN flight f ON airport_code = departure_airport
JOIN (
SELECT flight_id, count(*) passengers
FROM booking_leg l
JOIN boarding_pass b USING (booking_leg_id)
GROUP BY flight_id
) cnt
USING (flight_id)
GROUP BY 1,2
ORDER BY 3 DESC;
```

### Key Differences

#### Aggregation Level and Order of Operations:

Query 1: Aggregates the number of passengers at the level of flight, booking_leg, and boarding_pass directly in the main query.

Steps:
Joins all tables (airport, flight, booking_leg, and boarding_pass).
Counts the total number of passengers per city and month.
Aggregates all passengers at once before applying GROUP BY and ORDER BY.

Query 2: Uses a subquery to first aggregate the number of passengers per flight and then aggregates those results further by city and month.

Steps:
Subquery (cnt) calculates the number of passengers per flight_id by counting the boarding_pass entries.
Main query joins this aggregated data with the flight and airport tables.
Aggregates the results again to compute the total number of passengers per city and month.

#### Performance Considerations:

Query 1: May involve more intermediate data due to the need to join all tables and then perform aggregation. The count is computed directly from the joined data.

Query 2: Potentially more efficient because the subquery pre-aggregates the passenger count per flight, reducing the amount of data to be processed in the outer query. This can be especially beneficial if there are many flight_id records.

#### Complexity and Clarity:

Query 1: More straightforward as it performs all operations in a single query block.
Query 2: Uses a subquery, which might make it more complex but can provide better performance through reduced data processing in the outer query.

### Result

```
postgres=# explain analyze
SELECT
city,
date_trunc('month', scheduled_departure) AS month,
count(*) passengers
FROM airport a
JOIN flight f ON airport_code = departure_airport
JOIN booking_leg l ON f.flight_id =l.flight_id
JOIN boarding_pass b ON b.booking_leg_id = l.booking_leg_id
GROUP BY 1,2
ORDER BY 3 DESC;
                                                                           QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=7881129.01..7944362.74 rows=25293492 width=25) (actual time=60734.873..60734.994 rows=2202 loops=1)
   Sort Key: (count(*)) DESC
   Sort Method: quicksort  Memory: 208kB
   ->  HashAggregate  (cost=3553263.73..4165840.49 rows=25293492 width=25) (actual time=60726.271..60734.152 rows=2202 loops=1)
         Group Key: a.city, date_trunc('month'::text, f.scheduled_departure)
         Planned Partitions: 16  Batches: 1  Memory Usage: 49425kB
         ->  Hash Join  (cost=628037.31..1672060.26 rows=25293492 width=17) (actual time=11389.528..54804.721 rows=25293491 loops=1)
               Hash Cond: (f.departure_airport = a.airport_code)
               ->  Hash Join  (cost=628011.74..1541998.92 rows=25293492 width=12) (actual time=11389.316..44218.935 rows=25293491 loops=1)
                     Hash Cond: (l.flight_id = f.flight_id)
                     ->  Hash Join  (cost=604073.24..1451664.58 rows=25293492 width=4) (actual time=11114.343..38549.713 rows=25293491 loops=1)
                           Hash Cond: (b.booking_leg_id = l.booking_leg_id)
                           ->  Seq Scan on boarding_pass b  (cost=0.00..513692.92 rows=25293492 width=8) (actual time=0.507..7996.001 rows=25293491 loops=1)
                           ->  Hash  (cost=310506.66..310506.66 rows=17893566 width=8) (actual time=11056.440..11056.441 rows=17893566 loops=1)
                                 Buckets: 8388608  Batches: 4  Memory Usage: 240298kB
                                 ->  Seq Scan on booking_leg l  (cost=0.00..310506.66 rows=17893566 width=8) (actual time=0.679..5485.317 rows=17893566 loops=1)
                     ->  Hash  (cost=15398.78..15398.78 rows=683178 width=16) (actual time=274.373..274.373 rows=683178 loops=1)
                           Buckets: 1048576  Batches: 1  Memory Usage: 40216kB
                           ->  Seq Scan on flight f  (cost=0.00..15398.78 rows=683178 width=16) (actual time=0.019..98.433 rows=683178 loops=1)
               ->  Hash  (cost=16.92..16.92 rows=692 width=13) (actual time=0.195..0.196 rows=692 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 39kB
                     ->  Seq Scan on airport a  (cost=0.00..16.92 rows=692 width=13) (actual time=0.013..0.094 rows=692 loops=1)
 Planning Time: 0.332 ms
 Execution Time: 60784.990 ms
(24 rows)

Time: 60816.003 ms (01:00.816)
postgres=#
postgres=# explain analyze
postgres-# SELECT
city,
date_trunc('month', scheduled_departure),
sum(passengers) passengers
FROM airport a
JOIN flight f ON airport_code = departure_airport
JOIN (
SELECT flight_id, count(*) passengers
FROM booking_leg l
JOIN boarding_pass b USING (booking_leg_id)
GROUP BY flight_id
) cnt
USING (flight_id)
GROUP BY 1,2
ORDER BY 3 DESC;
                                                                                              QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=889163.99..889164.49 rows=200 width=49) (actual time=36583.405..36734.608 rows=2202 loops=1)
   Sort Key: (sum((count(*)))) DESC
   Sort Method: quicksort  Memory: 208kB
   ->  GroupAggregate  (cost=889151.34..889156.34 rows=200 width=49) (actual time=36491.057..36732.354 rows=2202 loops=1)
         Group Key: a.city, (date_trunc('month'::text, f.scheduled_departure))
         ->  Sort  (cost=889151.34..889151.84 rows=200 width=25) (actual time=36491.046..36679.828 rows=254253 loops=1)
               Sort Key: a.city, (date_trunc('month'::text, f.scheduled_departure))
               Sort Method: quicksort  Memory: 19081kB
               ->  Hash Join  (cost=887449.93..889143.70 rows=200 width=25) (actual time=34994.697..36317.238 rows=254253 loops=1)
                     Hash Cond: (f.departure_airport = a.airport_code)
                     ->  Nested Loop  (cost=887424.36..889117.11 rows=200 width=20) (actual time=34994.482..36197.112 rows=254253 loops=1)
                           ->  Finalize GroupAggregate  (cost=887423.94..887474.61 rows=200 width=12) (actual time=34994.413..35656.989 rows=254253 loops=1)
                                 Group Key: l.flight_id
                                 ->  Gather Merge  (cost=887423.94..887470.61 rows=400 width=12) (actual time=34994.404..35535.454 rows=728374 loops=1)
                                       Workers Planned: 2
                                       Workers Launched: 2
                                       ->  Sort  (cost=886423.91..886424.41 rows=200 width=12) (actual time=34949.512..35008.324 rows=242791 loops=3)
                                             Sort Key: l.flight_id
                                             Sort Method: quicksort  Memory: 15218kB
                                             Worker 0:  Sort Method: quicksort  Memory: 15840kB
                                             Worker 1:  Sort Method: quicksort  Memory: 15828kB
                                             ->  Partial HashAggregate  (cost=886414.27..886416.27 rows=200 width=12) (actual time=34656.869..34761.262 rows=242791 loops=3)
                                                   Group Key: l.flight_id
                                                   Batches: 1  Memory Usage: 28705kB
                                                   Worker 0:  Batches: 1  Memory Usage: 28705kB
                                                   Worker 1:  Batches: 1  Memory Usage: 28705kB
                                                   ->  Parallel Hash Join  (cost=328447.18..833719.49 rows=10538955 width=4) (actual time=22704.579..32038.818 rows=8431164 loops=3)
                                                         Hash Cond: (b.booking_leg_id = l.booking_leg_id)
                                                         ->  Parallel Seq Scan on boarding_pass b  (cost=0.00..366147.55 rows=10538955 width=8) (actual time=0.840..8530.578 rows=8431164 loops=3)
                                                         ->  Parallel Hash  (cost=206127.53..206127.53 rows=7455652 width=8) (actual time=8444.044..8444.045 rows=5964522 loops=3)
                                                               Buckets: 8388608  Batches: 4  Memory Usage: 240640kB
                                                               ->  Parallel Seq Scan on booking_leg l  (cost=0.00..206127.53 rows=7455652 width=8) (actual time=14.380..5432.307 rows=5964522 loops=3)
                           ->  Index Scan using flight_pkey on flight f  (cost=0.42..8.20 rows=1 width=16) (actual time=0.002..0.002 rows=1 loops=254253)
                                 Index Cond: (flight_id = l.flight_id)
                     ->  Hash  (cost=16.92..16.92 rows=692 width=13) (actual time=0.204..0.204 rows=692 loops=1)
                           Buckets: 1024  Batches: 1  Memory Usage: 39kB
                           ->  Seq Scan on airport a  (cost=0.00..16.92 rows=692 width=13) (actual time=0.007..0.116 rows=692 loops=1)
 Planning Time: 0.354 ms
 Execution Time: 36736.308 ms
(39 rows)

Time: 36737.611 ms (00:36.738)
postgres=#
```
