1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 유승찬 
4  --Date: 2017.09.26 
5   
6  @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7  @NHIS_JK: JK table in NHIS NSC 
8  @NHIS_20T: 20 table in NHIS NSC 
9  @NHIS_30T: 30 table in NHIS NSC 
10  @NHIS_40T: 40 table in NHIS NSC 
11  @NHIS_60T: 60 table in NHIS NSC 
12  @NHIS_GJ: GJ table in NHIS NSC 
13  --Description: MEASUREMENT 테이블 생성				 
14  --생성 Table: MEASUREMENT 
15 ***************************************/ 
16 
 
17 /************************************** 
18  0. 테이블 생성  (33440451) 
19 ***************************************/  
20 
 
21 IF OBJECT_ID('@ResultDatabaseSchema.MEASUREMENT', 'U') IS NULL 
22 CREATE TABLE @ResultDatabaseSchema.MEASUREMENT 
23     ( 
24      measurement_id						BIGINT						NOT NULL ,  
25      person_id							INTEGER						NOT NULL , 
26      measurement_concept_id				INTEGER						NOT NULL , 
27      measurement_date					DATE						NOT NULL , 
28      measurement_time					TIME						NULL,   
29      measurement_type_concept_id		integer		 				NULL,   
30 	 operator_concept_id				integer		 				NULL,   
31 	 value_as_number					float		 				NULL, 
32 	 value_as_concept_id				integer		 				NULL, 
33 	 unit_concept_id					integer						NULL, 
34 	 range_low							float						NULL, 
35 	 range_high							float						NULL, 
36 	 provider_id						integer						NULL, 
37 	 visit_occurrence_id				bigint						NULL, 
38 	 measurement_source_value			VARCHAR(50) 				NULL, 
39 	 measurement_source_concept_id		integer						NULL, 
40 	 unit_source_value					VARCHAR(50) 				NULL, 
41 	 value_source_value					VARCHAR(50)					NULL 
42 	); 
43 
 
44 
 
45 -- measurement mapping table(temp) 
46 
 
47 CREATE TABLE #measurement_mapping 
48     ( 
49      meas_type						varchar(50)					NULL ,  
50      id_value						varchar(50)					NULL , 
51      answer							bigint						NULL , 
52      measurement_concept_id			bigint						NULL , 
53 	 measurement_type_concept_id	bigint						NULL , 
54 	 measurement_unit_concept_id	bigint						NULL , 
55 	 value_as_concept_id			bigint						NULL , 
56 	 value_as_number				float						NULL  
57 	) 
58 ; 
59 
 
60 	 
61 
 
62 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('HEIGHT',			'01',	0,	3036277,	44818701,	4122378,	NULL,		NULL) 
63 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('WEIGHT',			'02',	0,	3025315,	44818701,	4122383,	NULL,		NULL) 
64 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('WAIST',				'03',	0,	3016258,	44818701,	4122378,	NULL,		NULL) 
65 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('BP_HIGH',			'04',	0,	3028737,	44818701,	4118323,	NULL,		NULL) 
66 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('BP_LWST',			'05',	0,	3012888,	44818701,	4118323,	NULL,		NULL) 
67 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('BLDS',				'06',	0,	46235168,	44818702,	4121396,	NULL,		NULL) 
68 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('TOT_CHOLE',			'07',	0,	3027114,	44818702,	4121396,	NULL,		NULL) 
69 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('TRIGLYCERIDE',		'08',	0,	3022038,	44818702,	4121396,	NULL,		NULL) 
70 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('HDL_CHOLE',			'09',	0,	3023752,	44818702,	4121396,	NULL,		NULL) 
71 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('LDL_CHOLE',			'10',	0,	3028437,	44818702,	4121396,	NULL,		NULL) 
72 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('HMG',				'11',	0,	3000963,	44818702,	4121395,	NULL,		NULL) 
73 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GLY_CD',			'12',	1,	3009261,	44818702,	NULL,		9189,		NULL) 
74 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GLY_CD',			'12',	2,	3009261,	44818702,	NULL,		4127785,	NULL) 
75 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GLY_CD',			'12',	3,	3009261,	44818702,	NULL,		4123508,	NULL) 
76 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GLY_CD',			'12',	4,	3009261,	44818702,	NULL,		4126673,	NULL) 
77 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GLY_CD',			'12',	5,	3009261,	44818702,	NULL,		4125547,	NULL) 
78 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GLY_CD',			'12',	6,	3009261,	44818702,	NULL,		4126674,	NULL) 
79 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_OCCU_CD',		'13',	1,	437038,		44818702,	NULL,		9189,		NULL) 
80 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_OCCU_CD',		'13',	2,	437038,		44818702,	NULL,		4127785,	NULL) 
81 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_OCCU_CD',		'13',	3,	437038,		44818702,	NULL,		4123508,	NULL) 
82 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_OCCU_CD',		'13',	4,	437038,		44818702,	NULL,		4126673,	NULL) 
83 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_OCCU_CD',		'13',	5,	437038,		44818702,	NULL,		4125547,	NULL) 
84 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_OCCU_CD',		'13',	6,	437038,		44818702,	NULL,		4126674,	NULL) 
85 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PH',			'14',	0,	3015736,	44818702,	8482,		NULL,		NULL) 
86 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PROTE_CD',		'15',	1,	3014051,	44818702,	NULL,		9189,		NULL) 
87 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PROTE_CD',		'15',	2,	3014051,	44818702,	NULL,		4127785,	NULL) 
88 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PROTE_CD',		'15',	3,	3014051,	44818702,	NULL,		4123508,	NULL) 
89 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PROTE_CD',		'15',	4,	3014051,	44818702,	NULL,		4126673,	NULL) 
90 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PROTE_CD',		'15',	5,	3014051,	44818702,	NULL,		4125547,	NULL) 
91 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('OLIG_PROTE_CD',		'15',	6,	3014051,	44818702,	NULL,		4126674,	NULL) 
92 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('CREATININE',		'16',	0,	2212294,	44818702,	4121396,	NULL,		NULL) 
93 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('SGOT_AST',			'17',	0,	2212597,	44818702,	4118000,	NULL,		NULL) 
94 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('SGPT_ALT',			'18',	0,	2212598,	44818702,	4118000,	NULL,		NULL) 
95 	insert into #measurement_mapping (meas_type, id_value, answer, measurement_concept_id, measurement_type_concept_id, measurement_unit_concept_id, value_as_concept_id, value_as_number) values ('GAMMA_GTP',			'19',	0,	4289475,	44818702,	4118000,	NULL,		NULL) 
96 																																																																					 
97 																																																																					 
98 
 
99 /**************************************																																							    
100  1. 행을 열로 전환 
101 ***************************************/  
102 select hchk_year, person_id, ykiho_gubun_cd, meas_type, meas_value into @ResultDatabaseSchema.GJ_VERTICAL 
103 from @NHISDatabaseSchema.@NHIS_GJ 
104 unpivot (meas_value for meas_type in ( -- 47 검진 항목 
105 	height, weight, waist, bp_high, bp_lwst, 
106 	blds, tot_chole, triglyceride, hdl_chole, ldl_chole, 
107 	hmg, gly_cd, olig_occu_cd, olig_ph, olig_prote_cd, 
108 	creatinine, sgot_ast, sgpt_alt, gamma_gtp, hchk_pmh_cd1, 
109 	hchk_pmh_cd2, hchk_pmh_cd3, hchk_apop_pmh_yn, hchk_hdise_pmh_yn, hchk_hprts_pmh_yn, 
110 	hchk_diabml_pmh_yn, hchk_hplpdm_pmh_yn, hchk_etcdse_pmh_yn, hchk_phss_pmh_yn, fmly_liver_dise_patien_yn,  
111 	fmly_hprts_patien_yn, fmly_apop_patien_yn, fmly_hdise_patien_yn, fmly_diabml_patien_yn, fmly_cancer_patien_yn,  
112 	smk_stat_type_rsps_cd, smk_term_rsps_cd, cur_smk_term_rsps_cd, cur_dsqty_rsps_cd, past_smk_term_rsps_cd,  
113 	past_dsqty_rsps_cd, dsqty_rsps_cd, drnk_habit_rsps_Cd, tm1_drkqty_rsps_cd, exerci_freq_rsps_cd,  
114 	mov20_wek_freq_id, mov30_wek_freq_id, wlk30_wek_freq_id 
115 )) as unpivortn 
116 
 
117 
 
118 
 
119 
 
120 
 
121 /************************************** 
122  2. 수치형 데이터 입력   
123 ***************************************/  
124 INSERT INTO @ResultDatabaseSchema.MEASUREMENT (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_time, measurement_type_concept_id, operator_concept_id, value_as_number, value_as_concept_id,			 
125 											unit_concept_id, range_low, range_high, provider_id, visit_occurrence_id, measurement_source_value, measurement_source_concept_id, unit_source_value, value_source_value) 
126 
 
127 
 
128 	select	case	when a.meas_type = 'HEIGHT' then cast(concat(c.master_seq, b.id_value) as bigint) 
129 					when a.meas_type = 'WEIGHT' then cast(concat(c.master_seq, b.id_value) as bigint) 
130 					when a.meas_type = 'WAIST' then cast(concat(c.master_seq, b.id_value) as bigint) 
131 					when a.meas_type = 'BP_HIGH' then cast(concat(c.master_seq, b.id_value) as bigint) 
132 					when a.meas_type = 'BP_LWST' then cast(concat(c.master_seq, b.id_value) as bigint) 
133 					when a.meas_type = 'BLDS' then cast(concat(c.master_seq, b.id_value) as bigint) 
134 					when a.meas_type = 'TOT_CHOLE' then cast(concat(c.master_seq, b.id_value) as bigint) 
135 					when a.meas_type = 'TRIGLYCERIDE' then cast(concat(c.master_seq, b.id_value) as bigint) 
136 					when a.meas_type = 'HDL_CHOLE' then cast(concat(c.master_seq, b.id_value) as bigint) 
137 					when a.meas_type = 'LDL_CHOLE' then cast(concat(c.master_seq, b.id_value) as bigint) 
138 					when a.meas_type = 'HMG' then cast(concat(c.master_seq, b.id_value) as bigint) 
139 					when a.meas_type = 'OLIG_PH' then cast(concat(c.master_seq, b.id_value) as bigint) 
140 					when a.meas_type = 'CREATININE' then cast(concat(c.master_seq, b.id_value) as bigint) 
141 					when a.meas_type = 'SGOT_AST' then cast(concat(c.master_seq, b.id_value) as bigint) 
142 					when a.meas_type = 'SGPT_ALT' then cast(concat(c.master_seq, b.id_value) as bigint) 
143 					when a.meas_type = 'GAMMA_GTP' then cast(concat(c.master_seq, b.id_value) as bigint) 
144 					end as measurement_id, 
145 			a.person_id as person_id, 
146 			b.measurement_concept_id as measurement_concept_id, 
147 			cast(CONVERT(VARCHAR, a.hchk_year+'0101', 23)as date) as measurement_date, 
148 			measurement_time = null, 
149 			b.measurement_type_concept_id as measurement_type_concept_id, 
150 			operator_concept_id = null, 
151 			b.value_as_number as value_as_number, 
152 			b.value_as_concept_id as value_as_concept_id, 
153 			b.measurement_unit_concept_id as unit_concept_id , 
154 			range_low = null, 
155 			range_high = null, 
156 			provider_id = null, 
157 			c.master_seq as visit_occurrence_id, 
158 			a.meas_value as measurement_source_value, 
159 			measurement_source_concept_id =null, 
160 			unit_source_value = null, 
161 			a.meas_value as value_source_value 
162 
 
163 	from (select hchk_year, person_id, ykiho_gubun_cd, meas_type, meas_value 			 
164 			from @ResultDatabaseSchema.GJ_VERTICAL) a 
165 		JOIN #measurement_mapping b  
166 		on isnull(a.meas_type,'') = isnull(b.meas_type,'')  
167 			and isnull(a.meas_value,'0') >= isnull(cast(b.answer as char),'0') 
168 		JOIN @ResultDatabaseSchema.SEQ_MASTER c 
169 		on a.person_id = cast(c.person_id as char) 
170 			and a.hchk_year = c.hchk_year 
171 	where (a.meas_value != '' and substring(a.meas_type, 1, 30) in ('HEIGHT', 'WEIGHT',	'WAIST', 'BP_HIGH', 'BP_LWST', 'BLDS', 'TOT_CHOLE', 'TRIGLYCERIDE',	'HDL_CHOLE',		 
172 																	'LDL_CHOLE', 'HMG', 'OLIG_PH', 'CREATININE', 'SGOT_AST', 'SGPT_ALT', 'GAMMA_GTP') 
173 			and c.source_table like 'GJT') 
174 ; 
175 
 
176 	 
177 
 
178 /************************************** 
179  2. 코드형 데이터 입력   
180 ***************************************/  
181 INSERT INTO @ResultDatabaseSchema.MEASUREMENT (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_time, measurement_type_concept_id, operator_concept_id, value_as_number, value_as_concept_id,			 
182 											unit_concept_id, range_low, range_high, provider_id, visit_occurrence_id, measurement_source_value, measurement_source_concept_id, unit_source_value, value_source_value) 
183 
 
184 
 
185 	select	case	when a.meas_type = 'GLY_CD' then cast(concat(c.master_seq, b.id_value) as bigint) 
186 					when a.meas_type = 'OLIG_OCCU_CD' then cast(concat(c.master_seq, b.id_value) as bigint) 
187 					when a.meas_type = 'OLIG_PROTE_CD' then cast(concat(c.master_seq, b.id_value) as bigint) 
188 					end as measurement_id, 
189 			a.person_id as person_id, 
190 			b.measurement_concept_id as measurement_concept_id, 
191 			cast(CONVERT(VARCHAR, a.hchk_year+'0101', 23)as date) as measurement_date, 
192 			measurement_time = null, 
193 			b.measurement_type_concept_id as measurement_type_concept_id, 
194 			operator_concept_id = null, 
195 			b.value_as_number as value_as_number, 
196 			b.value_as_concept_id as value_as_concept_id, 
197 			b.measurement_unit_concept_id as unit_concept_id , 
198 			range_low = null, 
199 			range_high = null, 
200 			provider_id = null, 
201 			c.master_seq as visit_occurrence_id, 
202 			a.meas_value as measurement_source_value, 
203 			measurement_source_concept_id =null, 
204 			unit_source_value = null, 
205 			a.meas_value as value_source_value 
206 
 
207 	from (select hchk_year, person_id, ykiho_gubun_cd, meas_type, meas_value 			 
208 			from @ResultDatabaseSchema.GJ_VERTICAL) a 
209 		JOIN #measurement_mapping b  
210 		on isnull(a.meas_type,'') = isnull(b.meas_type,'')  
211 			and isnull(a.meas_value,'0') = isnull(cast(b.answer as char),'0') 
212 		JOIN @ResultDatabaseSchema.SEQ_MASTER c 
213 		on a.person_id = cast(c.person_id as char) 
214 			and a.hchk_year = c.hchk_year 
215 	where (a.meas_value != '' and substring(a.meas_type, 1, 30) in ('GLY_CD', 'OLIG_OCCU_CD', 'OLIG_PROTE_CD') 
216 			and c.source_table like 'GJT') 
217 ; 
218 
 
219 /************************************** 
220  3.source_value의 값을 value_as_number에도 입력 
221 ***************************************/  
222 UPDATE @ResultDatabaseSchema.MEASUREMENT 
223 SET value_as_number = measurement_source_value 
224 where measurement_source_value is not null 
