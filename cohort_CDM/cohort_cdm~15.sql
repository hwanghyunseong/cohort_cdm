
 Open this file in githurb Desktop 
  Fork this project and edit the file 
 
  Fork this project and delete the file 
 

1 /************************************** 
2  --encoding : UTF-8 
3  --Author: OHDSI 
4    
5 @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
6 @ResultDatabaseSchema : DB for NHIS-NSC in CDM format 
7   
8  --Description: OHDSI에서 생성한 drug_era 생성 쿼리 
9  --Generating Table: DRUG_ERA 
10 ***************************************/ 
11 
 
12 /************************************** 
13  1. drug_era 테이블 생성 
14 ***************************************/  
15   CREATE TABLE @ResultDatabaseSchema.DRUG_ERA ( 
16      drug_era_id					INTEGER	 identity(1,1)    NOT NULL ,  
17      person_id							INTEGER     NOT NULL , 
18      drug_concept_id				INTEGER   NOT NULL , 
19      drug_era_start_date			DATE      NOT NULL , 
20      drug_era_end_date				DATE 	  NOT NULL , 
21      drug_exposure_count			INTEGER			NULL,  
22 	 gap_days						INTEGER			NULL 
23 ); 
24 
 
25 
 
26 /************************************** 
27  2. 1단계: 필요 데이터 조회 
28 ***************************************/  
29 
 
30 --------------------------------------------#cteDrugPreTarget  
31 SELECT  
32 	d.drug_exposure_id 
33 	, d.person_id 
34 	, c.concept_id AS ingredient_concept_id 
35 	, d.drug_exposure_start_date AS drug_exposure_start_date 
36 	, d.days_supply AS days_supply 
37 	, COALESCE(d.drug_exposure_end_date, DATEADD(DAY, d.days_supply, d.drug_exposure_start_date), DATEADD(DAY, 1, drug_exposure_start_date)) AS drug_exposure_end_date 
38 into #cteDrugPreTarget FROM drug_exposure d 
39 JOIN concept_ancestor ca  
40 ON ca.descendant_concept_id = d.drug_concept_id 
41 JOIN concept c  
42 ON ca.ancestor_concept_id = c.concept_id 
43 WHERE c.vocabulary_id = 'RxNorm' 
44 AND c.concept_class_ID = 'Ingredient'; 
45 
 
46 
 
47 --------------------------------------------#cteDrugTarget1 
48 SELECT 
49 	drug_exposure_id 
50 	, person_id 
51 	, ingredient_concept_id 
52 	, drug_exposure_start_date 
53 	, days_supply 
54 	, drug_exposure_end_date 
55 	, datediff(day, drug_exposure_start_date, drug_exposure_end_date) AS days_of_exposure ---Calculates the days of exposure to the drug so at the end we can subtract the SUM of these days from the total days in the era. 
56 into #cteDrugTarget1 FROM  #cteDrugPreTarget; 
57 
 
58 
 
59 --------------------------------------------#cteEndDates1 
60 SELECT 
61 	person_id 
62 	, ingredient_concept_id 
63 	, dateadd(day, -30, event_date) AS end_date -- unpad the end date 
64 into #cteEndDates1 FROM 
65 ( 
66 	SELECT 
67 		person_id 
68 		, ingredient_concept_id 
69 		, event_date 
70 		, event_type 
71 		, MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id ORDER BY event_date, event_type ROWS unbounded preceding) AS start_ordinal -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with 
72 		, ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id ORDER BY event_date, event_type) AS overall_ord -- this re-numbers the inner UNION so all rows are numbered ordered by the event date 
73 	FROM ( 
74 		-- select the start dates, assigning a row number to each 
75 		SELECT 
76 			person_id 
77 			, ingredient_concept_id 
78 			, drug_exposure_start_date AS event_date 
79 			, -1 AS event_type 
80 			, ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id ORDER BY drug_exposure_start_date) AS start_ordinal 
81 		FROM #cteDrugTarget1 
82 	 
83 		UNION ALL 
84 	 
85 		-- pad the end dates by 30 to allow a grace period for overlapping ranges. 
86 		SELECT 
87 			person_id 
88 			, ingredient_concept_id 
89 			, dateadd(day,30,drug_exposure_end_date) 
90 			, 1 AS event_type 
91 			, NULL 
92 		FROM #cteDrugTarget1 
93 	) RAWDATA 
94 ) e 
95 WHERE (2 * e.start_ordinal) - e.overall_ord = 0; 
96 
 
97 	 
98 --------------------------------------------#cteDrugExposureEnds1 
99 SELECT  
100 	   dt.person_id 
101 	   , dt.ingredient_concept_id as drug_concept_id 
102 	   , dt.drug_exposure_start_date 
103 	   , MIN(e.end_date) AS drug_era_end_date 
104 	   , dt.days_of_exposure AS days_of_exposure 
105 into #cteDrugExposureEnds1 FROM #cteDrugTarget1 dt 
106 						JOIN #cteEndDates1 e  
107 						ON dt.person_id = e.person_id AND  
108 						dt.ingredient_concept_id = e.ingredient_concept_id  
109 						AND e.end_date >= dt.drug_exposure_start_date 
110 GROUP BY  
111 		  dt.drug_exposure_id 
112 		  , dt.person_id 
113 	  , dt.ingredient_concept_id 
114 	  , dt.drug_exposure_start_date 
115 	  , dt.days_of_exposure; 
116 
 
117 		   
118 /************************************** 
119  3. 2단계: drug_era에 데이터 입력 
120 ***************************************/  
121 
 
122 INSERT INTO @ResultDatabaseSchema.drug_era (person_id, drug_concept_id, drug_era_start_date, drug_era_end_date, drug_exposure_count, gap_days) 
123 SELECT 
124 	person_id 
125 	, drug_concept_id 
126 	, MIN(drug_exposure_start_date) AS drug_era_start_date 
127 	, drug_era_end_date 
128 	, COUNT(*) AS drug_exposure_count 
129 	, DATEDIFF(DAY, MIN(drug_exposure_start_date),drug_era_end_date) -SUM(days_of_exposure) AS gap_days 
130 	/*, EXTRACT(EPOCH FROM (drug_era_end_date - MIN(drug_exposure_start_date)) - SUM(days_of_exposure))/86400 AS gap_day 
131 			  ---dividing by 86400 puts the integer in the "units" of days. 
132 			  ---There are no actual units on this, it is just an integer, but we want it to represent days and dividing by 86400 does that.*/ 
133 FROM #cteDrugExposureEnds1 
134 GROUP BY person_id, drug_concept_id, drug_era_end_date 
135 ORDER BY person_id, drug_concept_id; 
