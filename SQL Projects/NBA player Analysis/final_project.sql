-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT * FROM players;
SELECT * FROM salaries;
SELECT * FROM school_details;
SELECT * FROM schools;
-- 2. In each decade, how many schools were there that produced players?
SELECT  
        FLOOR((yearID)/10) * 10 as decade,
        COUNT(DISTINCT schoolID) as sch_count    
FROM schools
GROUP BY FLOOR((yearID)/10) * 10
ORDER BY FLOOR((yearID)/10) * 10;



-- 3. What are the names of the top 5 schools that produced the most players?
SELECT TOP 5
        --sd.schoolID,
        sd.name_full,
        COUNT(DISTINCT s.playerID) as player_cnt
        
FROM    school_details sd LEFT JOIN schools s
        ON sd.schoolID = s.schoolID
GROUP BY sd.name_full
ORDER BY COUNT(DISTINCT s.playerID) dESC

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
 WITH de AS (SELECT                     
                    FLOOR((s.yearID)/10) * 10 as decade,
                    sd.name_full,
                    COUNT(DISTINCT s.playerID) as player_cnt
                    
            FROM    schools s LEFT JOIN school_details sd
                    ON sd.schoolID = s.schoolID
            GROUP BY FLOOR((s.yearID)/10) * 10, sd.name_full
            ),

    rn AS   (SELECT decade, player_cnt,  name_full, 
                    ROW_NUMBER() OVER(PARTITION BY decade ORDER BY player_cnt DESC) as row_num
            FROM de
            WHERE decade IS NOT NULL)

SELECT decade, name_full, player_cnt FROM rn
WHERE row_num < 4
ORDER BY decade DESC, row_num




-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT * FROM players;
SELECT * FROM salaries;
SELECT * FROM school_details;
SELECT * FROM schools;
-- 2. Return the top 20% of teams in terms of average annual spending


WITH ts AS (
    SELECT  teamID,
            yearID,
            SUM(CAST(SALARY AS decimal(18,0))) AS total_salary          
    FROM salaries
    GROUP BY teamID, yearID
),
avg_s AS (
    SELECT   teamID, AVG(total_salary) AS average_salary,
            NTILE(5) OVER( ORDER BY AVG(total_salary) DESC) AS ave_spend_per
    FROM ts
    GROUP BY teamID)
    
SELECT  teamID, ROUND(average_salary/1000000,2) AS avg_spend_per_million
FROM avg_s
WHERE ave_spend_per =1;

-- 3. For each team, show the cumulative sum of spending over the years
WITH cs AS (
    SELECT  teamID,
                yearID,
                SUM(CAST(SALARY AS decimal(18,0))) AS total_salary          
        FROM salaries
        GROUP BY teamID, yearID
)

SELECT  teamID, yearID,
        ROUND(SUM(total_salary) OVER (PARTITION BY teamID ORDER BY yearID)/1000000,1) AS cumulative_sum_millions
FROM cs

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH cs AS (
    SELECT  teamID,
                yearID,
                SUM(CAST(SALARY AS decimal(18,0))) AS total_salary          
        FROM salaries
        GROUP BY teamID, yearID
    ),
    csm AS (
    SELECT  teamID, yearID,
            ROUND(SUM(total_salary) OVER (PARTITION BY teamID ORDER BY yearID)/1000000,1) AS cumulative_sum_millions
    FROM cs
    ),
    dr AS (
    SELECT  teamID, yearID, cumulative_sum_millions,
            DENSE_RANK() OVER(PARTITION BY teamID ORDER BY cumulative_sum_millions) AS rank_cum       
    FROM csm 
    WHERE cumulative_sum_millions >= 1000
    ) 
SELECT teamID, yearID, cumulative_sum_millions 
FROM dr
WHERE rank_cum = 1

-- PART III: PLAYER CAREER ANALYSIS

-- 1. View the players table and find the number of players in the table
SELECT * FROM players;
SELECT COUNT(playerID) AS player_cnt
FROM players;
-- SELECT * FROM salaries;
-- SELECT * FROM school_details;
-- SELECT * FROM schools;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
SELECT  nameGiven,
        DATEDIFF(year,DATEFROMPARTS(birthYear,birthMonth,birthDay), debut) AS age_first_game,
        DATEDIFF(year,DATEFROMPARTS(birthYear,birthMonth,birthDay), finalGame) AS age_last_game,
        DATEDIFF(year,debut, finalGame) AS career_lgth
FROM players
ORDER BY career_lgth DESC 


-- 3. What team did each player play on for their starting and ending years?
SELECT  p.nameGiven, 
        s.yearID AS starting_year, s.teamID AS starting_team, 
        e.yearID AS ending_year, e.teamID AS ending_team
FROM    players p INNER JOIN salaries s
                    ON p.playerID = s.playerID 
                    AND DATEPART(year,p.debut) = s.yearID
                 INNER JOIN salaries e
                    ON p.playerID = e.playerID
                    AND DATEPART(year,p.finalGame) = e.yearID    
;


-- 4. How many players started and ended on the same team and also played for over a decade?
SELECT  p.nameGiven, 
        s.yearID AS starting_year, s.teamID AS starting_team, 
        e.yearID AS ending_year, e.teamID AS ending_team
FROM    players p INNER JOIN salaries s
                    ON p.playerID = s.playerID 
                    AND DATEPART(year,p.debut) = s.yearID
                 INNER JOIN salaries e
                    ON p.playerID = e.playerID
                    AND DATEPART(year,p.finalGame) = e.yearID    

WHERE   s.teamID = e.teamID AND e.yearID - s.yearID > 10
;

-- PART IV: PLAYER COMPARISON ANALYSIS

-- 1. View the players table
SELECT * FROM players;

-- 2. Which players have the same birthday?

SELECT 
    STRING_AGG(nameGiven, ', ') AS players_with_same_birthday,
    DATEFROMPARTS(birthYear,birthMonth,birthDay) As birthday 
   
    
FROM 
    players
WHERE birthDay IS NOT NULL AND birthMonth IS NOT NULL                                       
GROUP BY 
     DATEFROMPARTS(birthYear,birthMonth,birthDay)
    
HAVING 
    COUNT(*) > 1;


-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
SELECT  s.teamID, --p.bats,
        ROUND(COUNT(CASE WHEN p.bats = 'R' THEN 1 END) * 100.0 / COUNT(p.playerID), 1) AS player_right,
        ROUND(COUNT(CASE WHEN p.bats = 'L' THEN 1 END) * 100.0 / COUNT(p.playerID), 1) AS player_left,
        ROUND(COUNT(CASE WHEN p.bats = 'B' THEN 1 END) * 100.0 / COUNT(p.playerID), 1) AS player_both       
       
FROM    players p INNER JOIN salaries s
                    ON p.playerID = s.playerID
GROUP BY  s.teamID;


-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
WITH dy AS (
        SELECT  FLOOR(DATEPART(Year, debut)/10) * 10 as decade,
                AVG(weight) AS avg_weight, 
                AVG(height) AS avg_height     
        FROM players
        GROUP BY FLOOR(DATEPART(Year, debut)/10) * 10
        --ORDER BY FLOOR(DATEPART(Year, debut)/10) * 10
        )
        
SELECT  decade,
        avg_weight - LAG(avg_weight) OVER(ORDER BY decade)/1.00 AS weight_diff,
        avg_height - LAG(avg_height) OVER(ORDER BY decade)/1.00 AS height_diff  
FROM dy
WHERE decade IS NOT NULL;