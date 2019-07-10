1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 조재형 
4  --Date: 2017.02.06 
5   
6  @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7  @NHIS_JK: JK table in NHIS NSC 
8  @NHIS_20T: 20 table in NHIS NSC 
9  @NHIS_30T: 30 table in NHIS NSC 
10  @NHIS_40T: 40 table in NHIS NSC 
11  @NHIS_60T: 60 table in NHIS NSC 
12  @NHIS_GJ: GJ table in NHIS NSC 
13  --Description: DEATH 테이블 생성 
14 			   1) 표본코호트DB에는 사망한 날짜가 년도, 월까지 표시가 되기 때문에 해당 월의 1일로 사망일 정의 
15 			   2) 표본코호트DB는 사망한 후에도 진료기록이 있는 경우가 있음을 고려 
16 			   3) 범위(A00-A15), J46 등 매핑 안되는 code들 insert(#death_mapping) 
17  --Generating Table: DEATH 
18 ***************************************/ 
19 
 
20 
 
21 /************************************** 
22  1. 테이블 생성 
23 ***************************************/   
24 
 
25 -- death table 생성 
26 CREATE TABLE  @ResultDatabaseSchema.DEATH 
27 ( 
28     person_id							INTEGER			NOT NULL ,  
29     death_date							DATE			NOT NULL ,  
30     death_type_concept_id				INTEGER			NOT NULL ,  
31     cause_concept_id					INTEGER			NULL ,  
32     cause_source_value					VARCHAR(500)	NULL, 
33 	cause_source_concept_id				INTEGER			NULL, 
34 	primary key (person_id) 
35 ); 
36 
 
37 
 
38 -- 임시 death mapping table 
39 select * into #death_mapping from  @ResultDatabaseSchema.@CONDITION_MAPPINGTABLE 
40 
 
41 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A00-A09', 'infectious enteritis', 4134887, 'Infectious disease of digestive tract') 
42 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A15-A19', 'tuberculosis', 434557, 'Tuberculosis') 
43 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A30-A49', '기타 박테리아 감염', 432545, 'Bacterial infectious disease') 
44 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A50-A64', 'sexually tranmitted disease', 440647, 'Sexually transmitted infectious disease') 
45 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A75-A79', '열성질환(typhus, tsutsugamushi, spotted fever....)', 432545, 'Bacterial infectious disease') 
46 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A80-A89', 'CNS 감염 질환', 4028070, 'Infectious disease of central nervous system') 
47 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('A90-A99', 'viral hemorrhagic fever', 4347554, 'Viral hemorrhagic fever') 
48 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B00-B09',	'viral infection', 440029, 'Viral disease') 
49 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B15-B19',	'viral liver disease', 4291005, 'Viral hepatitis') 
50 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B20-B24',	'AIDS-associated disorder', 4221489, 'AIDS-associated disorder') 
51 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B25-B34',	'viral infection', 440029, 'Viral disease') 
52 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B35-B49',	'진균증', 433701, 'Mycosis') 
53 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B50-B64',	'원충증', 442176, 'Protozoan infection') 
54 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B65-B83',	'기생충병', 432251, 'Disease caused by parasite') 
55 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('B90-B94',	'감염질환에 의한 후유증', 444201, 'Post-infectious disorder') 
56 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F00-F09',	'정신과 질환 (기질성)', 374009, 'Organic mental disorder') 
57 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F10-F19',	'약물 오남용 관련 질환', 40483111, 'Mental disorder due to drug') 
58 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F20-F29',	'조현병 관련 질환', 436073, 'Psychotic disorder') 
59 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F30-F39',	'우울증/ 조증 관련 질환', 444100, 'Mood disorder') 
60 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F40-F48',	'neurosis', 444243, 'Neurosis') 
61 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F50-F59',	'행동장애', 4333000, 'Behavioral syndrome associated with physiological disturbance and physical factors') 
62 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F70-F79',	'정신 지체', 440389, 'Mental retardation') 
63 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F80-F89',	'발달 장애', 435244, 'Developmental disorder') 
64 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('F99-F99',	'Mental disorder', 432586, 'Mental disorder') 
65 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('J46',	'Status asthmaticus', 4145356, 'Severe persistent asthma') 
66 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S00-S09',	'두부 외상', 375415, 'Injury of head') 
67 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S10-S19',	'목부위 외상', 24818, 'Injury of neck') 
68 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S20-S29',	'흉부 외상', 4094683, 'Chest injury') 
69 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S30-S39',	'복부/골반 외상', 200588, 'Injury of abdomen') 
70 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S40-S49',	'위팔/어깨 외상', 4130851, 'Injury of upper extremity') 
71 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S50-S59',	'forearm 외상', 136779, 'Disorder of forearm') 
72 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S60-S69',	'수부 외상', 80004, 'Injury of hand') 
73 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S70-S79',	'hip/thigh 외상', 4130852, 'Injury of lower extremity') 
74 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('S80-S89',	'무릎/lower leg 외상', 444131, 'Injury of lower leg') 
75 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T00-T07',	'다발성 외상', 440921, 'Traumatic injury') 
76 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T08-T14',	'척추 및 사지 손상', 4022201, 'Injury of musculoskeletal system') 
77 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T15-T19',	'foreign body', 4053838, 'Foreign body') 
78 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T20-T25',	'화상 (피부)', 4123196, 'Burn of skin of body region') 
79 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T26-T28',	'화상 (내부기관)', 198030, 'Burn of internal organ') 
80 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T29-T32',	'기타 화상', 442013, 'Burn') 
81 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T33-T35',	'동상', 441487, 'Frostbite') 
82 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T36-T50',	'poisoning (마약/약물)', 438028, 'Poisoning by drug AND/OR medicinal substance') 
83 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T51-T65',	'기타 중독', 40481346, 'Poisoning due to chemical substance') 
84 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T66-T78',	'외부 환경에 의한 영향', 4167864, 'Effect of exposure to physical force') 
85 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T79-T79',	'달리 분류되지 않은 외상의 특정 조기합병증', 4211546, 'Traumatic complication of injury') 
86 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T80-T88',	'의료 행위에 대한 합병증', 442019, 'Complication of procedure') 
87 insert into #death_mapping (KCDCODE, NAME, CONCEPT_ID, CONCEPT_NAME) values ('T90-T98',	'기타 후유증', 443403, 'Sequela') 
88 
 
89 /************************************** 
90  2. 데이터 입력 및 확인 
91 ***************************************/   
92 
 
93 --날짜를 해당 월의 말일로 정의 
94 INSERT INTO @ResultDatabaseSchema.DEATH (person_id, death_date, death_type_concept_id, cause_concept_id,  
95 cause_source_value, cause_source_concept_id) 
96 SELECT a.person_id AS PERSON_ID, 
97 	convert(varchar, DATEADD(DAY,-DATEPART(DD,DATEADD(MONTH,1,convert(VARCHAR, a.dth_ym + '01' ,23))),DATEADD(MONTH,1,convert(VARCHAR, a.dth_ym + '01' ,23))), 23) AS DEATH_DATE, 
98 	38003618 as death_type_concept_id, 
99 	b.concept_id as cause_concept_id, 
100 	dth_code1 as cause_source_value, 
101 	NULL as cause_source_concept_id 
102 FROM @NHISDatabaseSchema.@NHIS_JK a left join #death_mapping b 
103 on a.dth_code1=b.kcdcode 
104 WHERE a.dth_ym IS NOT NULL and a.dth_ym != '' 
105 
 
106 
 
107 
 
108 --날짜 없는 경우 해당 년의 12월 31일로 death 정의 
109 INSERT INTO @ResultDatabaseSchema.DEATH (person_id, death_date, death_type_concept_id, cause_concept_id,  
110 cause_source_value, cause_source_concept_id) 
111 SELECT a.person_id AS PERSON_ID, 
112 	convert(VARCHAR, STND_Y + '1231' ,23) AS DEATH_DATE, 
113 	38003618 as death_type_concept_id, 
114 	b.concept_id as cause_concept_id, 
115 	dth_code1 as cause_source_value, 
116 	NULL as cause_source_concept_id 
117 FROM @NHISDatabaseSchema.@NHIS_JK a left join #death_mapping b 
118 on a.dth_code1=b.kcdcode 
119 WHERE a.dth_ym = '' and a.DTH_CODE1 != '' 
120 
 
121 
 
122 --임시매핑테이블 삭제 
123 drop table #death_mapping 
