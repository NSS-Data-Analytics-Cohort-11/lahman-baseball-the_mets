SELECT * FROM allstarfull

-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year) AS start_year,
		MAX(year) AS end_year
FROM homegames
-- 		A. 1871-2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT CONCAT(p.namefirst, ' ', p.namelast) AS full_name,
		p.namegiven,
		p.height,
		a.g_all
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
WHERE height = (SELECT MIN(height::INTEGER)
				FROM people);
-- 			A. "Eddie Gaedel"	"Edward Carl"	43	1

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

SELECT p.namefirst || ' ' || p.namelast AS full_name, SUM(s.salary) AS total_salary
FROM salaries AS s
INNER JOIN people AS p
ON s.playerid = p.playerid
WHERE s.playerid IN 
				(SELECT DISTINCT playerid
				FROM collegeplaying
				WHERE schoolid = 'vandy')
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC;
-- 			A. "David Price"	81851296

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
			  
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT 10 * FLOOR(yearid/10) AS decade,
		ROUND(SUM(so) / SUM(g)::NUMERIC, 2) AS avg_so_game,
		ROUND(SUM(hr) / SUM(g)::NUMERIC, 2) AS avg_hr_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
-- 		A. Both strikeouts and home runs are increasing over the decades.

-- SELECT 10 * FLOOR(yearid/10) AS decade,
-- ROUND(SUM(soa) / SUM(g)::NUMERIC, 2) AS avg_soa_game,
-- ROUND(SUM(hra) / SUM(g)::NUMERIC, 2) AS avg_hra_game
-- FROM teams
-- WHERE yearid >= 1920
-- GROUP BY decade
-- ORDER BY decade

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT p.namefirst || ' ' || p.namelast AS name,
		ROUND(SUM(b.sb) / (SUM(b.sb) + SUM(b.cs))::NUMERIC * 100, 2) || '%' AS percent_successful
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE b.yearid = 2016
GROUP BY b.playerid, p.namefirst, p.namelast
HAVING (SUM(b.sb) + SUM(b.cs)) >= 20
ORDER BY percent_successful DESC
LIMIT 1;

-- 7.A.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 
	(SELECT name,
	 		MAX(w) AS team_with_most_wins,
	 		'most wins | lost WS' AS label
	FROM teams
	WHERE yearid >= 1970
		AND wswin = 'N'
	GROUP BY name
	ORDER BY team_with_most_wins DESC
	LIMIT 1)

UNION

	(SELECT name,
	 		MIN(w) AS team_with_most_wins,
	 		'least wins | won WS | on strike' AS label
	FROM teams
	WHERE yearid >= 1970
		AND wswin = 'Y'
	GROUP BY name
	ORDER BY team_with_most_wins
	LIMIT 1)

UNION

	(SELECT name,
	 		MIN(w) AS team_with_most_wins,
	 		'least wins | won WS | not on strike' AS label
	FROM teams
	WHERE yearid >= 1970
		AND yearid <> 1981
		AND wswin = 'Y'
	GROUP BY name
	ORDER BY team_with_most_wins
	LIMIT 1);
/*		"Seattle Mariners"	116	"most wins | lost WS"
		"St. Louis Cardinals"	83	"least wins | won WS | not on strike"
		"Los Angeles Dodgers"	63	"least wins | won WS | on strike"	
		In 1981 the MLB went on strike*/  

-- 7.B. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
WITH wins_and_ws AS
					(SELECT yearid,
							CASE WHEN wswin = 'Y' AND w = MAX(w) OVER(PARTITION BY yearid) THEN 1
								ELSE 0 END AS winner_and_highest
					FROM teams
					WHERE yearid >= 1970)

SELECT SUM(winner_and_highest) AS num_occurances,
		ROUND(SUM(winner_and_highest) / COUNT(DISTINCT yearid)::NUMERIC * 100, 2) || '%' AS percent_occured
FROM wins_and_ws;
		

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.





