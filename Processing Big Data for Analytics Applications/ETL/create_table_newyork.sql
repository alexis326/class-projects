DROP TABLE IF EXISTS new_york_migration;
CREATE EXTERNAL TABLE new_york_migration(
	state_code_a STRING,
	fip_county_code_a STRING,
	mcd_code_a STRING,
	state_code_b STRING,
	fip_county_code_b STRING,
	mcd_code_b STRING,
	state_name_a STRING,
	county_name_a STRING,
	mcd_a STRING,
	state_name_b STRING,
	county_name_b STRING,
	mcd_b STRING,
	flow_b_to_a_est STRING,
	flow_b_to_a_moe STRING,
	counterflow_a_to_b_est STRING,
	counterflow_a_to_b_moe STRING,
	net_b_to_a_est STRING,
	net_b_to_a_moe STRING,
	gross_btw_a_b_est STRING,
	gross_btw_a_b_moe STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE
LOCATION '/user/ahr359/final_project_files/hive_tables/new_york_migration';