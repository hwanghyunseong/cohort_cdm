1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 이성원 
4  --Date: 2017.02.13 
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
17   
18  --Description: Procedure_occurrence 테이블 생성 
19 			   * 30T(진료), 60T(처방전) 테이블에서 각각 ETL을 수행해야 함 
20  --Generating Table: PROCEDURE_OCCURRENCE 
21 ***************************************/ 
22 
 
23 /************************************** 
24  1. 변환 데이터 건수 파악 
25 ***************************************/  
26 -- 30T 변환 예상 건수(1:N 매핑 허용) 
27 select count(a.key_seq) 
28 from @NHISDatabaseSchema.@NHIS_30T a, procedure_edi_mapped_20161007 b, @NHISDatabaseSchema.@NHIS_20T c 
29 where a.div_cd=b.sourcecode 
30 and a.key_seq=c.key_seq 
31 
 
32 -- 참고) 30T 변환 예상 건수 (distinct 용어만 카운트) 
33 select count(a.key_seq) 
34 from @NHISDatabaseSchema.@NHIS_30T a, @NHISDatabaseSchema.@NHIS_20T b 
35 where a.key_seq=b.key_seq 
36 and a.div_cd in (select distinct sourcecode 
37 	from procedure_edi_mapped_20161007) 
38 	 
39 -- 참고) 30T 중 1:N 매핑 중복 건수 
40 select count(a.key_seq), sum(cnt) 
41 from @NHISDatabaseSchema.@NHIS_30T a,  
42 	(select sourcecode, count(sourcecode)-1 as cnt  
43 	from procedure_edi_mapped_20161007  
44 	group by sourcecode  
45 	having count(sourcecode) > 1) b 
46 where a.div_cd=b.sourcecode 
47 -- 1,168,437 
48 
 
49 ---------------------------------------- 
50 -- 60T 변환 예상 건수(1:N 매핑 허용) 
51 select count(a.key_seq) 
52 from @NHISDatabaseSchema.[drug02_13_60T] a, procedure_edi_mapped_20161007 b, @NHISDatabaseSchema.@NHIS_20T c 
53 where a.div_cd=b.sourcecode 
54 and a.key_seq=c.key_seq 
55 
 
56 -- 참고) 60T 변환 예상 건수 (distinct 용어만 카운트) 
57 select count(a.key_seq) 
58 from @NHISDatabaseSchema.[drug02_13_60T] a, @NHISDatabaseSchema.@NHIS_20T b 
59 where a.key_seq=b.key_seq 
60 and a.div_cd in (select distinct sourcecode 
61 	from procedure_edi_mapped_20161007) 
62 
 
63 -- 참고) 60T 중 1:N 매핑 중복 건수 
64 select count(a.key_seq), sum(cnt) 
65 from @NHISDatabaseSchema.[drug02_13_60T] a,  
66 	(select sourcecode, count(sourcecode)-1 as cnt  
67 	from procedure_edi_mapped_20161007  
68 	group by sourcecode  
69 	having count(sourcecode) > 1) b, 
70 	@NHISDatabaseSchema.@NHIS_20T c 
71 where a.div_cd=b.sourcecode 
72 and a.key_seq=c.key_seq 
73 -- 1건 
74 
 
75 
 
76 /************************************** 
77  2. 테이블 생성 
78 ***************************************/  
79 CREATE TABLE @ResultDatabaseSchema.PROCEDURE_OCCURRENCE (  
80      procedure_occurrence_id		BIGINT			PRIMARY KEY,  
81      person_id						INTEGER			NOT NULL,  
82      procedure_concept_id			INTEGER			NOT NULL,  
83      procedure_date					DATE			NOT NULL,  
84      procedure_type_concept_id		INTEGER			NOT NULL, 
85 	 modifier_concept_id			INTEGER			NULL, 
86 	 quantity						INTEGER			NULL,  
87      provider_id					INTEGER			NULL,  
88      visit_occurrence_id			BIGINT			NULL,  
89      procedure_source_value			VARCHAR(50)		NULL, 
90 	 procedure_source_concept_id	INTEGER			NULL, 
91 	 qualifier_source_value			VARCHAR(50)		NULL 
92     ) 
93 ; 
94 
 
95 
 
96 /************************************** 
97  3. 30T를 이용하여 데이터 입력 
98 ***************************************/ 
99 INSERT INTO @ResultDatabaseSchema.PROCEDURE_OCCURRENCE  
100 	(procedure_occurrence_id, person_id, procedure_concept_id, procedure_date, procedure_type_concept_id,  
101 	modifier_concept_id, quantity, provider_id, visit_occurrence_id, procedure_source_value,  
102 	procedure_source_concept_id, qualifier_source_value) 
103 SELECT  
104 	convert(bigint, convert(varchar, a.master_seq) + convert(varchar, row_number() over (partition by a.key_seq, a.seq_no order by b.concept_id))) as procedure_occurrence_id, 
105 	a.person_id as person_id, 
106 	CASE WHEN b.concept_id IS NOT NULL THEN b.concept_id ELSE 0 END as procedure_concept_id, 
107 	CONVERT(VARCHAR, a.recu_fr_dt, 112) as procedure_date, 
108 	45756900 as procedure_type_concept_id, 
109 	NULL as modifier_concept_id, 
110 	convert(float, a.dd_mqty_exec_freq) * convert(float, a.mdcn_exec_freq) * convert(float, a.dd_mqty_freq) as quantity, 
111 	NULL as provider_id, 
112 	a.key_seq as visit_occurrence_id, 
113 	a.div_cd as procedure_source_value, 
114 	null as procedure_source_concept_id, 
115 	null as qualifier_source_value 
116 FROM (SELECt x.key_seq, x.seq_no, x.recu_fr_dt, x.div_cd,  
117 			case when x.mdcn_exec_freq is not null and isnumeric(x.mdcn_exec_freq)=1 and cast(x.mdcn_exec_freq as float) > '0' then cast(x.mdcn_exec_freq as float) else 1 end as mdcn_exec_freq, 
118 			case when x.dd_mqty_exec_freq is not null and isnumeric(x.dd_mqty_exec_freq)=1 and cast(x.dd_mqty_exec_freq as float) > '0' then cast(x.dd_mqty_exec_freq as float) else 1 end as dd_mqty_exec_freq, 
119 			case when x.dd_mqty_freq is not null and isnumeric(x.dd_mqty_freq)=1 and cast(x.dd_mqty_freq as float) > '0' then cast(x.dd_mqty_freq as float) else 1 end as dd_mqty_freq, 
120 			y.master_seq, y.person_id 
121 	FROM @NHISDatabaseSchema.@NHIS_30T x,  
122 		 (select master_seq, key_seq, seq_no, person_id from seq_master where source_table='130') y 
123 	WHERE x.key_seq=y.key_seq 
124 	AND x.seq_no=y.seq_no) a, procedure_EDI_mapped_20161007 b 
125 WHERE a.div_cd=b.sourcecode 
126 
 
127 
 
128 /************************************** 
129  4. 60T를 이용하여 데이터 입력 
130 ***************************************/ 
131 INSERT INTO @ResultDatabaseSchema.PROCEDURE_OCCURRENCE  
132 	(procedure_occurrence_id, person_id, procedure_concept_id, procedure_date, procedure_type_concept_id,  
133 	modifier_concept_id, quantity, provider_id, visit_occurrence_id, procedure_source_value,  
134 	procedure_source_concept_id, qualifier_source_value) 
135 SELECT  
136 	convert(bigint, convert(varchar, a.master_seq) + convert(varchar, row_number() over (partition by a.key_seq, a.seq_no order by b.concept_id))) as procedure_occurrence_id, 
137 	a.person_id as person_id, 
138 	CASE WHEN b.concept_id IS NOT NULL THEN b.concept_id ELSE 0 END as procedure_concept_id, 
139 	CONVERT(VARCHAR, a.recu_fr_dt, 112) as procedure_date, 
140 	45756900 as procedure_type_concept_id, 
141 	NULL as modifier_concept_id, 
142 	convert(float, a.dd_mqty_freq) * convert(float, a.dd_exec_freq) * convert(float, a.mdcn_exec_freq) as quantity, 
143 	NULL as provider_id, 
144 	a.key_seq as visit_occurrence_id, 
145 	a.div_cd as procedure_source_value, 
146 	null as procedure_source_concept_id, 
147 	null as qualifier_source_value 
148 FROM (SELECt x.key_seq, x.seq_no, x.recu_fr_dt, x.div_cd,  
149 			case when x.mdcn_exec_freq is not null and isnumeric(x.mdcn_exec_freq)=1 and cast(x.mdcn_exec_freq as float) > '0' then cast(x.mdcn_exec_freq as float) else 1 end as mdcn_exec_freq, 
150 			case when x.dd_exec_freq is not null and isnumeric(x.dd_exec_freq)=1 and cast(x.dd_exec_freq as float) > '0' then cast(x.dd_exec_freq as float) else 1 end as dd_exec_freq, 
151 			case when x.dd_mqty_freq is not null and isnumeric(x.dd_mqty_freq)=1 and cast(x.dd_mqty_freq as float) > '0' then cast(x.dd_mqty_freq as float) else 1 end as dd_mqty_freq, 
152 			y.master_seq, y.person_id 
153 	FROM @NHISDatabaseSchema.@NHIS_60T x,  
154 		 (select master_seq, key_seq, seq_no, person_id from seq_master where source_table='160') y 
155 	WHERE x.key_seq=y.key_seq 
156 	AND x.seq_no=y.seq_no) a, @ResultDatabaseSchema.@PROCEDURE_MAPPINGTABLE b 
157 WHERE a.div_cd=b.sourcecode 
