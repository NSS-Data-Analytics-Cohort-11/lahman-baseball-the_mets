-- QUESTION 1: What range of years for baseball games played does the provided database cover?

SELECT MIN(year) AS min_year,
MAX(year) AS max_year
FROM homegames;

-- ANSWER: From 1871 to 2016

-- QUESTION 2: Find the name and height of the shortest player in the database. 
-- How many games did he play in? 
-- What is the name of the team for which he played?

SELECT namegiven, height, g_all, name
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid, yearid)
WHERE people.height = (SELECT MIN(height) FROM people);

-- ANSWER: Edward Carl, played in 1 game for the St. Louis Browns

-- QUESTION 3: Find all players in the database who played at Vanderbilt University. 
-- Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
-- Sort this list in descending order by the total salary earned. 
-- Which Vanderbilt player earned the most money in the majors?

SELECT namefirst, namelast, playerid, SUM(salary) AS total_salary
FROM salaries
LEFT JOIN people
USING (playerid)
WHERE playerid IN
	(SELECT DISTINCT playerid
		FROM collegeplaying
		WHERE schoolid = 'vandy')
	GROUP BY namefirst, namelast, playerid
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

-- QUESTION 5: Find the average number of strikeouts per game by decade since 1920. 
-- Round the numbers you report to 2 decimal places. 
-- Do the same for home runs per game. Do you see any trends?

SELECT 10 * FLOOR(yearid/10) AS decade, 
ROUND(SUM(so)/ SUM(g)::numeric,2) AS avg_so_per_year,
ROUND(SUM(hr)/ SUM(g)::numeric,2) AS avg_hr_per_year
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

-- ANSWER: See queries above...average stikeouts and home runs seem to be increasing as the decades increase

-- QUESTION 6: Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. 
-- (A stolen base attempt results either in a stolen base or being caught stealing.) 
-- Consider only players who attempted at least 20 stolen bases.

SELECT namefirst, namelast, SUM(sb)/(SUM(sb)+SUM(cs))::numeric * 100 AS success_sb
FROM batting
INNER JOIN people
USING (playerid)
WHERE yearid = '2016'
GROUP BY namefirst, namelast
HAVING (SUM(sb)+SUM(cs)) >= 20
ORDER BY success_sb DESC
LIMIT 1;

-- ANSWER: Chris Owings 91.3%

-- QUESTION 7a: From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
-- What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
-- Then redo your query, excluding the problem year.

(SELECT name, yearid, w, wswin
FROM teams
WHERE yearid >= '1970' AND wswin = 'N'
GROUP BY name, yearid, w, wswin
ORDER BY w DESC
LIMIT 1)
UNION
(SELECT name, yearid, w, wswin
FROM teams
WHERE yearid >= '1970' AND wswin = 'Y' AND yearid <> '1981'
GROUP BY name, yearid, w, wswin
ORDER BY w ASC
LIMIT 1)

/*ANSWER: largest # of wins without a world series was the Seattle Mariners with 116 wins and
the team with lowest # of wins was the Los Anegels Dodgers in 1981 with 63 wins but that data
is misleading due to a players strike that year which shortened the season. The St. Louis Cardinals 
won the world series in 2006 with 83 wins which is the lowest number of wins for a team to win the world series 
in a full season.*/

/*QUESTION 7b. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?*/

WITH wins AS (
	SELECT 
		yearid AS year,
		name AS team,
		w AS num_wins,
		wswin,
		CASE WHEN w = MAX(w) OVER(PARTITION BY yearid) AND wswin = 'Y' THEN 1 ELSE 0 END AS most_wins_and_ws
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	ORDER BY year
)
SELECT 
	SUM(most_wins_and_ws) AS how_often,
	ROUND(SUM(most_wins_and_ws) / COUNT(DISTINCT year)::numeric * 100, 2) AS perc_of_years
FROM wins

-- ANSWER: 12 times (25.53%)

/*QUESTION 8: Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

SELECT *
FROM homegames;

SELECT team, park, attendance / games AS avg_attendance
FROM homegames
WHERE year = '2016' AND games > 10
ORDER BY avg_attendance DESC
LIMIT 5;























