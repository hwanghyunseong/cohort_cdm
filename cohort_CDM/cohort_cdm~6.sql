1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 이성원 
4  --Date: 2017.01.31 
5   
6 @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7 @NHIS_JK: JK table in NHIS NSC 
8 @NHIS_20T: 20 table in NHIS NSC 
9 @NHIS_30T: 30 table in NHIS NSC 
10 @NHIS_40T: 40 table in NHIS NSC 
11 @NHIS_60T: 60 table in NHIS NSC 
12 @NHIS_GJ: GJ table in NHIS NSC 
13 @CONDITION_MAPPINGTABLE : mapping table between KCD and SNOMED-CT 
14  --Description: Condition_occurrence 테이블 생성 
15  --Generating Table: CONDITION_OCCURRENCE 
16 ***************************************/ 
17 
 
18 /************************************** 
19  1. 테이블 생성 
20 ***************************************/  
21 CREATE TABLE @ResultDatabaseSchema.CONDITION_OCCURRENCE (  
22      condition_occurrence_id		BIGINT			PRIMARY KEY,  
23      person_id						INTEGER			NOT NULL ,  
24      condition_concept_id			INTEGER			NOT NULL ,  
25      condition_start_date			DATE			NOT NULL ,  
26      condition_end_date				DATE,  
27      condition_type_concept_id		INTEGER			NOT NULL ,  
28      stop_reason					VARCHAR(20),  
29      provider_id					INTEGER,  
30      visit_occurrence_id			BIGINT,  
31      condition_source_value			VARCHAR(50), 
32 	 condition_source_concept_id	VARCHAR(50) 
33 ); 
34 
 
35 
 
36 /************************************** 
37  2. 데이터 입력 
38     1) 관측시작일: 자격년도.01.01이 디폴트. 출생년도가 그 이전이면 출생년도.01.01 
39 	2) 관측종료일: 자격년도.12.31이 디폴트. 사망년월이 그 이후면 사망년.월.마지막날 
40 	 
41 	참고) 20T: 119,362,188 
42         40T: 299,379,698 
43 	 
44 	-- checklist 
45 	   1) 상병 kcdcode full set 있는지 확인 -> 조수연 선생님 : 완료 
46 	   2) condition_type_concept_id 값 확인 -> 유승찬 선생님 
47 ***************************************/  
48 
 
49 INSERT INTO @ResultDatabaseSchema.CONDITION_OCCURRENCE  
50 	(condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_end_date, 
51 	condition_type_concept_id, stop_reason, provider_id, visit_occurrence_id, condition_source_value,  
52 	condition_source_concept_id) 
53 select  
54 	convert(bigint, convert(varchar, m.master_seq) + convert(varchar, ROW_NUMBER() OVER(partition BY key_seq, seq_no order by concept_id desc))) as condition_occurrence_id, 
55 	--ROW_NUMBER() OVER(partition BY key_seq, seq_no order by concept_id desc) AS rank, m.seq_no, 
56 	m.person_id as person_id, 
57 	n.concept_id as condition_concept_id, 
58 	convert(date, m.recu_fr_dt, 112) as condition_start_date, 
59 	m.visit_end_date as condition_end_date, 
60 	m.sick_order as condition_type_concept_id, 
61 	null as stop_reason, 
62 	null as provider_id, 
63 	m.key_seq as visit_occurrence_id, 
64 	m.sick_sym as condition_source_value, 
65 	null as condition_source_concept_id 
66 from ( 
67 	select 
68 		a.master_seq, a.person_id, a.key_seq, a.seq_no, b.recu_fr_dt, 
69 		case when b.form_cd in ('02', '04', '06', '07', '10', '12') then DATEADD(DAY, b.vscn-1, convert(date, b.recu_fr_dt, 112))  
70 			when b.form_cd in ('03', '05', '08', '09', '11', '13', '20', '21', 'ZZ') and b.in_pat_cors_type in ('11', '21', '31') then DATEADD(DAY, b.vscn-1, convert(date, b.recu_fr_dt, 112)) 
71 			else convert(date, b.recu_fr_dt, 112) 
72 		end as visit_end_date, 
73 		c.sick_sym, 
74 		case when c.sick_sym=b.main_sick then '44786627' --primary condition 
75 			when c.sick_sym=b.sub_sick then '44786629' --secondary condition 
76 			else '45756845' --third condition 
77 		end as sick_order, 
78 		case when b.sub_sick=c.sick_sym then 'Y' else 'N' end as sub_sick_yn 
79 	from (select master_seq, person_id, key_seq, seq_no from seq_master where source_table='140') a,  
80 		@NHISDatabaseSchema.@NHIS_20T b, 
81 		@NHISDatabaseSchema.@NHIS_40T  c, 
82 		observation_period d --추가 
83 	where a.person_id=b.person_id 
84 	and a.key_seq=b.key_seq 
85 	and a.key_seq=c.key_seq 
86 	and a.seq_no=c.seq_no 
87 	and b.person_id=d.person_id --추가 
88 	and convert(date, c.recu_fr_dt, 112) between d.observation_period_start_date and d.observation_period_end_date) as m, --추가 
89 	@ResultDatabaseSchema.@CONDITION_MAPPINGTABLE as n 
90 where m.sick_sym=n.kcdcode 
91  
