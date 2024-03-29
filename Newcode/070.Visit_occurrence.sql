/**************************************
 --encoding : UTF-8
 --Author: SW Lee
 --Date: 2018.09.10
 
 @NHIDNSC_rawdata : DB containing NHIS National Sample cohort DB
 @NHIDNSC_database : DB for NHIS-NSC in CDM format
 @NHID_JK: JK table in NHIS NSC
 @NHID_20T: 20 table in NHIS NSC
 @NHID_30T: 30 table in NHIS NSC
 @NHID_40T: 40 table in NHIS NSC
 @NHID_60T: 60 table in NHIS NSC
 @NHID_GJ: GJ table in NHIS NSC
 --Description: Create Visit_occurrence table
 --Generating Table: VISIT_OCCURRENCE
***************************************/

/**************************************
 1. Create table
***************************************/ 
/*
CREATE TABLE cohort_cdm.VISIT_OCCURRENCE (
	visit_occurrence_id	number	primary key,
	person_id			integer	not null,
	visit_concept_id	integer	not null,
	visit_start_date	date	not null,
	visit_start_time	date,
	visit_end_date		date	not null,
	visit_end_time		date,
	visit_type_concept_id	integer	not null,
	provider_id			integer,
	care_site_id		integer,
	visit_source_value	varchar(50),
	visit_source_concept_id	integer
);
*/

/**************************************
 2. Insert data
***************************************/ 
insert into cohort_cdm.VISIT_OCCURRENCE (
	visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_datetime,
	visit_end_date, visit_end_datetime, visit_type_concept_id, provider_id, care_site_id,
	visit_source_value, visit_source_concept_id
)
select 
	key_seq as visit_occurrence_id,
	person_id as person_id,
	case when form_cd in ('02', '2', '04', '06', '07', '10', '12') and in_pat_cors_type in ('11', '21', '31') then 9203 -- inpatient + emergency
		when form_cd in ('02', '2', '04', '06', '07', '10', '12') and in_pat_cors_type not in ('11', '21', '31') then 9201 -- inaptient 
		when form_cd in ('03', '3', '05', '08', '8', '09', '9', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type in ('11', '21', '31') then 9203 -- outpatient + emergency
		when form_cd in ('03', '3', '05', '08', '8', '09', '9', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type not in ('11', '21', '31') then 9202 -- outpatient
		else 0
	end as visit_concept_id,
	TO_DATE(recu_fr_dt, 'yyyymmdd') as visit_start_date,
	null as visit_start_datetime,
	case when form_cd in ('02', '2', '04', '06', '07', '10', '12') and VSCN > 0 then TO_DATE(recu_fr_dt, 'yyyymmdd') + vscn -1
		when form_cd in ('02', '2', '04', '06', '07', '10', '12') and VSCN = 0 then DATEADD(DAY, convert(int, vscn) then TO_DATE(recu_fr_dt, 'yyyymmdd') + vscn -1 
		when form_cd in ('03', '3', '05', '08', '8', '09', '9', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type in ('11', '21', '31') and VSCN > 0 then DATEADD(DAY, vscn-1, convert(date, recu_fr_dt, 112))
		when form_cd in ('03', '3', '05', '08', '8', '09', '9', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type in ('11', '21', '31') and VSCN = 0 then DATEADD(DAY, convert(int, vscn), convert(date, recu_fr_dt, 112))
		else TO_DATE(recu_fr_dt, 'yyyymmdd')
	end as visit_end_date,
	null as visit_end_datetime,
	44818517 as visit_type_concept_id,
	null as provider_id,
	ykiho_id as care_site_id,
	key_seq as visit_source_value,
	null as visit_source_concept_id
from cohot_cdm.NHID_20T
;

--INSERT GJ data
insert into cohort_cdm.VISIT_OCCURRENCE (
	visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_datetime,
	visit_end_date, visit_end_datetime, visit_type_concept_id, provider_id, care_site_id,
	visit_source_value, visit_source_concept_id
)
select 
	b.master_seq as visit_occurrence_id,
	a.person_id as person_id,
	9202 as visit_concept_id,
	to_date(a.hchk_year || '0101', 'yyyymmdd') as visit_start_date,
	null as visit_start_datetime,
	to_date(a.hchk_year || '0101', 'yyyymmdd') as visit_end_date,
	null as visit_end_datetime,
	44818517 as visit_type_concept_id,
	null as provider_id,
	null as care_site_id,
	b.master_seq as visit_source_value,
	null as visit_source_concept_id
from cohort_cdm.NHID_GJ a JOIN cohort_cdm.seq_master b on a.person_id=b.person_id and a.hchk_year=b.hchk_year
;
