-- Fix formatting in table

INSERT OVERWRITE TABLE new_york_migration SELECT
	state_code_a , fip_county_code_a , mcd_code_a , state_code_b , fip_county_code_b , mcd_code_b , 
	state_name_a , county_name_a , mcd_a , state_name_b , county_name_b , mcd_b , REGEXP_REPLACE(flow_b_to_a_est,'[",]','') AS flow_b_to_a_est,
	flow_b_to_a_moe , REGEXP_REPLACE(counterflow_a_to_b_est,'[,"]','') AS counterflow_a_to_b_est, counterflow_a_to_b_moe , REGEXP_REPLACE(net_b_to_a_est,'[",]','') AS net_b_to_a_est , 
	net_b_to_a_moe , gross_btw_a_b_est , gross_btw_a_b_moe
	FROM new_york_migration;

-- Make empty spaces NULL
ALTER TABLE new_york_migration SET TBLPROPERTIES('serialization.null.format' = '');


-- mcd codes for the five boroughs: The Bronx 8510, Brooklyn 10022, Manhattan 44919, Queens 60323, Staten Island 70915

-- RANKING BOROUGHS BY INMIGRATION (AGGREGATE)
SELECT mcd_a,SUM(CAST(flow_b_to_a_est AS NUMERIC)) as flow FROM new_york_migration 
	WHERE mcd_code_a IN ('8510','10022','44919','60323','70915')
	GROUP BY mcd_a ORDER BY flow DESC;

-- RANKING BOROUGHS BY OUTMIGRATION (AGGREGATE)
SELECT mcd_a,SUM(CAST(counterflow_a_to_b_est AS NUMERIC)) as counter_flow FROM new_york_migration 
	WHERE mcd_code_a IN ('8510','10022','44919','60323','70915')
	GROUP BY mcd_a ORDER BY counter_flow DESC;
	
-- MOST MIGRATED FROM STATE TO NYC BOROUGH
SELECT state_name_b, SUM(CAST(flow_b_to_a_est AS NUMERIC)) AS state_flow FROM new_york_migration 
	WHERE state_name_b NOT IN ('New York','U.S. Island Areas','Caribbean','Asia','Africa','Oceania and At Sea','South America','Europe','Central America','Northern America')
	GROUP BY state_name_b ORDER BY state_flow DESC;
	
-- TOP 3 MOST MIGRATED FROM STATE TO NYC BOROUGH (PER BOROUGH)
WITH from_state AS(
SELECT DISTINCT state_name_b, mcd_a, SUM(CAST(flow_b_to_a_est AS NUMERIC)) OVER(PARTITION BY state_name_b,mcd_a) AS state_flow FROM new_york_migration 
	WHERE state_name_b NOT IN ('New York','U.S. Island Areas','Caribbean','Asia','Africa','Puerto Rico'
													 'Oceania and At Sea','South America','Europe','Central America','Northern America')
	AND mcd_code_a IN ('8510','10022','44919','60323','70915')),
	from_state2 AS(
	SELECT state_name_b,mcd_a,state_flow,ROW_NUMBER() OVER(PARTITION BY mcd_a ORDER BY state_flow DESC) AS row_num 
	FROM from_state) 
	SELECT state_name_b,mcd_a,state_flow FROM from_state2
	WHERE from_state2.row_num <= 3
	ORDER BY mcd_a,state_flow DESC;

-- MOST MIGRATED (OUTMIGRATION) TO STATE PER NYC BOROUGH
WITH out_migration AS(
SELECT DISTINCT state_name_b,mcd_a,
	SUM(CAST(counterflow_a_to_b_est AS NUMERIC)) OVER(PARTITION BY state_name_b,mcd_a) AS max_m 
	FROM new_york_migration
	WHERE mcd_code_a IN ('8510','10022','44919','60323','70915') AND
    state_name_b NOT IN ('New York','U.S. Island Areas','Caribbean','Asia','Africa','Oceania and At Sea',
						 'South America','Europe','Central America','Northern America')
	), out_migration2 AS 
	(SELECT DISTINCT mcd_a,MAX(max_m) OVER(PARTITION BY mcd_a) AS max_m FROM out_migration)
	SELECT out_migration2.mcd_a,out_migration.state_name_b,out_migration2.max_m AS migration FROM out_migration2 
	JOIN out_migration ON out_migration.mcd_a = out_migration2.mcd_a AND out_migration.max_m = out_migration2.max_m
	ORDER BY migration DESC;

-- MOST MIGRATED FROM NYC BOROUGH TO OTHER NYC BOROUGH
SELECT mcd_a AS from_borough,mcd_b AS to_borough,CAST(counterflow_a_to_b_est AS NUMERIC) AS outmigration FROM new_york_migration
	WHERE mcd_code_a IN ('8510','10022','44919','60323','70915') AND
	mcd_code_b IN ('8510','10022','44919','60323','70915')
	ORDER BY outmigration DESC LIMIT 100;

