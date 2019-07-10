1 /************************************** 
2  --encoding : UTF-8 
3  --Author: OHDSI 
4    
5 @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
6 @ResultDatabaseSchema : DB for NHIS-NSC in CDM format 
7   
8  --Description: OHDSI에서 생성한 dose_era 생성 쿼리 
9  --Generating Table: DOSE_ERA 
10 ***************************************/ 
11 
 
12 /************************************** 
13  1. dose_era 테이블 생성 
14 ***************************************/  
15  CREATE TABLE @ResultDatabaseSchema.DOSE_ERA ( 
16      dose_era_id					INTEGER	 identity(1,1)    NOT NULL ,  
17      person_id						INTEGER     NOT NULL , 
18      drug_concept_id				INTEGER   NOT NULL , 
19      unit_concept_id				INTEGER      NOT NULL , 
20      dose_value						float  NOT NULL , 
21      dose_era_start_date			DATE 		NOT	NULL,  
22 	 dose_era_end_date				DATE 		NOT	NULL 
23 ); 
24 
 
25 
 
26 /************************************** 
27  2. 1단계: 필요 데이터 조회 
28 ***************************************/  
29 
 
30 --------------------------------------------#cteDrugTarget 
31 SELECT 
32 	d.drug_exposure_id 
33 	, d.person_id 
34 	, c.concept_id AS ingredient_concept_id 
35 	, d.dose_unit_concept_id AS unit_concept_id 
36 	, d.effective_drug_dose AS dose_value 
37 	, d.drug_exposure_start_date 
38 	, d.days_supply AS days_supply 
39 	, COALESCE(d.drug_exposure_end_date, DATEADD(DAY, d.days_supply, d.drug_exposure_start_date), DATEADD(DAY, 1, drug_exposure_start_date)) AS drug_exposure_end_date 
40 INTO #cteDrugTarget  
41 FROM drug_exposure d 
42 	 JOIN concept_ancestor ca ON ca.descendant_concept_id = d.drug_concept_id 
43 	 JOIN concept c ON ca.ancestor_concept_id = c.concept_id 
44 	 WHERE c.vocabulary_id = 'RxNorm' 
45 	 AND c.concept_class_ID = 'Ingredient'; 
46 	 
47 	 
48 --------------------------------------------#cteEndDates 
49 SELECT 
50 	person_id 
51 	, ingredient_concept_id 
52 	, unit_concept_id 
53 	, dose_value 
54 	, DATEADD( DAY, -30, event_date) AS end_date 
55 INTO #cteEndDates FROM 
56 ( 
57 	SELECT 
58 		person_id 
59 		, ingredient_concept_id 
60 		, unit_concept_id 
61 		, dose_value 
62 		, event_date 
63 		, event_type 
64 		, MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id, unit_concept_id, dose_value ORDER BY event_date, event_type ROWS unbounded preceding) AS start_ordinal 
65 		, ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id, unit_concept_id, dose_value ORDER BY event_date, event_type) AS overall_ord 
66 	FROM 
67 	( 
68 		SELECT 
69 			person_id 
70 			, ingredient_concept_id 
71 			, unit_concept_id 
72 			, dose_value 
73 			, drug_exposure_start_date AS event_date 
74 			, -1 AS event_type, ROW_NUMBER() OVER(PARTITION BY person_id, ingredient_concept_id, unit_concept_id, dose_value ORDER BY drug_exposure_start_date) AS start_ordinal 
75 		FROM #cteDrugTarget  
76 
 
77 		UNION ALL 
78 
 
79 		SELECT 
80 			person_id 
81 			, ingredient_concept_id 
82 			, unit_concept_id 
83 			, dose_value 
84 			, DATEADD(DAY, 30, drug_exposure_end_date) AS drug_exposure_end_date 
85 			, 1 AS event_type 
86 			, NULL 
87 		FROM #cteDrugTarget 
88 	) RAWDATA 
89 ) e 
90 WHERE (2 * e.start_ordinal) - e.overall_ord = 0; 
91 
 
92 
 
93 --------------------------------------------#cteDoseEraEnds 
94 SELECT 
95 	dt.person_id 
96 	, dt.ingredient_concept_id as drug_concept_id 
97 	, dt.unit_concept_id  
98 	, dt.dose_value 
99 	, dt.drug_exposure_start_date 
100 	, MIN(e.end_date) AS dose_era_end_date 
101 into #cteDoseEraEnds FROM #cteDrugTarget dt 
102 JOIN #cteEndDates e 
103 ON dt.person_id = e.person_id AND dt.ingredient_concept_id = e.ingredient_concept_id AND dt.unit_concept_id = e.unit_concept_id AND dt.dose_value = e.dose_value AND e.end_date >= dt.drug_exposure_start_date 
104 GROUP BY 
105 	dt.drug_exposure_id 
106 	, dt.person_id 
107 	, dt.ingredient_concept_id 
108 	, dt.unit_concept_id 
109 	, dt.dose_value 
110 	, dt.drug_exposure_start_date; 
111 
 
112 	 
113 	 
114 /************************************** 
115  3. 2단계: dose_era에 데이터 입력 
116 ***************************************/  
117 
 
118 INSERT INTO @ResultDatabaseSchema.dose_era (person_id, drug_concept_id, unit_concept_id, dose_value, dose_era_start_date, dose_era_end_date) 
119 SELECT 
120 	person_id 
121 	, drug_concept_id 
122 	, unit_concept_id 
123 	, dose_value 
124 	, MIN(drug_exposure_start_date) AS dose_era_start_date 
125 	, dose_era_end_date 
126 	from #cteDoseEraEnds 
127 GROUP BY person_id, drug_concept_id, unit_concept_id, dose_value, dose_era_end_date 
128 ORDER BY person_id, drug_concept_id; 
