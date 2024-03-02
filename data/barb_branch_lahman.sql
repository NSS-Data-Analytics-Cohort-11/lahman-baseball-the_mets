-- 1. What range of years for baseball games played does the provided database cover? 

SELECT
	MIN(yearid) as start_year,
	MAX(yearid) as end_year,
	MAX(yearid)  - MIN(yearid) as total_years
FROM teams

-- MIN YEAR: 1871
-- MAX YEAR: 2016

************************************************************************************************

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

************************************************************************************************

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

************************************************************************************************

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

************************************************************************************************

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

select
	10 * (yearid/10) AS decade,
	ROUND(SUM(SO) / SUM(g)::numeric, 2) as strikeout_avg,
	ROUND(SUM(hr) / SUM(g)::numeric, 2) as homeruns_avg
from teams
where yearid >= 1920
group by decade
order by decade

************************************************************************************************

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.  !!! GOOD TO GO :)


select 
	CONCAT(namefirst, ' ', namelast) AS player_name,
	sb,
	(sb + cs) as attempts,
	sb * 100 / (sb + cs) as sb_pct                          
from batting
INNER JOIN people
USING (playerid)
WHERE yearid = 2016
	AND (sb + cs) >= 20
group by yearid, player_name, sb, cs
order by sb_pct desc

************************************************************************************************

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
-- 116 wins, Seattle Mariners


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
-- 63 wins, Los Angeles Dodgers


-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
-- 1981, there was a baseball strike during this year.
	
-- Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

WITH teams_1970_2016 AS

(
select
	yearid as year,
	name as team,
	WSWin as world_series_winner,
	MAX(w) AS wins,                                                             -- !!! ALMOST DONE, NEED TO FINALIZE THE END OF THE QUESTION !!! --
	l as losses
from teams
where WSWin is not null
	and WSWin = 'N'
	and yearid BETWEEN 1970 AND 2016
group by year, team, world_series_winner, losses
	
UNION ALL

select 
	yearid as year,
	name as team,
	WSWin as world_series_winner,
	MAX(w) AS wins,
	l AS losses
from teams
where wswin is not null
	and wswin = 'Y'
	and yearid BETWEEN 1970 AND 2016
group by year, team, world_series_winner, losses
)


SELECT 
	year,
	team,
	world_series_winner,
	wins
FROM teams_1970_2016
WHERE year <> 1981
ORDER BY wins DESC;

************************************************************************************************

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

(
SELECT 
	park_name,
	t.name,
	hg.attendance / hg.games
	--SUM(hg.attendance) / SUM(hg.games) AS avg_attendance_per_game
FROM parks as p
INNER JOIN homegames as hg
USING (park)
INNER JOIN teams as t
USING (park)
                                             /* UPDATE... */

WHERE yearid = 2016
	AND games >= 10
GROUP BY t.name, hg.park
ORDER BY avg_attendance_per_game desc
LIMIT 5
)
	
UNION ALL

(
SELECT 
	park_name,
	t.name,
	hg.attendance / hg.games
	--SUM(hg.attendance) / SUM(hg.games) AS avg_attendance_per_game
	
FROM homegames as hg
INNER JOIN teams as t
ON hg.team = t.teamid

WHERE yearid = 2016
	AND games >= 10
GROUP BY t.name, hg.park
ORDER BY avg_attendance_per_game
LIMIT 5
)

************************************************************************************************

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT
	t.yearid,
	CONCAT(p.namefirst, ' ', p.namelast) AS manager_name,
	am.awardid,
	t.name

FROM people as p
JOIN awardsmanagers as am
USING (playerid)
JOIN managers as m
ON am.playerid = m.playerid AND am.yearid = m.yearid
JOIN teams as t
ON m.yearid = t.yearid AND m.teamid = t.teamid

	

WHERE awardid = 'TSN Manager of the Year'
	and p.playerid IN (select playerid from awardsmanagers where awardid = 'TSN Manager of the Year' and lgid = 'NL')
	and p.playerid IN (select playerid from awardsmanagers where awardid = 'TSN Manager of the Year' and lgid = 'AL')

ORDER BY manager_name

************************************************************************************************

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- all players in 2016 with their total of homeruns
SELECT 
	playerid,
	CONCAT(namefirst, ' ', namelast) AS player_name,
	SUM(hr) as total_homeruns
from batting
INNER JOIN people
using(playerid)
where yearid = 2016
	and hr > 0
group by playerid, player_name
order by total_homeruns desc
 



--Jessica's Code
SELECT
    p.namefirst || ' ' || p.namelast AS player_name,
    b.hr AS home_runs_2016
FROM batting AS b
INNER JOIN people AS p ON b.playerID = p.playerid
WHERE b.yearid = 2016
	AND hr > 0
	AND EXTRACT(YEAR FROM debut::date) <= 2016 - 9
    AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid)
ORDER BY home_runs_2016 DESC;


--Derek's code
WITH highest_2016 AS
				/* return playerid and number of home runs if max was in 2016 */
			(SELECT  playerid,
						/* return hr when 2016 AND player hit their max hr */
						CASE WHEN hr = MAX(hr) OVER (PARTITION BY playerid) AND yearid = 2016 THEN hr
								END AS career_highest_2016
				FROM batting
				GROUP BY playerid, hr, yearid
				ORDER BY playerid)

SELECT  p.namefirst || ' ' || p.namelast AS name,
		h.career_highest_2016 AS num_hr
FROM highest_2016 AS h
LEFT JOIN people AS p
	ON h.playerid = p.playerid
WHERE h.career_highest_2016 IS NOT NULL
	AND h.career_highest_2016 > 0
	AND DATE_PART('year', p.debut::DATE) <= 2007
ORDER BY num_hr DESC;




















