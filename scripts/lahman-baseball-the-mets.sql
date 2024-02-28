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
SELECT p.namefirst,
		p.namelast,
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
-- 		A. "Eddie"	"Gaedel"	"Edward Carl"	43	1	"St. Louis Browns"

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT DISTINCT schoolname
FROM schools