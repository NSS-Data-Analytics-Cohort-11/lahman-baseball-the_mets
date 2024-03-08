select distinct playerid
from people  --19,112 total people in the database

//////////////////////////////////////////////////////////////////////////////////

select distinct lgid
from teams   -- American Association, National Association, Union Association, American League, Players League, National League, Federal League

//////////////////////////////////////////////////////////////////////////////////


WITH team_names_and_their_leagues AS (

select name,
	CASE 
	WHEN lgid = 'AA' then 'American Association'
	WHEN lgid = 'AL' then 'American League'
	WHEN lgid = 'NA' then 'National Association'
	WHEN lgid = 'PL' then 'Players League'
	WHEN lgid = 'NL' then 'National League'
	WHEN lgid = 'UA' then 'Union Association'
	WHEN lgid = 'FL' then 'Federal League'
	END AS league
from teams
)

select yearid, name, league
from teams
inner join team_names_and_their_leagues
using (name)
group by yearid, name, league
order by yearid 

-- breaks down the team names and each league they have been associated with

//////////////////////////////////////////////////////////////////////////////////

select DISTINCT playerid, namefirst, namelast, yearid
from managers
inner join people
using (playerid)  -- 3385 managers

//////////////////////////////////////////////////////////////////////////////////

select CONCAT(namefirst,' ',namelast) as right_handed_player_name
from people
where throws = 'R'  -- 11,146
	and bats = 'R'

select CONCAT(namefirst,' ',namelast) as left_handed_player_name  
from people
where throws = 'L'
	and bats = 'L' -- 2,826
	
//////////////////////////////////////////////////////////////////////////////////
--finding the percentage of left-handed players

WITH left_handed_players AS (
	
select 
	playerid,
	CONCAT(namefirst,' ',namelast) as player_name,
	SUM(g_all) as total_games,
	throws as throwing_hand,
	bats as batting_hand
from appearances
inner join people
using (playerid)
group by playerid, player_name, throws, bats
order by total_games desc
)

select
	(select count(*)
	 from left_handed_players
	where throwing_hand = 'R'
		and batting_hand = 'R') * 100.0
	/
	(select count(*) from left_handed_players) as perc_of_lefties


-- PERCENTAGE OF LEFTIES: 14.8%

//////////////////////////////////////////////////////////////////////////////////
-- top 3 left-handed players (both throwing AND batting) who had the highest number of games played

select 
	a.lgid, 
	playerid,
	CONCAT(namefirst,' ',namelast) as player_name,
	SUM(g_all) as total_games,
	debut,
	finalgame
from appearances as a
left join people as p
using (playerid)
where throws = 'L'
	and bats = 'L'
group by a.lgid, playerid, player_name, debut, finalgame
order by total_games desc
limit 3

-- 1. Stan Musial
-- 2. Barry Bonds 
-- 3. Harold Baines 

//////////////////////////////////////////////////////////////////////////////////

select playerid, sum(g_all) as games_played
from appearances
where playerid = 'marrle01'
group by playerid    

-- how I checked my work to see if the total numbers of games was correct in my large query up top

//////////////////////////////////////////////////////////////////////////////////
-- different positions with each season

select 
	playerid,
	pos,
	COUNT(pos) as position
from fielding
inner join people
using (playerid)
where playerid IN ('bondsba01', 'ruthba01', 'griffke02')
group by playerid, pos
order by playerid

-- 1. Stan Musial: Pitcher 1 time, Outfield 19 times, First Base 14 times
-- 2. Barry Bonds: Outfield 22 times 
-- 3. Harold Baines: Outfield 15 times

//////////////////////////////////////////////////////////////////////////////////

select playerid, namefirst, namelast, debut, yearid, lgid
from people
inner join appearances
using (playerid)
where throws = 'L'
	and bats = 'L'
group by playerid, yearid, lgid
order by debut, yearid
limit 1;

-- first leftie named in the dataset is Charlie Pabor, debut at 1871


//////////////////////////////////////////////////////////////////////////////////

select 
	playerid,
	CONCAT(namefirst,' ',namelast) as player_name,
	SUM(g_all) as total_games,
	throws as throwing_hand,
	bats as batting_hand
from appearances
inner join people
using (playerid)
where bats = 'B'
	and throws = 'R'
group by playerid, player_name, throws, bats
order by total_games desc

-- throw L and bat B: 183
-- throw R and bat B: 977

//////////////////////////////////////////////////////////////////////////////////

select 
	CONCAT(namefirst,' ',namelast) as player_name,
	SUM(G_3b) as games_as_third_baseman
from appearances
inner join people
using (playerid)
where bats = 'L'                                     /*Lefty Marr - player with the most games played as L batter, L thrower*/
	and throws = 'L'
	and G_3b > 0
group by player_name
order by games_as_third_baseman desc

select *
from people
where namefirst = 'Lefty'
	and namelast = 'Marr'

select SUM(g_all)
from appearances
where playerid = 'marrle01'

//////////////////////////////////////////////////////////////////////////////////

WITH left_handers_homeruns AS (
	
select 
	playerid,
	CONCAT(namefirst,' ',namelast) as player_name,
	SUM(g_all) as total_games,
	SUM(HR) as total_homeruns
from people
inner join appearances
using (playerid)
inner join batting
using (playerid, yearid, teamid)
	where bats = 'L'
	and throws = 'L'
	and yearid >= 1970
	and namefirst = 'tris'
group by playerid, player_name
order by total_homeruns desc
-- limit 3
)

SELECT SUM(total_homeruns)
from people
inner join left_handers_homeruns
using (playerid)
where bats = 'L'
	and throws = 'L' 


select teamid, yearid, playerid, namefirst, namelast, debut, finalgame, name, deathyear
from people
inner join appearances
using (playerid)
inner join teams
using (teamid, yearid)
where playerid = 'bondsba01'
order by yearid


select teamid
from people
