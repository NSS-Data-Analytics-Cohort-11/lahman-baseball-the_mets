-- QUESTION 1: What range of years for baseball games played does the provided database cover?

SELECT MIN(year) AS min_year,
MAX(year) AS max_year
FROM homegames;

-- ANSWER: From 1871 to 2016

-- QUESTION 2: Find the name and height of the shortest player in the database. 
-- How many games did he play in? 
-- What is the name of the team for which he played?

SELECT *
FROM people;

SELECT *
FROM appearances;

SELECT *
FROM teams;

SELECT namegiven, height, g_all, name
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid, yearid)
WHERE people.height = (SELECT MIN(height) FROM people)
ORDER BY height;

-- ANSWER: Edward Carl, played in 1 game for the St. Louis Browns

-- QUESTION 3: Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
-- Sort this list in descending order by the total salary earned. 
-- Which Vanderbilt player earned the most money in the majors?

SELECT COUNT(schoolid)
FROM schools
WHERE schoolid LIKE 'vandy';

SELECT namefirst, namelast, COALESCE(SUM(salary), 0) AS total_salary
FROM people
LEFT JOIN salaries
USING (playerid)
INNER JOIN collegeplaying
USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;

-- ANSWER: David Price

-- QUESTION 4: Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-- Determine the number of putouts made by each of these three groups in 2016.

SELECT 
CASE
WHEN pos IN ('1B', '2B', 'SS', '3B') THEN 'Infield'
WHEN pos = 'OF' THEN 'Outfield'
WHEN pos IN ('P', 'C') THEN 'Battery'
END AS position,
SUM(po)
FROM fielding
WHERE yearid = '2016'
GROUP BY position;

-- ANSWER: Battery = 41424, Infield = 58934, Outfield = 29560










