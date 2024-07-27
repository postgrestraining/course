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
