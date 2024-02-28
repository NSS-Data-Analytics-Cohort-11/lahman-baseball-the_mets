-- 1. What range of years for baseball games played does the provided database cover? 

SELECT
	MIN(yearid),
	MAX(yearid)
FROM teams

-- MIN YEAR: 1871
-- MAX YEAR: 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

select
	CONCAT(namefirst, ' ', namelast) AS player_name,
-- 	namefirst,
-- 	namelast,
	namegiven,
	playerid,
	height as height_in_inches,
	teamid,
	teams.name,
	g_all as games_played
from people
--where height is not null

INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid, yearid)

WHERE height = (SELECT MIN(height) from people)

--height is not null
-- 	AND playerid = 'gaedeed01'
-- 	AND teamid = 'SLA'

--group by namefirst, namelast, namegiven, height, playerid, teamid, g_all
--order by height
--limit 1;


-- select 
-- 	playerid,
-- 	teamid,
-- 	g_all
-- from appearances
-- where playerid = 'gaedeed01';


-- SELECT distinct teamid, name
-- from teams
-- where teamid = 'SLA'


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?


select schoolid, schoolname, schoolnick
from schools
where schoolname ILIKE '%Vanderbilt%'  --Vandy


select 
	--playerid,
	--schoolid,
	DISTINCT CONCAT(namefirst, ' ', namelast) AS player_name,
	--MAX(salary) as max_salary
	COALESCE(SUM(salary), 0) AS total_salary
from collegeplaying
INNER JOIN people
USING (playerid)
LEFT JOIN salaries
USING (playerid)
where schoolid ILIKE '%Vandy%'
GROUP BY player_name
ORDER BY total_salary DESC
--OR schoolid ILIKE '%Vanderbilt%'
--GROUP BY playerid, schoolid, player_name


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- OUTFIELD... OF
-- INFIELD... SS, 1B, 2B, 3B, 
-- BATTERY... P, C

SELECT 
	playerid,
	pos,
	yearid
from fielding
where yearid = 2016

select *
from fielding


SELECT COUNT(put_outs)
FROM

(
	select 
		playerid,
		CASE WHEN
			pos IN ('OF', 'OUTFIELD') THEN 'OUTFIELD'
		WHEN
			pos IN ('SS', '1B', '2B', '3B') THEN 'INFIELD'
		WHEN
			pos IN ('P', 'C') THEN 'BATTERY'
		END AS POSITION, 
		SUM(po) as put_outs
	from fielding 
	where yearid = 2016
	group by playerid, pos
)
--group by playerid, pos











