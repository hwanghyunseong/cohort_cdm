1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 이성원 
4  --Date: 2017.01.26 
5   
6  @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7  @NHIS_JK: JK table in NHIS NSC 
8  @NHIS_20T: 20 table in NHIS NSC 
9  @NHIS_30T: 30 table in NHIS NSC 
10  @NHIS_40T: 40 table in NHIS NSC 
11  @NHIS_60T: 60 table in NHIS NSC 
12  @NHIS_GJ: GJ table in NHIS NSC 
13  --Description: Visit_occurrence 테이블 생성 
14  --Generating Table: VISIT_OCCURRENCE 
15 ***************************************/ 
16 
 
17 /************************************** 
18  1. 테이블 생성 
19 ***************************************/  
20 CREATE TABLE @ResultDatabaseSchema.VISIT_OCCURRENCE ( 
21 	visit_occurrence_id	bigint	primary key, 
22 	person_id			integer	not null, 
23 	visit_concept_id	integer	not null, 
24 	visit_start_date	date	not null, 
25 	visit_start_time	time, 
26 	visit_end_date		date	not null, 
27 	visit_end_time		time, 
28 	visit_type_concept_id	integer	not null, 
29 	provider_id			integer, 
30 	care_site_id		integer, 
31 	visit_source_value	varchar(50), 
32 	visit_source_concept_id	integer 
33 ); 
34 
 
35 /************************************** 
36  2. 데이터 입력 
37 ***************************************/  
38 insert into @ResultDatabaseSchema.VISIT_OCCURRENCE ( 
39 	visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_time, 
40 	visit_end_date, visit_end_time, visit_type_concept_id, provider_id, care_site_id, 
41 	visit_source_value, visit_source_concept_id 
42 ) 
43 select  
44 	key_seq as visit_concept_id, 
45 	person_id as person_id, 
46 	case when form_cd in ('02', '04', '06', '07', '10', '12') and in_pat_cors_type in ('11', '21', '31') then 9203 --입원 + 응급 
47 		when form_cd in ('02', '04', '06', '07', '10', '12') and in_pat_cors_type not in ('11', '21', '31') then 9201 --입원 + 입원 
48 		when form_cd in ('03', '05', '08', '09', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type in ('11', '21', '31') then 9203 --외래 + 응급 
49 		when form_cd in ('03', '05', '08', '09', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type not in ('11', '21', '31') then 9202 --외래 + 외래 
50 		else 0 
51 	end as visit_concept_id, 
52 	convert(date, recu_fr_dt, 112) as visit_start_date, 
53 	null as visit_start_time, 
54 	case when form_cd in ('02', '04', '06', '07', '10', '12') then DATEADD(DAY, vscn-1, convert(date, recu_fr_dt, 112))  
55 		when form_cd in ('03', '05', '08', '09', '11', '13', '20', '21', 'ZZ') and in_pat_cors_type in ('11', '21', '31') then DATEADD(DAY, vscn-1, convert(date, recu_fr_dt, 112)) 
56 		else convert(date, recu_fr_dt, 112) 
57 	end as visit_end_date, 
58 	null as visit_end_time, 
59 	44818517 as visit_type_concept_id, 
60 	null as provider_id, 
61 	ykiho_id as care_site_id, 
62 	key_seq as visit_source_value, 
63 	null as visit_source_concept_id 
64 from @NHISDatabaseSchema.@NHIS_20T 
65 ; 
66 
 
67 
 
68 --건강검진 INSERT 
69 insert into @ResultDatabaseSchema.VISIT_OCCURRENCE ( 
70 	visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_time, 
71 	visit_end_date, visit_end_time, visit_type_concept_id, provider_id, care_site_id, 
72 	visit_source_value, visit_source_concept_id 
73 ) 
74 select  
75 	b.master_seq as visit_concept_id, 
76 	a.person_id as person_id, 
77 	9202 as visit_concept_id, 
78 	cast(CONVERT(VARCHAR, a.hchk_year+'0101', 23)as date) as visit_start_date, 
79 	null as visit_start_time, 
80 	cast(CONVERT(VARCHAR, a.hchk_year+'0101', 23)as date) as visit_end_date, 
81 	null as visit_end_time, 
82 	44818517 as visit_type_concept_id, 
83 	null as provider_id, 
84 	null as care_site_id, 
85 	b.master_seq as visit_source_value, 
86 	null as visit_source_concept_id 
87 from @NHISDatabaseSchema.@NHIS_GJ a JOIN @ResultDatabaseSchema.seq_master b on a.person_id=b.person_id and a.hchk_year=b.hchk_year 
88 ; 
