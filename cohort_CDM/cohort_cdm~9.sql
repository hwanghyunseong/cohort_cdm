1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 조재형 
4  --Date: 2017.02.15 
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
19  --Description: device 테이블 생성 
20 			   1) device_exposure_end_date는 drug_exposure의 end_date와 같은 방법으로 생성 
21 			   2) quantity의 경우 단가(UN_COST) 혹은 금액(AMT)이 비정상이거나, 사용량(DD_MQTY_EXEC_FREQ, MDCN_EXEC_FREQ, DD_MQTY_FREQ)이 비정상인 경우가 많고, 
22 				  정수가 아닌 경우가 많음(메디폼을 잘라서 쓰는 경우 등)  
23 					1. 단가(UN_COST)와 금액(AMT)이 정상인 경우 (Null이 아니거나 0원이 아닌 경우) AMT/UN_COST 
24 					2. 단가(UN_COST)와 금액(AMT)이 정상이 아닌 경우(0, Null, UN_COST>AMT) 30t의 경우 사용량(DD_MQTY_EXEC_FREQ, MDCN_EXEC_FREQ, DD_MQTY_FREQ)의 곱으로, 
25 					   60t의 경우 사용량 (DD_EXEC_FREQ, MDCN_EXEC_FREQ, DD_MQTY_FREQ)의 곱으로 계산 
26 					3. 단가, 금액, 사용량 모두 비정상(0인 경우)일 경우 1로 정의 
27  --Generating Table: Device_exposure 
28 ***************************************/ 
29 
 
30 /************************************** 
31  1. 테이블 생성  
32 ***************************************/  
33   
34 
 
35 CREATE TABLE @ResultDatabaseSchema.DEVICE_EXPOSURE (  
36      device_exposure_id				BIGINT	 		PRIMARY KEY ,  
37      person_id						INTEGER			NOT NULL ,  
38      divce_concept_id				INTEGER			NOT NULL ,  
39      device_exposure_start_date		DATE			NOT NULL ,  
40      device_exposure_end_date		DATE			NULL ,  
41      device_type_concept_id			INTEGER			NOT NULL ,  
42      unique_device_id				VARCHAR(20)		NULL ,  
43      quantity						float			NULL ,  
44      provider_id					INTEGER			NULL ,  
45      visit_occurrence_id			BIGINT			NULL ,  
46 	 device_source_value			VARCHAR(50)		NULL , 
47 	 device_source_concept_id		integer			NULL  
48     ); 
49 
 
50 /************************************** 
51  2. 데이터 입력 및 확인 (30t : 8515647개 행이 영향을 받음, 03:53, 매핑이 안돼서/ 60t : 72개 행이 영향을 받음, 00:48, 매핑이 안돼서) 총 8,515,719건 
52 ***************************************/   
53 
 
54 --30t 입력 (8515647개 행이 영향을 받음) 02:51 
55 insert into @ResultDatabaseSchema.DEVICE_EXPOSURE 
56 (device_exposure_id, person_id, divce_concept_id, device_exposure_start_date,  
57 device_exposure_end_date, device_type_concept_id, unique_device_id, quantity,  
58 provider_id, visit_occurrence_id, device_source_value, device_source_concept_id) 
59 select	convert(bigint, convert(varchar, a.master_seq) + convert(varchar, row_number() over (partition by a.key_seq, a.seq_no order by b.concept_id))) as device_exposure_id, 
60 		a.person_id as person_id, 
61 		b.concept_id as device_concept_id , 
62 		CONVERT(VARCHAR, a.recu_fr_dt, 23) as device_source_start_date, 
63 		CONVERT(VARCHAR, DATEADD(DAY, a.mdcn_exec_freq-1, a.recu_fr_dt),23) as device_source_end_date, 
64 		44818705 as device_type_concept_id, 
65 		null as unique_device_id, 
66 case	when a.AMT is not null and cast(a.AMT as float) > 0 and a.UN_COST is not null and cast(a.UN_COST as float) > 0 and cast(a.AMT as float)>=cast(a.UN_COST as float) then cast(a.AMT as float)/cast(a.UN_COST as float) 
67 		when a.AMT is not null and cast(a.AMT as float) > 0 and a.UN_COST is not null and cast(a.UN_COST as float) > 0 and cast(a.UN_COST as float)>cast(a.AMT as float) then a.DD_MQTY_EXEC_FREQ * a.MDCN_EXEC_FREQ * a.DD_MQTY_FREQ  
68 		else a.DD_MQTY_EXEC_FREQ * a.MDCN_EXEC_FREQ * a.DD_MQTY_FREQ  
69 		end as quantity, 
70 		null as provider_id, 
71 		a.key_seq as visit_occurence_id, 
72 		a.div_cd as device_source_value, 
73 		null as device_source_concept_id 
74 
 
75 FROM  
76 	(SELECT x.key_seq, x.seq_no, x.recu_fr_dt, x.div_cd,  
77 			case when x.mdcn_exec_freq is not null and x.mdcn_exec_freq > '0' and isnumeric(x.mdcn_exec_freq)=1 then cast(x.mdcn_exec_freq as float) else 1 end as mdcn_exec_freq, 
78 			case when x.dd_mqty_exec_freq is not null and x.dd_mqty_exec_freq > '0' and isnumeric(x.dd_mqty_exec_freq)=1 then cast(x.dd_mqty_exec_freq as float) else 1 end as dd_mqty_exec_freq, 
79 			case when x.dd_mqty_freq is not null and x.dd_mqty_freq > '0' and isnumeric(x.dd_mqty_freq)=1 then cast(x.dd_mqty_freq as float) else 1 end as dd_mqty_freq, 
80 			cast(x.amt as float) as amt , cast(x.un_cost as float) as un_cost, y.master_seq, y.person_id 
81 	FROM @NHISDatabaseSchema.@NHIS_30T x, @ResultDatabaseSchema.SEQ_MASTER y 
82 	WHERE y.source_table='130' 
83 	AND x.key_seq=y.key_seq 
84 	AND x.seq_no=y.seq_no) a JOIN @ResultDatabaseSchema.@DEVICE_MAPPINGTABLE b  
85 ON a.div_cd=b.sourcecode 
86 
 
87 
 
88 
 
89 
 
90 --60t 입력 (72개 행이 영향을 받음) 00:46 
91 insert into @ResultDatabaseSchema.DEVICE_EXPOSURE 
92 (device_exposure_id, person_id, divce_concept_id, device_exposure_start_date,  
93 device_exposure_end_date, device_type_concept_id, unique_device_id, quantity,  
94 provider_id, visit_occurrence_id, device_source_value, device_source_concept_id) 
95 select	convert(bigint, convert(varchar, a.master_seq) + convert(varchar, row_number() over (partition by a.key_seq, a.seq_no order by b.concept_id))) as device_exposure_id, 
96 		a.person_id as person_id, 
97 		b.concept_id as device_concept_id , 
98 		CONVERT(VARCHAR, a.recu_fr_dt, 23) as device_source_start_date, 
99 		CONVERT(VARCHAR, DATEADD(DAY, a.mdcn_exec_freq-1, a.recu_fr_dt),23) as device_source_end_date, 
100 		44818705 as device_type_concept_id, 
101 		null as unique_device_id, 
102 case	when a.AMT is not null and cast(a.AMT as float) > 0 and a.UN_COST is not null and cast(a.UN_COST as float) > 0 and cast(a.AMT as float)>=cast(a.UN_COST as float) then cast(a.AMT as float)/cast(a.UN_COST as float) 
103 		when a.AMT is not null and cast(a.AMT as float) > 0 and a.UN_COST is not null and cast(a.UN_COST as float) > 0 and cast(a.UN_COST as float)>cast(a.AMT as float) then a.MDCN_EXEC_FREQ * a.DD_MQTY_FREQ * a.DD_EXEC_FREQ 
104 		else a.MDCN_EXEC_FREQ * a.DD_MQTY_FREQ * a.DD_EXEC_FREQ 
105 		end as quantity, 
106 		null as provider_id, 
107 		a.key_seq as visit_occurence_id, 
108 		a.div_cd as device_source_value, 
109 		null as device_source_concept_id 
110 
 
111 FROM  
112 	(SELECT x.key_seq, x.seq_no, x.recu_fr_dt, x.div_cd,  
113 			case when x.mdcn_exec_freq is not null and x.mdcn_exec_freq > '0' and isnumeric(x.mdcn_exec_freq)=1 then cast(x.mdcn_exec_freq as float) else 1 end as mdcn_exec_freq, 
114 			case when x.dd_mqty_freq is not null and x.dd_mqty_freq > '0' and isnumeric(x.dd_mqty_freq)=1 then cast(x.dd_mqty_freq as float) else 1 end as dd_mqty_freq, 
115 			case when x.dd_exec_freq is not null and x.dd_exec_freq > '0' and isnumeric(x.dd_exec_freq)=1 then cast(x.dd_exec_freq as float) else 1 end as dd_exec_freq, 
116 			cast(x.amt as float) as amt , cast(x.un_cost as float) as un_cost, y.master_seq, y.person_id 
117 	FROM @NHISDatabaseSchema.@NHIS_60T x, @ResultDatabaseSchema.SEQ_MASTER y 
118 	WHERE y.source_table='160' 
119 	AND x.key_seq=y.key_seq 
120 	AND x.seq_no=y.seq_no) a JOIN @ResultDatabaseSchema.@DEVICE_MAPPINGTABLE b 
121 ON a.div_cd=b.sourcecode 
122 
 
123 
 
124 -- quantity가 0인 경우 1로 변경 (6268개 행이 영향을 받음) 00:04 
125 update @ResultDatabaseSchema.DEVICE_EXPOSURE 
126 set quantity = 1 
127 where quantity = 0 
128 
 
129 
 
130 
 
131 /******************* quantity 0인 경우 1로 변경하기 전 결과 확인********************* 
132 select * from @ResultDatabaseSchema.device_exposure where quantity=0 -- 변경 전 -> 6268(정맥내유치침5275건) / 변경 후 -> 0 
133 select * from @ResultDatabaseSchema.device_exposure where quantity=1 -- 변경 전 -> 4548117 / 변경 후 -> 4554385 
134 *************************************************************************************/ 
