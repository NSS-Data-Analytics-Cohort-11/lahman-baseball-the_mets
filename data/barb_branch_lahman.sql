-- 1. What range of years for baseball games played does the provided database cover? 

SELECT
	MIN(yearid) as start_year,
	MAX(yearid) as end_year,
	MAX(yearid)  - MIN(yearid) as total_years
FROM teams

-- MIN YEAR: 1871
-- MAX YEAR: 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

select
	CONCAT(namefirst, ' ', namelast) AS player_name,
	namegiven,
	playerid,
	height as height_in_inches,
	teamid,
	teams.name,
	g_all as games_played
	
from people

INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid, yearid)

WHERE height = (SELECT MIN(height) from people)


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT 
	namefirst,
	namelast,
	playerid, 
	SUM(salary) AS total_salary
FROM salaries
LEFT JOIN people
USING(playerid)
WHERE playerid IN

	(SELECT distinct playerid
	from collegeplaying
	where schoolid ILIKE '%vandy%')
	
GROUP BY playerid, namefirst, namelast
ORDER BY total_salary DESC



-- SELECT 
-- 	playerid,
-- 	CONCAT(namefirst, ' ', namelast) AS player_name,
-- 	COALESCE(SUM(salary), 0) AS total_salary
-- from collegeplaying
-- INNER JOIN people
-- USING (playerid)
-- INNER JOIN salaries
-- USING (playerid)
-- where schoolid ILIKE '%Vandy%'
-- GROUP BY playerid, player_name
-- ORDER BY total_salary DESC    -- 245553888

-- SELECT SUM(salary)
-- FROM salaries
-- WHERE playerid = 'priceda01'   -- 81851296






-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- OUTFIELD... OF
-- INFIELD... SS, 1B, 2B, 3B, 
-- BATTERY... P, C

Select 
	CASE WHEN
		pos = 'OF' THEN 'OUTFIELD'
	WHEN
		pos IN ('SS', '1B', '2B', '3B') THEN 'INFIELD'
	WHEN
		pos IN ('P', 'C') THEN 'BATTERY'
	END AS POSITION, 
	SUM(po) as put_outs
from fielding 
where yearid = 2016
group by position 


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

select
	10 * (yearid/10) AS decade,
	ROUND(SUM(SO) / SUM(g)::numeric, 2) as strikeout_avg,
	ROUND(SUM(hr) / SUM(g)::numeric, 2) as homeruns_avg
from teams
where yearid >= 1920
group by decade
order by decade

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


select 
	CONCAT(namefirst, ' ', namelast) AS player_name,
	count(sb + cs) * 100 / sum(sb + cs)
	
-- 	(sb + cs / SUM(sb + cs)) *100 AS stolen_bases                             !!! NEEDS REVIEW !!!
from batting
-- where yearid = 2016
-- 	and sb >= 20
INNER JOIN people
USING (playerid)
WHERE yearid = 2016
	AND sb >= 20
group by yearid, player_name, sb, cs
-- order by stolen_bases


-- 7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
select
	yearid as year,
	name as team,
	WSWin,
	w AS wins,
	l as losses
from teams
where WSWin is not null
	and WSWin = 'N'
	and yearid BETWEEN 1970 AND 2016
order by wins desc;
-- 116 wins


-- What is the smallest number of wins for a team that did win the world series?
select 
	yearid as year,
	name as team,
	WSWin,
	w AS wins,
	l AS losses
from teams
where wswin is not null
	and wswin = 'Y'
	and yearid BETWEEN 1970 AND 2016
order by wins;
-- 63 wins


-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
-- 1981, there was a strike during this year.
	
-- Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


working on how to filter a specific date from a range.....







