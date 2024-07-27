### csv data

#### Update name in csv data

```

CREATE TABLE csvdata (
    inx int NOT NULL,
    organization_id text,
    name text,
    website text,
    country text,
    description text,
    founded text,
    industry text,
    number_of_employees text
) ;

-- import data

UPDATE csvdata
SET name = (
    SELECT first_name
    FROM passenger
    ORDER BY RANDOM()
    LIMIT 1
)
WHERE inx IN (
    SELECT inx
    FROM csvdata
    ORDER BY RANDOM()
    LIMIT 10000
);

```
### Memory issue 

```
postgres=# SELECT
    p.last_name,
    p.first_name,
    p.passenger_id
FROM
    passenger p
JOIN
    csvdata1 c
ON
    p.first_name = c.name
WHERE
    p.passenger_id < 5000000;
Killed
[postgres@lab01 ~]$
```

drop index idx_passenger_first_name;
drop index idx_csvdata_name;
drop index idx_passenger_id;

### Create indexes and partition

```
CREATE INDEX idx_passenger_first_name ON passenger(first_name);
CREATE INDEX idx_csvdata_name ON csvdata(name);
CREATE INDEX idx_passenger_id ON passenger(passenger_id);

CREATE TABLE csvdata (
    inx int NOT NULL,
    organization_id text,
    name text,
    website text,
    country text,
    description text,
    founded text,
    industry text,
    number_of_employees text
) PARTITION BY RANGE (inx);

-- Create partitions for different ranges
CREATE TABLE csvdata_0_500000 PARTITION OF csvdata
    FOR VALUES FROM (1) TO (500000);

CREATE TABLE csvdata_500000_1000000 PARTITION OF csvdata
    FOR VALUES FROM (500000) TO (1000000);

CREATE TABLE csvdata_1000000_1500000 PARTITION OF csvdata
    FOR VALUES FROM (1000000) TO (1500000);
	
CREATE TABLE csvdata_1500000_3000000 PARTITION OF csvdata
    FOR VALUES FROM (1500000) TO (MAXVALUE);	
```

Final Result

```

postgres=# SELECT
    p.last_name,
    p.first_name,
    p.passenger_id
FROM
    passenger p
JOIN
    csvdata c
ON
    p.first_name = c.name
WHERE
    p.passenger_id < 5000000;

 last_name | first_name | passenger_id
-----------+------------+--------------
(0 rows)

postgres=#


postgres=#      explain analyze SELECT
    p.last_name,
    p.first_name,
    p.passenger_id
FROM
    passenger p
JOIN
    csvdata c
ON
    p.first_name = c.name
WHERE
    p.passenger_id < 5000000;
                                                                                       QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=92906.16..1945088.33 rows=4207938109 width=16) (actual time=4931.645..4931.648 rows=0 loops=1)
   ->  Bitmap Heap Scan on passenger p  (cost=92905.72..326619.51 rows=4963263 width=16) (actual time=414.347..2826.964 rows=4999999 loops=1)
         Recheck Cond: (passenger_id < 5000000)
         Heap Blocks: exact=78116
         ->  Bitmap Index Scan on idx_passenger_id  (cost=0.00..91664.91 rows=4963263 width=0) (actual time=396.140..396.141 rows=4999999 loops=1)
               Index Cond: (passenger_id < 5000000)
   ->  Memoize  (cost=0.43..2.30 rows=25 width=17) (actual time=0.000..0.000 rows=0 loops=4999999)
         Cache Key: p.first_name
         Cache Mode: logical
         Hits: 4995335  Misses: 4664  Evictions: 0  Overflows: 0  Memory Usage: 323kB
         ->  Append  (cost=0.42..2.29 rows=25 width=17) (actual time=0.024..0.024 rows=0 loops=4664)
               ->  Index Only Scan using csvdata_0_500000_name_idx on csvdata_0_500000 c_1  (cost=0.42..0.55 rows=7 width=17) (actual time=0.007..0.007 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
               ->  Index Only Scan using csvdata_500000_1000000_name_idx on csvdata_500000_1000000 c_2  (cost=0.42..0.54 rows=6 width=17) (actual time=0.005..0.005 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
               ->  Index Only Scan using csvdata_1000000_1500000_name_idx on csvdata_1000000_1500000 c_3  (cost=0.42..0.54 rows=6 width=17) (actual time=0.005..0.005 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
               ->  Index Only Scan using csvdata_1500000_3000000_name_idx on csvdata_1500000_3000000 c_4  (cost=0.42..0.54 rows=6 width=17) (actual time=0.005..0.005 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
 Planning Time: 0.466 ms
 Execution Time: 4931.721 ms
(25 rows)

```

### Create indexes
```
create index csvdata_0_500000_i1 on csvdata_0_500000(name);
create index csvdata_500000_1000000_i2 on csvdata_500000_1000000(name);
create index csvdata_1000000_1500000_i3 on csvdata_1000000_1500000(name);
create index csvdata_1500000_3000000_i4 on csvdata_1500000_3000000(name);


postgres=# explain analyze
postgres-# SELECT
    p.last_name,
    p.first_name,
    p.passenger_id
FROM
    passenger p
JOIN
    csvdata c
ON
    p.first_name = c.name
WHERE
    p.passenger_id < 5000000;
                                                                                    QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=92906.16..1882994.44 rows=114243944 width=16) (actual time=2762.664..2762.667 rows=0 loops=1)
   ->  Bitmap Heap Scan on passenger p  (cost=92905.72..326619.51 rows=4963263 width=16) (actual time=270.932..915.389 rows=4999999 loops=1)
         Recheck Cond: (passenger_id < 5000000)
         Heap Blocks: exact=78116
         ->  Bitmap Index Scan on idx_passenger_id  (cost=0.00..91664.91 rows=4963263 width=0) (actual time=253.617..253.618 rows=4999999 loops=1)
               Index Cond: (passenger_id < 5000000)
   ->  Memoize  (cost=0.43..2.28 rows=24 width=17) (actual time=0.000..0.000 rows=0 loops=4999999)
         Cache Key: p.first_name
         Cache Mode: logical
         Hits: 4995335  Misses: 4664  Evictions: 0  Overflows: 0  Memory Usage: 323kB
         ->  Append  (cost=0.42..2.27 rows=24 width=17) (actual time=0.020..0.020 rows=0 loops=4664)
               ->  Index Only Scan using csvdata_0_500000_i1 on csvdata_0_500000 c_1  (cost=0.42..0.54 rows=6 width=17) (actual time=0.005..0.005 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
               ->  Index Only Scan using csvdata_500000_1000000_i2 on csvdata_500000_1000000 c_2  (cost=0.42..0.54 rows=6 width=17) (actual time=0.005..0.005 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
               ->  Index Only Scan using csvdata_1000000_1500000_i3 on csvdata_1000000_1500000 c_3  (cost=0.42..0.54 rows=6 width=17) (actual time=0.004..0.004 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
               ->  Index Only Scan using csvdata_1500000_3000000_i4 on csvdata_1500000_3000000 c_4  (cost=0.42..0.54 rows=6 width=17) (actual time=0.004..0.004 rows=0 loops=4664)
                     Index Cond: (name = p.first_name)
                     Heap Fetches: 0
 Planning Time: 0.432 ms
 Execution Time: 2762.706 ms
(25 rows)

```








SELECT
    p.last_name,
    p.first_name,
    p.passenger_id
FROM
    passenger p
JOIN
    csvdata1 c
ON
    p.first_name = c.name
WHERE
    p.passenger_id < 5000000;
