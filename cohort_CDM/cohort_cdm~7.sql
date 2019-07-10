1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 이성원 
4  --Date: 2017.02.08 
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
16   
17  --Description: Drug_exposure 테이블 생성 
18 			   * 30T(진료), 60T(처방전) 테이블에서 각각 ETL을 수행해야 함 
19  --Generating Table: DRUG_EXPOSURE 
20 ***************************************/ 
21 
 
22 /************************************** 
23  1. 사전 준비 
24 ***************************************/  
25 -- 1) 30T의 항/목 코드 현황 체크매핑 
26 select clause_cd, item_cd, count(clause_cd) 
27 from @NHISDatabaseSchema.@NHIS_30T 
28 group by clause_cd, item_cd 
29 
 
30 --> 결과는 "08. 참고) 30T, 60T의 코드 분석.xlsx" 참고 
31 
 
32 
 
33 -- 2) 30T의 계산식에 들어갈 숫자 데이터 정합성 체크 
34 -- 1일 투여량 또는 실시 횟수 
35 select dd_mqty_exec_freq, count(dd_mqty_exec_freq) as cnt 
36 from @NHISDatabaseSchema.@NHIS_30T 
37 where dd_mqty_exec_freq is not null and ISNUMERIC(dd_mqty_exec_freq) = 0 
38 group by dd_mqty_exec_freq 
39 
 
40 -- 총투여일수 또는 실시횟수 
41 select mdcn_exec_freq, count(mdcn_exec_freq) as cnt 
42 from @NHISDatabaseSchema.@NHIS_30T 
43 where mdcn_exec_freq is not null and ISNUMERIC(mdcn_exec_freq) = 0 
44 group by mdcn_exec_freq 
45 
 
46 -- 1회 투약량 
47 select dd_mqty_freq, count(dd_mqty_freq) as cnt 
48 from @NHISDatabaseSchema.@NHIS_30T 
49 where dd_mqty_freq is not null and ISNUMERIC(dd_mqty_freq) = 0 
50 group by dd_mqty_freq 
51 
 
52 --> 결과는 "08. 참고) 30T, 60T의 코드 분석.xlsx" 참고 
53 
 
54 
 
55 -- 3) 60T의 계산식에 들어갈 숫자 데이터 정합성 체크 
56 -- 1회 투약량 
57 select dd_mqty_freq, count(dd_mqty_freq) as cnt 
58 from @NHISDatabaseSchema.@NHIS_60T 
59 where dd_mqty_freq is not null and ISNUMERIC(dd_mqty_freq) = 0 
60 group by dd_mqty_freq 
61 
 
62 -- 1일 투약량 
63 select dd_exec_freq, count(dd_exec_freq) as cnt 
64 from @NHISDatabaseSchema.@NHIS_60T 
65 where dd_exec_freq is not null and ISNUMERIC(dd_exec_freq) = 0 
66 group by dd_exec_freq 
67 
 
68 -- 총투여일수 또는 실시횟수 
69 select mdcn_exec_freq, count(mdcn_exec_freq) as cnt 
70 from @NHISDatabaseSchema.@NHIS_60T 
71 where mdcn_exec_freq is not null and ISNUMERIC(mdcn_exec_freq) = 0 
72 group by mdcn_exec_freq 
73 
 
74 --> 결과는 "08. 참고) 30T, 60T의 코드 분석.xlsx" 참고 
75 
 
76 
 
77 -- 4) 매핑 테이블의 약코드 1:N 건수 체크 
78 select source_code, count(source_code) 
79 from @ResultDatabaseSchema.@DRUG_MAPPINGTABLE 
80 group by source_code 
81 having count(source_code)>1 
82 --> 1:N 매핑 약코드 없음 
83 
 
84 
 
85 -- 5) 변환 예상 건수 파악 
86 select count(a.key_seq) 
87 from @NHISDatabaseSchema.@NHIS_30T a, @ResultDatabaseSchema.@DRUG_MAPPINGTABLE b, @NHISDatabaseSchema.@NHIS_20T c 
88 where a.div_cd=b.source_code 
89 and a.key_seq=c.key_seq 
90 
 
91 select count(a.key_seq) 
92 from @NHISDatabaseSchema.@NHIS_60T a, @ResultDatabaseSchema.@DRUG_MAPPINGTABLE b, @NHISDatabaseSchema.@NHIS_20T c 
93 where a.div_cd=b.source_code 
94 and a.key_seq=c.key_seq 
95 
 
96 
 
97 /************************************** 
98  1.1. drug_exposure_end_date 계산 방법을 정하기 위해 실행한 쿼리들 (2017.02.17 by 유승찬) 
99 ***************************************/  
100 
 
101 select a.person_id, a.drug_exposure_id, a.drug_exposure_start_date, a.drug_exposure_end_date, b.observation_period_start_date, b.observation_period_end_date, c.death_date 
102 from drug_exposure a, observation_period b, death C 
103 where a.person_id=b.person_id 
104 and a.person_id = c.person_id 
105 and (a.drug_exposure_start_date < b.observation_period_start_date 
106 or a.drug_exposure_end_date > b.observation_period_end_date) 
107 
 
108 select b.concept_name, x.* 
109 from  
110 (select A.*, B.concept_id 
111 from @NHISDatabaseSchema.@NHIS_30T AS A 
112 join @ResultDatabaseSchema.@DRUG_MAPPINGTABLE B 
113 on A.div_cd=b.source_code  
114    where cast(DD_MQTY_EXEC_FREQ as float)<1 
115    and cast(DD_MQTY_EXEC_FREQ as float)>=0) x 
116    join @ResultDatabaseSchema.concept b 
117    on x.concept_id= b.concept_id 
118 
 
119 select b.concept_name, x.* 
120 from  
121 (select A.*, B.concept_id 
122 from @NHISDatabaseSchema.@NHIS_30T AS A 
123 join @ResultDatabaseSchema.@DRUG_MAPPINGTABLE B 
124 on A.div_cd=b.source_code  
125    where cast(DD_MQTY_EXEC_FREQ as float)>1) x 
126    join @ResultDatabaseSchema.concept b 
127    on x.concept_id= b.concept_id 
128 
 
129 
 
130 select b.concept_name, x.* 
131 from  
132 (select A.*, B.concept_id 
133 from @NHISDatabaseSchema.@NHIS_60T AS A 
134 join @ResultDatabaseSchema.@DRUG_MAPPINGTABLE B 
135 on A.div_cd=b.source_code  
136    where cast(DD_MQTY_FREQ as float)>1) x 
137    join @NHISDatabaseSchema.concept b 
138    on x.concept_id= b.concept_id 
139 
 
140 
 
141 /************************************** 
142  2. 테이블 생성 
143 ***************************************/   
144 CREATE TABLE @ResultDatabaseSchema.DRUG_EXPOSURE (  
145      drug_exposure_id				BIGINT	 	NOT NULL ,  
146      person_id						INTEGER			NOT NULL ,  
147      drug_concept_id				INTEGER			NULL ,  
148      drug_exposure_start_date		DATE			NOT NULL ,  
149      drug_exposure_end_date			DATE			NULL ,  
150      drug_type_concept_id			INTEGER			NOT NULL ,  
151      stop_reason					VARCHAR(20)		NULL ,  
152      refills						INTEGER			NULL ,  
153      quantity						FLOAT			NULL ,  
154      days_supply					INTEGER			NULL ,  
155      sig							VARCHAR(MAX)	NULL ,  
156 	 route_concept_id				INTEGER			NULL , 
157 	 effective_drug_dose			FLOAT			NULL , 
158 	 dose_unit_concept_id			INTEGER			NULL , 
159 	 lot_number						VARCHAR(50)		NULL , 
160      provider_id					INTEGER			NULL ,  
161      visit_occurrence_id			BIGINT			NULL ,  
162      drug_source_value				VARCHAR(50)		NULL , 
163 	 drug_source_concept_id			INTEGER			NULL , 
164 	 route_source_value				VARCHAR(50)		NULL , 
165 	 dose_unit_source_value			VARCHAR(50)		NULL 
166     ); 
167 
 
168 	 
169 /************************************** 
170  3. 30T를 이용하여 데이터 입력 
171 ***************************************/   
172 insert into @ResultDatabaseSchema.DRUG_EXPOSURE  
173 (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date,  
174 drug_type_concept_id, stop_reason, refills, quantity, days_supply,  
175 sig, route_concept_id, effective_drug_dose, dose_unit_concept_id, lot_number, 
176 provider_id, visit_occurrence_id, drug_source_value, drug_source_concept_id, route_source_value,  
177 dose_unit_source_value) 
178 SELECT convert(bigint, convert(varchar, a.master_seq) + convert(varchar, row_number() over (partition by a.key_seq, a.seq_no order by b.concept_id))) as drug_exposure_id, 
179 	a.person_id as person_id, 
180 	b.concept_id as drug_concept_id, 
181 	CONVERT(date, a.recu_fr_dt, 112) as drug_exposure_start_date, 
182 	--DATEADD(day, CEILING(convert(float, a.mdcn_exec_freq)/convert(float, a.dd_mqty_exec_freq))-1, convert(date, a.recu_fr_dt, 112)) as drug_exposure_end_date, (수정: 2017.02.17 by 이성원) 
183 	DATEADD(day, convert(float, a.mdcn_exec_freq)-1, convert(date, a.recu_fr_dt, 112)) as drug_exposure_end_date, 
184 	38000180 as drug_type_concept_id, 
185 	NULL as stop_reason, 
186 	NULL as refills, 
187 	convert(float, a.dd_mqty_exec_freq) * convert(float, a.mdcn_exec_freq) * convert(float, a.dd_mqty_freq) as quantity, 
188 	a.mdcn_exec_freq as days_supply, 
189 	a.clause_cd as sig, 
190 	CASE  
191 		WHEN a.clause_cd='03' and a.item_cd='01' then 4128794 -- oral 
192 		WHEN a.clause_cd='03' and a.item_cd='02' then 45956875 -- not applicable 
193 		WHEN a.clause_cd='04' and a.item_cd='01' then 4139962 -- Subcutaneous 
194 		WHEN a.clause_cd='04' and a.item_cd='02' then 4112421 -- intravenous 
195 		WHEN a.clause_cd='04' and a.item_cd='03' then 4112421 
196 		ELSE 0 
197 	END as route_concept_id, 
198 	NULL as effective_drug_dose, 
199 	NULL as dose_unit_concept_id, 
200 	NULL as lot_number, 
201 	NULL as provider_id, 
202 	a.key_seq as visit_occurrence_id, 
203 	a.div_cd as drug_source_value, 
204 	null as drug_source_concept_id, 
205 	a.clause_cd + '/' + a.item_cd as route_source_value, 
206 	NULL as dose_unit_source_value 
207 FROM  
208 	(SELECt x.key_seq, x.seq_no, x.recu_fr_dt, x.div_cd, 
209 			case when x.mdcn_exec_freq is not null and isnumeric(x.mdcn_exec_freq)=1 and cast(x.mdcn_exec_freq as float) > '0' then cast(x.mdcn_exec_freq as float) else 1 end as mdcn_exec_freq, 
210 			case when x.dd_mqty_exec_freq is not null and isnumeric(x.dd_mqty_exec_freq)=1 and cast(x.dd_mqty_exec_freq as float) > '0' then cast(x.dd_mqty_exec_freq as float) else 1 end as dd_mqty_exec_freq, 
211 			case when x.dd_mqty_freq is not null and isnumeric(x.dd_mqty_freq)=1 and cast(x.dd_mqty_freq as float) > '0' then cast(x.dd_mqty_freq as float) else 1 end as dd_mqty_freq, 
212 			case when x.clause_cd is not null and len(x.clause_cd) = 1 and isnumeric(x.clause_cd)=1 and convert(int, x.clause_cd) between 1 and 9 then '0' + x.clause_cd else x.clause_cd end as clause_cd, 
213 			case when x.item_cd is not null and len(x.item_cd) = 1 and isnumeric(x.item_cd)=1 and convert(int, x.item_cd) between 1 and 9 then '0' + x.item_cd else x.item_cd end as item_cd, 
214 			y.master_seq, y.person_id			 
215 	FROM @NHISDatabaseSchema.@NHIS_30T x,  
216 	     (select master_seq, person_id, key_seq, seq_no from seq_master where source_Table='130') y 
217 	WHERE x.key_seq=y.key_seq 
218 	AND x.seq_no=y.seq_no) a, 
219 	@ResultDatabaseSchema.@DRUG_MAPPINGTABLE b 
220 where a.div_cd=b.source_code 
221 
 
222 
 
223 /************************************** 
224  4. 60T를 이용하여 데이터 입력 
225 ***************************************/ 
226 insert into DRUG_EXPOSURE  
227 (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date,  
228 drug_type_concept_id, stop_reason, refills, quantity, days_supply,  
229 sig, route_concept_id, effective_drug_dose, dose_unit_concept_id, lot_number, 
230 provider_id, visit_occurrence_id, drug_source_value, drug_source_concept_id, route_source_value,  
231 dose_unit_source_value) 
232 SELECT convert(bigint, convert(varchar, a.master_seq) + convert(varchar, row_number() over (partition by a.key_seq, a.seq_no order by b.concept_id))) as drug_exposure_id, 
233 	a.person_id as person_id, 
234 	b.concept_id as drug_concept_id, 
235 	CONVERT(date, a.recu_fr_dt, 112) as drug_exposure_start_date, 
236 	-- DATEADD(day, CEILING(convert(float, a.mdcn_exec_freq)/convert(float, a.dd_exec_freq))-1, convert(date, a.recu_fr_dt, 112)) as drug_exposure_end_date, (수정: 2017.02.17 by 이성원) 
237 	DATEADD(day, convert(float, a.mdcn_exec_freq)-1, convert(date, a.recu_fr_dt, 112)) as drug_exposure_end_date, 
238 	38000177 as drug_type_concept_id, 
239 	NULL as stop_reason, 
240 	NULL as refills, 
241 	convert(float, a.dd_mqty_freq) * convert(float, a.dd_exec_freq) * convert(float, a.mdcn_exec_freq) as quantity, 
242 	a.mdcn_exec_freq as days_supply, 
243 	null as sig, 
244 	null as route_concept_id, 
245 	NULL as effective_drug_dose, 
246 	NULL as dose_unit_concept_id, 
247 	NULL as lot_number, 
248 	NULL as provider_id, 
249 	a.key_seq as visit_occurrence_id, 
250 	a.div_cd as drug_source_value, 
251 	null as drug_source_concept_id, 
252 	null as route_source_value, 
253 	NULL as dose_unit_source_value 
254 FROM  
255 	(SELECt x.key_seq, x.seq_no, x.recu_fr_dt, x.div_cd, 
256 			case when x.mdcn_exec_freq is not null and isnumeric(x.mdcn_exec_freq)=1 and cast(x.mdcn_exec_freq as float) > '0' then cast(x.mdcn_exec_freq as float) else 1 end as mdcn_exec_freq, 
257 			case when x.dd_mqty_freq is not null and isnumeric(x.dd_mqty_freq)=1 and cast(x.dd_mqty_freq as float) > '0' then cast(x.dd_mqty_freq as float) else 1 end as dd_mqty_freq, 
258 			case when x.dd_exec_freq is not null and isnumeric(x.dd_exec_freq)=1 and cast(x.dd_exec_freq as float) > '0' then cast(x.dd_exec_freq as float) else 1 end as dd_exec_freq, 
259 			y.master_seq, y.person_id			 
260 	FROM @NHISDatabaseSchema.@NHIS_60T x,  
261 	     (select master_seq, person_id, key_seq, seq_no from seq_master where source_Table='160') y 
262 	WHERE x.key_seq=y.key_seq 
263 	AND x.seq_no=y.seq_no) a, 
264 	@ResultDatabaseSchema.@DRUG_MAPPINGTABLE b 
265 where a.div_cd=b.source_code 
266 
 
267 
 
268 
 
269 /************************************** 
270  5. drug_start_date가 사망일자 이전인 데이터 삭제 
271     총 1,042 건 
272 ***************************************/ 
273 delete from a 
274 from drug_exposure a, death b 
275 where a.person_id=b.person_id 
276 and b.death_date < a.drug_exposure_start_date 
277 
 
278 
 
279 
 
280 /************************************** 
281  6. drug_end_date가 사장일자 이전인 데이터의 drug_end_date를 사망일자로 변경 
282     총 39,186 건 
283 ***************************************/ 
284 update a 
285 set drug_exposure_end_date=b.death_date 
286 from drug_exposure a, death b 
287 where a.person_id=b.person_id 
288 and (b.death_date < a.drug_exposure_start_date 
289 or b.death_date < a.drug_exposure_end_date) 
290 
 
291 
 
292 ------------------------------------------- 
293 참고) http://tennesseewaltz.tistory.com/236 
294 UPDATE A 
295       SET A.SEQ     = B.CMT_NO 
296         , A.CarType = B.CAR_TYPE 
297      FROM TABLE_AAA A 
298           JOIN TABLE_BBB B ON A.OPCode = B.OP_CODE 
299     WHERE A.LineCode = '조건' 
300 ------------------------------------------- 
