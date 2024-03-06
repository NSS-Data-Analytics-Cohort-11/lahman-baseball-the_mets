select CONCAT(namefirst,' ',namelast) as right_handed_player_name
from people
where throws = 'R'  -- 14,480

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
	where throwing_hand = 'L'
		and batting_hand = 'L') * 100.0
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
-- limit 3

-- 1. Stan Musial
-- 2. Barry Bonds 
-- 3. Harold Baines 

//////////////////////////////////////////////////////////////////////////////////

select playerid, sum(g_all) as games_played
from appearances
where playerid = 'musiast01'
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
where playerid IN ('musiast01', 'bondsba01', 'palmera01')
group by playerid, pos
order by playerid

-- Musial: Pitcher 1 time, Outfield 19 times, First Base 14 times
-- Bonds: Outfield 22 times
-- Palmeiro: Outfield 3 times, First Base 19 times

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


select playerid, salary
from salaries
where playerid = 'bondsba01'


select playerid
from appearances
where playerid = 'bondsba01' 







