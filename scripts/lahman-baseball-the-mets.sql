SELECT * FROM allstarfull

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year) AS start_year,
		MAX(year) AS end_year
FROM homegames
-- 		A. 1871-2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- height 43in
SELECT MIN(height::INTEGER)
FROM people

SELECT namefirst,
		namelast,
		namegiven,
		height
FROM people
WHERE height = (SELECT MIN(height::INTEGER)
				FROM people)
-- 			A. "Eddie"	"Gaedel"	"Edward Carl"	43in

SELECT g_all
FROM appearances
WHERE playerid = (SELECT playerid
					FROM people
					WHERE height = (SELECT MIN(height::INTEGER)
					FROM people))
-- 			A. 1 game

/* ***** Final Query ***** */
SELECT CONCAT(p.namefirst, ' ', p.namelast) AS player_name,
		p.namegiven,
		p.height,
		a.g_all,
		t.name
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON a.teamid = t.teamid AND a.yearid = t.yearid
WHERE p.height = (SELECT MIN(height::INTEGER)
				FROM people)
-- 		A. "Eddie Gaedel"	"Edward Carl"	43	1	"St. Louis Browns"

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT schoolid
FROM schools
WHERE schoolname ILIKE '%vanderbilt%'
-- 		A. "vandy"

SELECT COUNT(DISTINCT p.playerid)
FROM people AS p
INNER JOIN collegeplaying AS c
ON p.playerid = c.playerid
WHERE c.schoolid = 'vandy'
-- 24 different players at Vandy

SELECT CONCAT(p.namefirst, ' ', p.namelast) AS player_name,
		SUM(COALESCE(s.salary, 0)) AS total_salary
FROM people AS p
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
INNER JOIN collegeplaying AS c
ON p.playerid = c.playerid
WHERE c.schoolid = 'vandy'
GROUP BY CONCAT(p.namefirst, ' ', p.namelast)
ORDER BY total_salary DESC;
-- 		A. "David Price"	245553888

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('1B', '2B', '3B', 'SS') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery'
			ELSE 'Other' END AS position,
			SUM(po)
FROM fielding
WHERE yearid = '2016'
GROUP BY position;
 		/* A. "Battery"	41424
 			  "Infield"	58934
			  "Outfield"29560 */
