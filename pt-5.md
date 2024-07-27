Often, we can
• Use EXCEPT instead of NOT EXISTS and NOT IN.
• Use INTERSECT instead of EXISTS and IN.
• Use UNION instead of complex selection criteria with OR.

```
SELECT
last_name,
first_name,
p.passenger_id,
coalesce(max(CASE WHEN custom_field_name ='passport_num'
THEN custom_field_value ELSE NULL END),'') AS passport_num,
coalesce(max(CASE WHEN custom_field_name='passport_exp_date'
THEN custom_field_value ELSE NULL END),'') AS passport_exp_date,
coalesce(max(CASE WHEN custom_field_name ='passport_country'
THEN custom_field_value ELSE NULL END),'') AS passport_country
FROM passenger p JOIN custom_field cf
USING (passenger_id)
WHERE cf.passenger_id<50000
AND p.passenger_id<50000
GROUP by 3,1,2;

Moving grouping into subquery

SELECT
last_name,
first_name,
passport_num,
passport_exp_date,
passport_country
FROM
passenger p
JOIN
(SELECT cf.passenger_id,
coalesce(max(CASE WHEN custom_field_name ='passport_num'
THEN custom_field_value ELSE NULL END),'') AS passport_num,
coalesce(max(CASE WHEN custom_field_name='passport_exp_date'
THEN custom_field_value ELSE NULL END),'') AS passport_exp_date,
coalesce(max(CASE WHEN custom_field_name ='passport_country'
THEN custom_field_value ELSE NULL END),'') AS passport_country
FROM custom_field cf
WHERE cf.passenger_id<50000
GROUP BY 1) info
USING (passenger_id)
WHERE p.passenger_id<50000;
```
