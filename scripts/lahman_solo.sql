Solo exploration ideas:
Correlation between salary and performance (scatterplot, avg salary for each quartile of wins, hypothesis test...) Would need to account for mid-season trades? Is this reflected in tables?
SELECT * FROM salaries ORDER BY playerid, teamid

SELECT
	yearid,
	teamid,
	AVG(salary),
	AVG(w)
FROM teams
INNER JOIN salaries
USING(yearid, teamid)
GROUP BY yearid, teamid
ORDER BY yearid, teamid

--correlation wins and salary
SELECT corr(t.W, s.salary) AS correlation_wins_salary
FROM teams t
JOIN salaries s ON t.teamid = s.teamid AND t.yearid = s.yearid
WHERE t.w IS NOT NULL
    AND s.salary IS NOT NULL
	
--quartiles with avg salary	
WITH team_quartiles AS (
    SELECT teams.teamid,
        teams.yearid,
        w,
        salary,
        NTILE(4) OVER (ORDER BY W) AS win_quartile
    FROM teams
    JOIN salaries ON Teams.teamid = aalaries.teamid AND teams.yearid = salaries.yearid
    WHERE teams.w IS NOT NULL
        AND salaries.salary IS NOT NULL AND teams.yearid BETWEEN 2000 AND 2016
)

SELECT win_quartile,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
FROM team_quartiles
GROUP BY win_quartile
ORDER BY win_quartile;

--OR moneyball effect
--Boston Red Sox - team was purchased in 2002 and Bill James hired to use sabermetrics
--Oakland was doing really well in 80s, got bad after budget cuts, and used analytics to improve 90s/2000s

SELECT yearid, w
FROM teams
WHERE name ILIKE '%Oakland%'
ORDER BY yearid DESC

-- Identify the teams that were early adopters of Moneyball metrics during the specified era.
-- Calculate the average values of key Moneyball metrics (OBP, SLG, OPS) for these teams over time.
SELECT
    yearid,
    AVG((h + bb + hbp)::numeric / (ab + bb + hbp + sf)) AS avg_obp,
    AVG((h + h2b + (2 * h3b) + (3 * hr))::numeric / ab) AS avg_slg,
    AVG((h + bb + hbp)::numeric / (ab + bb + hbp + sf) + (h + 2 * h2b + 3 * h3b + 4 * hr)::numeric / ab) AS avg_ops
FROM teams
--WHERE teamID IN ('Replace with Moneyball teams')
GROUP BY yearID
ORDER BY yearID;

--looking at early adopters

SELECT
    name,
	MIN(yearid),
    AVG((h + bb + hbp)::numeric / (ab + bb + hbp + sf)) AS avg_obp,
    AVG((h + h2b + (2 * h3b) + (3 * hr))::numeric / ab) AS avg_slg,
    AVG((h + bb + hbp)::numeric / (ab + bb + hbp + sf) + (h + 2 * h2b + 3 * h3b + 4 * hr)::numeric / ab) AS avg_ops
FROM teams
GROUP BY name
HAVING AVG((h + bb + hbp)::numeric / (ab + bb + hbp + sf)) IS NOT NULL
	AND AVG((h + bb + hbp)::numeric / (ab + bb + hbp + sf) + (h + 2 * h2b + 3 * h3b + 4 * hr)::numeric / ab) IS NOT NULL
ORDER BY  MIN(yearid);

--hall of famers

SELECT * FROM halloffame WHERE inducted = 'Y'

--player age and performance

WITH player_stats AS (
    SELECT
        playerid,
        MAX(yearid) - birthyear AS age,
        AVG(h) AS avg_h,
        AVG(ab) AS avg_ab,
        AVG(bb) AS avg_bb,
        AVG(hbp) AS avg_hbp,
        AVG(sf) AS avg_sf,
        AVG(h2b) AS avg_h2b,
        AVG(h3b) AS avg_h3b,
        AVG(hr) AS avg_hr
    FROM
        batting
    INNER JOIN people USING(playerid)
    WHERE
        ab > 100  -- Consider players with at least 100 at-bats
    GROUP BY
        playerid, birthyear
)
SELECT
    age AS age_group,
    ROUND(COALESCE(AVG(avg_h / NULLIF(avg_ab, 0)), 0)::NUMERIC, 3) AS avg_BattingAverage,
    ROUND(COALESCE(AVG((avg_h + avg_Bb + avg_hbp) / NULLIF(avg_ab + avg_bb + avg_hbp + avg_sf, 0)), 0)::NUMERIC, 3) AS avg_obp,
    ROUND(COALESCE(AVG((avg_h + avg_h2b + (2 * avg_h3B) + (3 * avg_hr)) / NULLIF(avg_ab, 0)), 0)::NUMERIC, 3) AS avg_slg,
    ROUND(COALESCE(AVG(((avg_h + avg_bb + avg_hbp) / NULLIF(avg_ab + avg_bb + avg_hbp + avg_sf, 0)) + ((avg_h + 2 * avg_h2b + 3 * avg_h3b + 4 * avg_hr) / NULLIF(avg_ab, 0))), 0)::NUMERIC, 3) AS avg_ops
FROM
    player_stats
GROUP BY
    age_group
ORDER BY
    age_group;
