-- End-to-End SQL Project: Pigeon Racing Club
-- A complete SQL project...
-- 1. The Business Scenario

-- club organizes long-distance pigeon races and needs a database to track:

-- Owners who breed and race pigeons
-- Pigeons registered to owners (with ring numbers, breed, age)
-- Races — organized events with a release point and race date
-- Race Results — each pigeon's flight time, distance covered, and speed in a race
-- Release Points — the locations pigeons are released from, with distance to the home loft
-- 5 tables is enough to demonstrate every concept end-to-end.

-- 2. Database & Table Creation (DDL + Data Types + Constraints)
CREATE DATABASE pigeon_racing;
USE pigeon_racing;

CREATE TABLE owners (
    owner_id      INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    loft_location VARCHAR(100),
    joined_date   DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE release_points (
    point_id      INT AUTO_INCREMENT PRIMARY KEY,
    point_name    VARCHAR(100) NOT NULL,
    distance_km   DECIMAL(6,2) CHECK (distance_km > 0)   -- distance to home loft
);

CREATE TABLE pigeons (
    pigeon_id     INT AUTO_INCREMENT PRIMARY KEY,
    owner_id      INT,
    ring_number   VARCHAR(20) UNIQUE NOT NULL,
    breed         VARCHAR(50),
    birth_year    INT,
    FOREIGN KEY (owner_id) REFERENCES owners(owner_id)
);

CREATE TABLE races (
    race_id       INT AUTO_INCREMENT PRIMARY KEY,
    race_name     VARCHAR(150) NOT NULL,
    point_id      INT,
    race_date     DATE,
    weather_condition VARCHAR(50) DEFAULT 'Clear',
    FOREIGN KEY (point_id) REFERENCES release_points(point_id)
);

CREATE TABLE race_results (
    result_id     INT AUTO_INCREMENT PRIMARY KEY,
    race_id       INT,
    pigeon_id     INT,
    flight_time_min INT CHECK (flight_time_min > 0),
    speed_mpm     DECIMAL(8,2),        -- meters per minute
    rank_position INT,
    FOREIGN KEY (race_id) REFERENCES races(race_id),
    FOREIGN KEY (pigeon_id) REFERENCES pigeons(pigeon_id)
);


-- 3. Inserting Sample Data (DML)
INSERT INTO owners (name, loft_location, joined_date) VALUES
('Ravi Kumar', 'Hyderabad', '2019-03-10'),
('Anita Sharma', 'Mumbai', '2020-07-15'),
('John Paul', 'Bengaluru', '2018-01-05'),
('Sneha Reddy', 'Hyderabad', '2021-09-20'),
('Amit Verma', 'Delhi', '2017-11-01');

INSERT INTO release_points (point_name, distance_km) VALUES
('Warangal', 140.00),
('Vijayawada', 270.00),
('Nagpur', 500.00),
('Pune', 560.00),
('Chennai', 630.00);

INSERT INTO pigeons (owner_id, ring_number, breed, birth_year) VALUES
(1, 'IN-2021-1001', 'Racing Homer', 2021),
(1, 'IN-2022-1002', 'Racing Homer', 2022),
(2, 'IN-2020-2001', 'Blue Bar', 2020),
(3, 'IN-2021-3001', 'Racing Homer', 2021),
(4, 'IN-2023-4001', 'Show Racer', 2023),
(5, 'IN-2019-5001', 'Blue Bar', 2019);

INSERT INTO races (race_name, point_id, race_date, weather_condition) VALUES
('Spring Sprint', 1, '2024-03-10', 'Clear'),
('Vijayawada Classic', 2, '2024-04-14', 'Clear'),
('Nagpur Endurance', 3, '2024-05-20', 'Windy'),
('Pune Grand Fondo', 4, '2024-06-25', 'Clear'),
('Chennai Marathon', 5, '2024-07-30', 'Cloudy');

INSERT INTO race_results (race_id, pigeon_id, flight_time_min, speed_mpm, rank_position) VALUES
(1, 1, 120, 1166.67, 1),
(1, 3, 125, 1120.00, 2),
(1, 4, 130, 1076.92, 3),
(2, 1, 220, 1227.27, 1),
(2, 6, 230, 1173.91, 2),
(3, 3, 400, 1250.00, 1),
(3, 4, 420, 1190.48, 2),
(4, 1, 440, 1272.73, 1),
(4, 6, 460, 1217.39, 2),
(5, 3, 480, 1312.50, 1),
(5, 5, 500, 1260.00, 2);


-- 4. CRUD Basics
-- READ
SELECT * FROM pigeons;

-- UPDATE
UPDATE pigeons SET breed = 'Racing Homer Elite' WHERE pigeon_id = 1;

-- DELETE
DELETE FROM race_results WHERE rank_position > 2;
-- 5. Operators
-- Comparison + Logical
SELECT * FROM race_results WHERE speed_mpm > 1200 AND rank_position = 1;

-- BETWEEN
SELECT * FROM race_results WHERE flight_time_min BETWEEN 200 AND 450;

-- IN
SELECT * FROM release_points WHERE point_name IN ('Nagpur', 'Pune', 'Chennai');

-- LIKE
SELECT * FROM owners WHERE name LIKE 'A%';
-- 6. Aggregate Functions + GROUP BY + HAVING + ORDER BY
-- Average speed per pigeon across all races
SELECT p.ring_number, AVG(rr.speed_mpm) AS avg_speed
FROM pigeons p
JOIN race_results rr ON p.pigeon_id = rr.pigeon_id
GROUP BY p.ring_number
ORDER BY avg_speed DESC;

-- Release points used in more than 1 race, with average speed recorded there
SELECT rp.point_name, COUNT(rr.result_id) AS total_entries, AVG(rr.speed_mpm) AS avg_speed
FROM release_points rp
JOIN races r ON rp.point_id = r.point_id
JOIN race_results rr ON r.race_id = rr.race_id
GROUP BY rp.point_name
HAVING COUNT(rr.result_id) > 1;
-- 7. CASE Statements
SELECT p.ring_number, rr.speed_mpm,
    CASE
        WHEN rr.speed_mpm < 1100 THEN 'Slow Flyer'
        WHEN rr.speed_mpm BETWEEN 1100 AND 1250 THEN 'Solid Flyer'
        ELSE 'Champion Flyer'
    END AS speed_category
FROM race_results rr
JOIN pigeons p ON rr.pigeon_id = p.pigeon_id;
-- 8. Subqueries
-- Results with speed above the overall average
SELECT p.ring_number, rr.speed_mpm FROM race_results rr
JOIN pigeons p ON rr.pigeon_id = p.pigeon_id
WHERE rr.speed_mpm > (SELECT AVG(speed_mpm) FROM race_results);

-- Pigeons that have never finished first
SELECT ring_number FROM pigeons
WHERE pigeon_id NOT IN (SELECT DISTINCT pigeon_id FROM race_results WHERE rank_position = 1);
-- 9. Joins (INNER, LEFT, RIGHT, SELF)
-- INNER JOIN: results with pigeon ring numbers and race names
SELECT r.race_name, p.ring_number, rr.speed_mpm, rr.rank_position
FROM race_results rr
INNER JOIN races r ON rr.race_id = r.race_id
INNER JOIN pigeons p ON rr.pigeon_id = p.pigeon_id;

-- LEFT JOIN: all pigeons, even those that never raced
SELECT p.ring_number, rr.race_id
FROM pigeons p
LEFT JOIN race_results rr ON p.pigeon_id = rr.pigeon_id;

-- RIGHT JOIN: all results even if pigeon info missing (flip of above)
SELECT p.ring_number, rr.race_id
FROM race_results rr
RIGHT JOIN pigeons p ON p.pigeon_id = rr.pigeon_id;

-- SELF JOIN: owners from the same loft location
SELECT a.name AS owner1, b.name AS owner2, a.loft_location
FROM owners a
JOIN owners b ON a.loft_location = b.loft_location AND a.owner_id < b.owner_id;
-- 10. String, Date & Conditional Functions
-- String functions
SELECT UPPER(o.name) AS owner_upper, CONCAT(p.ring_number, ' (', p.breed, ')') AS pigeon_profile
FROM pigeons p JOIN owners o ON p.owner_id = o.owner_id;

-- Date functions
SELECT race_name, race_date, DAYNAME(race_date) AS day_of_week,
       DATEDIFF(CURDATE(), race_date) AS days_since_race
FROM races;

-- Conditional functions
SELECT p.ring_number, rr.rank_position,
       IF(rr.rank_position = 1, 'Winner', 'Not First Place') AS result_status
FROM race_results rr
JOIN pigeons p ON rr.pigeon_id = p.pigeon_id;
-- 11. CTEs (Common Table Expressions)
WITH pigeon_wins AS (
    SELECT p.pigeon_id, p.ring_number, COUNT(*) AS total_wins
    FROM race_results rr
    JOIN pigeons p ON rr.pigeon_id = p.pigeon_id
    WHERE rr.rank_position = 1
    GROUP BY p.pigeon_id, p.ring_number
)
SELECT ring_number, total_wins
FROM pigeon_wins
ORDER BY total_wins DESC;
-- 12. Views
CREATE VIEW owner_performance_summary AS
SELECT o.owner_id, o.name, COUNT(rr.result_id) AS total_entries,
       SUM(CASE WHEN rr.rank_position = 1 THEN 1 ELSE 0 END) AS total_wins
FROM owners o
JOIN pigeons p ON o.owner_id = p.owner_id
LEFT JOIN race_results rr ON p.pigeon_id = rr.pigeon_id
GROUP BY o.owner_id, o.name;

SELECT * FROM owner_performance_summary;
-- 13. Window Functions
-- Rank pigeons by speed within each race
SELECT r.race_name, p.ring_number, rr.speed_mpm,
       RANK() OVER (PARTITION BY r.race_id ORDER BY rr.speed_mpm DESC) AS race_rank
FROM race_results rr
JOIN races r ON rr.race_id = r.race_id
JOIN pigeons p ON rr.pigeon_id = p.pigeon_id;

-- Running best speed for each pigeon over time
SELECT p.ring_number, r.race_date, rr.speed_mpm,
       MAX(rr.speed_mpm) OVER (PARTITION BY p.pigeon_id ORDER BY r.race_date) AS best_speed_so_far
FROM race_results rr
JOIN races r ON rr.race_id = r.race_id
JOIN pigeons p ON rr.pigeon_id = p.pigeon_id;


-- Top 3 champion pigeons by wins
SELECT p.ring_number, COUNT(*) AS total_wins
FROM race_results rr
JOIN pigeons p ON rr.pigeon_id = p.pigeon_id
WHERE rr.rank_position = 1
GROUP BY p.ring_number
ORDER BY total_wins DESC
LIMIT 3;

-- Release point with the fastest average speed
SELECT rp.point_name, AVG(rr.speed_mpm) AS avg_speed
FROM release_points rp
JOIN races r ON rp.point_id = r.point_id
JOIN race_results rr ON r.race_id = rr.race_id
GROUP BY rp.point_name
ORDER BY avg_speed DESC
LIMIT 1;

-- Owner with the best overall performance (total wins across their pigeons)
SELECT o.name, SUM(CASE WHEN rr.rank_position = 1 THEN 1 ELSE 0 END) AS total_wins
FROM owners o
JOIN pigeons p ON o.owner_id = p.owner_id
JOIN race_results rr ON p.pigeon_id = rr.pigeon_id
GROUP BY o.name
ORDER BY total_wins DESC
LIMIT 1;
