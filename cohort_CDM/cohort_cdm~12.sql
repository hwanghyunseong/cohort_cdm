1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 조재형 
4  --Date: 2017.02.21 
5   
6 @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7 @ResultDatabaseSchema : DB for NHIS-NSC in CDM format 
8 @NHIS_JK: JK table in NHIS NSC 
9 @NHIS_20T: 20 table in NHIS NSC 
10 @NHIS_30T: 30 table in NHIS NSC 
11 @NHIS_40T: 40 table in NHIS NSC 
12 @NHIS_60T: 60 table in NHIS NSC 
13 @NHIS_GJ: GJ table in NHIS NSC 
14 @CONDITION_MAPPINGTABLE : mapping table between KCD and OMOP vocabulary 
15 @DRUG_MAPPINGTABLE : mapping table between EDI and OMOP vocabulary 
16 @PROCEDURE_MAPPINGTABLE : mapping table between Korean procedure and OMOP vocabulary 
17 @DEVICE_MAPPINGTABLE : mapping table between EDI and OMOP vocabulary 
18   
19  --Description: PAYER_PLAN_PERIOD 테이블 생성 
20 			   1) payer_plan_period_id = person_id+연도 4자로 정의 
21 			   2) payer_plan_period_start_date = 당해 01월 01일로 정의 
22 			   3) payer_plan_period_end_date = 당해 12월 31일 혹은 death date로 정의 
23  --Generating Table: PAYER_PLAN_PERIOD 
24 ***************************************/ 
25 
 
26 /************************************** 
27  1. 테이블 생성  
28 ***************************************/  
29 
 
30 CREATE TABLE @ResultDatabaseSchema.PAYER_PLAN_PERIOD 
31     ( 
32      payer_plan_period_id				BIGINT						NOT NULL ,  
33      person_id							INTEGER						NOT NULL , 
34      payer_plan_period_start_date		DATE						NOT NULL , 
35      payer_plan_period_end_date			DATE						NOT NULL , 
36      payer_source_value					VARCHAR(50) 				NULL,   
37      plan_source_value					VARCHAR(50) 				NULL,   
38 	 family_source_value				VARCHAR(50) 				NULL    
39 	) 
40  ; -- DROP TABLE @ResultDatabaseSchema.PAYER_PLAN_PERIOD 
41   
42   
43 /************************************** 
44  2. 데이터 입력 및 확인 -- 02:57, (12132633개 행이 영향을 받음) 
45 ***************************************/   
46 
 
47 INSERT INTO @ResultDatabaseSchema.PAYER_PLAN_PERIOD (payer_plan_period_id, person_id, payer_plan_period_start_date, payer_plan_period_end_date, payer_source_value, plan_source_value, family_source_value) 
48 	SELECT	a.person_id+STND_Y as payer_plan_period_id, 
49 			a.person_id as person_id, 
50 			cast(convert(VARCHAR, STND_Y + '0101' ,23) as date) as payer_plan_period_start_date, 
51 			case when year < death_date then a.year 
52 			when year > death_date then death_date 
53 			else a.year 
54 			end as payer_plan_period_end_date, 
55 			payer_source_value = 'National Health Insurance Service', 
56 			IPSN_TYPE_CD as plan_source_value, 
57 			family_source_value = null 
58 	FROM  
59 			(select person_id, STND_Y, IPSN_TYPE_CD, cast(convert(VARCHAR, cast(YEAR as varchar) + '1231' ,23) as date) as year from @NHISDatabaseSchema.@NHIS_JK ) a left join @NHISDatabaseSchema.Death b 
60 	  		on a.person_id=b.person_id 
