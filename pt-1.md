### Retrieve Instructor ID

```
SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe';

postgres=# SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe';
 instructor_id
---------------
             1
(1 row)

postgres=#

```

### Retrieve Course IDs for an Instructor

```
SELECT course_id FROM courses WHERE instructor_id = (
    SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe'
);

postgres=# SELECT course_id FROM courses WHERE instructor_id = (
    SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe'
);
 course_id
-----------
         1
         2
(2 rows)

postgres=#

[or]

SELECT course_id FROM courses WHERE instructor_id in (SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe' );

postgres=# SELECT course_id FROM courses WHERE instructor_id in (SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe'
);
 course_id
-----------
         1
         2
(2 rows)

postgres=#


[or]

WITH instructor_info AS (
    -- Step 1: Get the instructor ID for John Doe
    SELECT instructor_id
    FROM instructors
    WHERE first_name = 'John' AND last_name = 'Doe'
)
-- Step 2: Get the course IDs for the instructor found in the CTE
SELECT course_id
FROM courses
WHERE instructor_id = (SELECT instructor_id FROM instructor_info);

[or]

WITH instructor_info AS (
    -- Step 1: Get the instructor ID for John Doe
    SELECT instructor_id
    FROM instructors
    WHERE first_name = 'John' AND last_name = 'Doe'
)
-- Step 2: Join the courses table with the instructor_info CTE
SELECT c.course_id
FROM courses c
JOIN instructor_info i ON c.instructor_id = i.instructor_id;
```

### Retrieve Student IDs Enrolled in Courses

```
SELECT student_id FROM enrollments WHERE course_id IN (
    SELECT course_id FROM courses WHERE instructor_id = (
        SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe'
    )
);


postgres=#
postgres=# SELECT student_id FROM enrollments WHERE course_id IN (
    SELECT course_id FROM courses WHERE instructor_id = (
        SELECT instructor_id FROM instructors WHERE first_name = 'John' AND last_name = 'Doe'
    )
);
 student_id
------------
          1
          1
          2
         10
         11
         15
         16
         20
         21
         25
         26
         30
         31
         35
         36
         40
(16 rows)
```

### Retrieve Student Details Enrolled in Courses

```
SELECT e.student_id, s.first_name, s.last_name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
WHERE e.course_id IN (
    SELECT c.course_id
    FROM courses c
    WHERE c.instructor_id = (
        SELECT i.instructor_id
        FROM instructors i
        WHERE i.first_name = 'John' AND i.last_name = 'Doe'
    )
);

postgres=# SELECT e.student_id, s.first_name, s.last_name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
WHERE e.course_id IN (
    SELECT c.course_id
    FROM courses c
    WHERE c.instructor_id = (
        SELECT i.instructor_id
        FROM instructors i
        WHERE i.first_name = 'John' AND i.last_name = 'Doe'
    )
);
 student_id | first_name | last_name
------------+------------+-----------
          1 | John       | Doe
          1 | John       | Doe
          2 | Jane       | Smith
         10 | Daniel     | Anderson
         11 | Sophia     | Thomas
         15 | Mia        | Lee
         16 | Ethan      | Garcia
         20 | Ryan       | Walker
         21 | Amelia     | Robinson
         25 | Ella       | Allen
         26 | William    | King
         30 | Michael    | Baker
         31 | Aria       | Nelson
         35 | Avery      | Roberts
         36 | Jack       | Gonzalez
         40 | Samuel     | Powell
(16 rows)

postgres=#

```

## Final dataset with sub query

```
SELECT e.student_id, s.first_name, s.last_name, COUNT(e.course_id) AS course_count
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
WHERE e.course_id IN (
    SELECT c.course_id
    FROM courses c
    WHERE c.instructor_id = (
        SELECT i.instructor_id
        FROM instructors i
        WHERE i.first_name = 'John' AND i.last_name = 'Doe'
    )
)
GROUP BY e.student_id, s.first_name, s.last_name;
```

## Final dataset with joins

```
SELECT e.student_id, s.first_name, s.last_name, COUNT(e.course_id) AS course_count
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN instructors i ON c.instructor_id = i.instructor_id
WHERE i.first_name = 'John' AND i.last_name = 'Doe'
GROUP BY e.student_id, s.first_name, s.last_name;
```

## Final dataset with CTE

```
WITH instructor_info AS (
    -- Step 1: Get the instructor ID for John Doe
    SELECT instructor_id
    FROM instructors
    WHERE first_name = 'John' AND last_name = 'Doe'
),
instructor_courses AS (
    -- Step 2: Get the course IDs taught by John Doe
    SELECT course_id
    FROM courses
    WHERE instructor_id IN (SELECT instructor_id FROM instructor_info)
),
enrolled_students AS (
    -- Step 3: Get student enrollments for the courses taught by John Doe
    SELECT e.student_id, e.course_id
    FROM enrollments e
    JOIN instructor_courses ic ON e.course_id = ic.course_id
),
student_details AS (
    -- Step 4: Get student details for enrolled students
    SELECT DISTINCT s.student_id, s.first_name, s.last_name
    FROM students s
    JOIN enrolled_students es ON s.student_id = es.student_id
)
-- Final selection: count courses per student
SELECT sd.student_id, sd.first_name, sd.last_name, COUNT(es.course_id) AS course_count
FROM student_details sd
JOIN enrolled_students es ON sd.student_id = es.student_id
GROUP BY sd.student_id, sd.first_name, sd.last_name;
```

# Identify student with more than one course

```
WITH instructor_courses AS (
    -- Step 1: Get the courses taught by Jacob Brown
    SELECT c.course_id
    FROM courses c
    JOIN instructors i ON c.instructor_id = i.instructor_id
    WHERE i.first_name = 'Jacob' AND i.last_name = 'Brown'
),
enrolled_students AS (
    -- Step 2: Get student enrollments for courses taught by Jacob Brown
    SELECT e.student_id, e.course_id
    FROM enrollments e
    JOIN instructor_courses ic ON e.course_id = ic.course_id
),
student_course_count AS (
    -- Step 3: Count courses for each student
    SELECT e.student_id, COUNT(e.course_id) AS course_count
    FROM enrolled_students e
    GROUP BY e.student_id
),
student_details AS (
    -- Step 4: Get student details for those with more than one course
    SELECT s.student_id, s.first_name, s.last_name, sc.course_count
    FROM students s
    JOIN student_course_count sc ON s.student_id = sc.student_id
    WHERE sc.course_count > 1
)
-- Final selection
SELECT student_id, first_name, last_name, course_count
FROM student_details;
```

#### OR

```
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    COUNT(c.course_id) AS course_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN instructors i ON c.instructor_id = i.instructor_id
WHERE i.first_name = 'Jacob' AND i.last_name = 'Brown'
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(c.course_id) > 1;
```


