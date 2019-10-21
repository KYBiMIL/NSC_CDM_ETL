=/**************************************
 --encoding : UTF-8
 --Author: 이성원
 --Date: 2017.01.31
 
@NHISDatabaseSchema : DB containing NHIS National Sample cohort DB
@NHIS_JK: JK table in NHIS NSC
@NHIS_20T: 20 table in NHIS NSC
@NHIS_30T: 30 table in NHIS NSC
@NHIS_40T: 40 table in NHIS NSC
@NHIS_60T: 60 table in NHIS NSC
@NHIS_GJ: GJ table in NHIS NSC
@CONDITION_MAPPINGTABLE : mapping table between KCD and SNOMED-CT
 --Description: Condition_occurrence 테이블 생성
 --Generating Table: CONDITION_OCCURRENCE
***************************************/

/**************************************
 1. 테이블 생성
***************************************/ 
CREATE TABLE cohort_cdm.CONDITION_OCCURRENCE ( 
     condition_occurrence_id		NUMBER			PRIMARY KEY, 
     person_id						INTEGER			NOT NULL , 
     condition_concept_id			INTEGER			NOT NULL , 
     condition_start_date			DATE			NOT NULL , 
     condition_end_date				DATE, 
     condition_type_concept_id		INTEGER			NOT NULL , 
     stop_reason					VARCHAR(20), 
     provider_id					INTEGER, 
     visit_occurrence_id			NUMBER, 
     condition_source_value			VARCHAR(50),
	 condition_source_concept_id	VARCHAR(50)
);


/**************************************
 2. 데이터 입력
    1) 관측시작일: 자격년도.01.01이 디폴트. 출생년도가 그 이전이면 출생년도.01.01
	2) 관측종료일: 자격년도.12.31이 디폴트. 사망년월이 그 이후면 사망년.월.마지막날
	
	참고) 20T: 119,362,188
        40T: 299,379,698
	
	-- checklist
	   1) 상병 kcdcode full set 있는지 확인 -> 조수연 선생님 : 완료
	   2) condition_type_concept_id 값 확인 -> 유승찬 선생님
***************************************/ 

INSERT INTO cohort_cdm.CONDITION_OCCURRENCE 
	(condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_end_date,
	condition_type_concept_id, stop_reason, provider_id, visit_occurrence_id, condition_source_value, 
	condition_source_concept_id)
select 
	to_number(to_char(m.master_seq) || to_char(ROW_NUMBER() OVER(partition BY key_seq, seq_no order by concept_id desc))) as condition_occurrence_id,
	--ROW_NUMBER() OVER(partition BY key_seq, seq_no order by concept_id desc) AS rank, m.seq_no,
	m.person_id as person_id,
	n.concept_id as condition_concept_id,
	to_date(m.recu_fr_dt, 'yyyymmdd') as condition_start_date,
	m.visit_end_date as condition_end_date,
	m.sick_order as condition_type_concept_id,
	null as stop_reason,
	null as provider_id,
	m.key_seq as visit_occurrence_id,
	m.sick_sym as condition_source_value,
	null as condition_source_concept_id
from (
	select
		a.master_seq, a.person_id, a.key_seq, a.seq_no, b.recu_fr_dt,
		case when b.form_cd in ('02', '04', '06', '07', '10', '12') then to_date(b.recu_fr_dt, 'yyyymmdd') + b.vscn - 1 
			when b.form_cd in ('03', '05', '08', '09', '11', '13', '20', '21', 'ZZ') and b.in_pat_cors_type in ('11', '21', '31') then to_date(b.recu_fr_dt, 'yyyymmdd') + b.vscn - 1
	);
