-- Fix formatting issues 
INSERT OVERWRITE TABLE county_to_county SELECT
	location_code , REPLACE(current_state,'District of Columb','District of Columbia') AS current_state, REPLACE(current_county,'[ia	]','') AS current_county, 
	pop_1y_over_est , pop_1y_over_moe , current_county_nonmovers_est , current_county_nonmovers_moe , 
	movers_within_current_county_est , movers_within_current_county_moe , movers_within_same_county_est , movers_within_same_county_moe , 
	REGEXP_REPLACE(movers_dif_county_same_state_est,'[ ,]','0') AS movers_dif_county_same_state_est, movers_dif_county_same_state_moe , REGEXP_REPLACE(movers_dif_state_current_county_est,'[.]','0') AS movers_dif_state_current_county_est , 
	movers_dif_state_current_county_moe , movers_from_abroad_est , movers_from_abroad_moe , prev_state_name , 
	prev_county_name , prev_pop_1y_ago_est , prev_pop_1y_ago_moe , prev_county_nonmovers_est , prev_county_nonmovers_moe , prev_movers_within_us_est , 
	prev_movers_within_us_moe , REGEXP_REPLACE(prev_movers_within_same_county_est,'[.,]','0') AS prev_movers_within_same_county_est , prev_movers_within_same_county_moe , prev_movers_dif_county_same_state_est , prev_movers_dif_county_same_state_moe , prev_movers_dif_state_est , prev_movers_dif_state_moe , pr_est , pr_moe , movers_within_flow_est , movers_within_flow_moe
	FROM county_to_county;

-- Alter to make empty strings NULL
ALTER TABLE county_to_county SET TBLPROPERTIES('serialization.null.format' = '');

-- Change certain columns to be NUMERIC for calculations
ALTER TABLE county_to_county CHANGE movers_dif_county_same_state_est movers_dif_county_same_state_est NUMERIC;

-- FIND COUNTY WITH MOST INNER COUNTY MOVING ONLY USING CURRENT STATE COLUMNS
WITH tbl1 AS (
	SELECT current_county,current_state,movers_within_current_county_est  FROM county_to_county),
	tbl2 AS (SELECT DISTINCT * FROM tbl1) SELECT * FROM tbl2 
	ORDER BY CAST(REGEXP_REPLACE(movers_within_current_county_est,'','0') AS NUMERIC) DESC LIMIT 50;	
	
-- FIND STATE WITH MOST INNER COUNTY MOVING IN SAME STATE
WITH tbl1 AS (
	SELECT current_state,current_county,movers_dif_county_same_state_est FROM county_to_county),
	tbl2 AS (SELECT DISTINCT * FROM tbl1) SELECT * FROM tbl2 
	ORDER BY CAST(REGEXP_REPLACE(movers_dif_county_same_state_est,'','0') AS NUMERIC) DESC LIMIT 50;	
	
-- FIND REGION WITH MOST INTER-REGION MIGRATION, REGIONS GROUPED AS PER CESUS DEFINITION


-- MOST MIGRATED TO STATE PER REGION (INNER REGION MIGRATION, ONE STATE IN REGION TO ANOTHER STATE IN REGION)
-- NORTHEAST
WITH tbl1ne AS (
	SELECT current_state,current_county,movers_dif_state_current_county_est FROM county_to_county WHERE current_state IN ('Connecticut', 'Maine','Massachusetts','New Hampshire','Rhode Island','Vermont','New Jersey','New York','Pensylvania')
	AND prev_state_name IN ('Connecticut', 'Maine','Massachusetts','New Hampshire','Rhode Island','Vermont','New Jersey','New York','Pensylvania')),
	tbl2ne AS (SELECT DISTINCT * FROM tbl1ne)
	SELECT current_state,SUM(CAST(movers_dif_state_current_county_est AS NUMERIC)) AS m FROM tbl2ne
		GROUP BY current_state
		ORDER BY m DESC;	

-- MIDWEST
WITH tbl1mw AS (
	SELECT current_state,current_county,movers_dif_state_current_county_est FROM county_to_county WHERE current_state IN ('Indiana', 'Illinois','Michigan','Ohio','Wisconsin','Iowa','Kansas','Minnesota','Missouri')
	 		AND prev_state_name IN ('Indiana', 'Illinois','Michigan','Ohio','Wisconsin','Iowa','Kansas','Minnesota','Missouri')),
	tbl2mw AS (SELECT DISTINCT * FROM tbl1mw)
	SELECT current_state,SUM(CAST(movers_dif_state_current_county_est AS NUMERIC)) AS m FROM tbl2mw
		GROUP BY current_state
		ORDER BY m DESC;	
	
-- SOUTH
WITH tbl1s AS (
	SELECT current_state,current_county,movers_dif_state_current_county_est FROM county_to_county WHERE current_state IN ('Delaware', 'District of Columbia','Florida','Georgia','Maryland','North Carolina','South Carolina','Virginia','West Virginia', 'Alabama','Kentucky','Mississippi','Tennessee','Arkansas','Louisiana','Oklahoma','Texas')
	('Delaware', 'District of Columbia','Florida','Georgia','Maryland','North Carolina','South Carolina','Virginia','West Virginia', 'Alabama','Kentucky','Mississippi','Tennessee','Arkansas','Louisiana','Oklahoma','Texas')),
	tbl2s AS (SELECT DISTINCT * FROM tbl1s)
	SELECT current_state,SUM(CAST(movers_dif_state_current_county_est AS NUMERIC)) AS m FROM tbl2s
		GROUP BY current_state
		ORDER BY m DESC;	

-- WEST
WITH tbl1w AS (
	SELECT current_state,current_county,movers_dif_state_current_county_est FROM county_to_county WHERE current_state IN ('Arizona', 'Colorado', 'Idaho', 'New Mexico','Montana','Utah','Nevada','Wyoming','Alaska','California','Hawaii','Oregon','Washington')
		AND prev_state_name IN ('Arizona', 'Colorado', 'Idaho', 'New Mexico','Montana','Utah','Nevada','Wyoming','Alaska','California','Hawaii','Oregon','Washington')),
	tbl2w AS (SELECT DISTINCT * FROM tbl1w)
	SELECT current_state,SUM(CAST(movers_dif_state_current_county_est AS NUMERIC)) AS m FROM tbl2w
		GROUP BY current_state
		ORDER BY m DESC;	
		
		
-- MOST MIGRATED TO STATE FROM A DIFFERENT STATE OVERALL (EXCLUDING INNER STATE MOVING)
WITH tbl1_dif_overall AS (
	SELECT current_state,current_county,movers_dif_state_current_county_est FROM county_to_county WHERE current_state != prev_state_name AND current_state NOT IN ('District of Columbiaiaiaia')),
	tbl2_dif_overall AS (SELECT DISTINCT * FROM tbl1_dif_overall)
	SELECT current_state,SUM(CAST(movers_dif_state_current_county_est AS NUMERIC)) AS m FROM tbl2_dif_overall
		GROUP BY current_state
		ORDER BY m DESC;	