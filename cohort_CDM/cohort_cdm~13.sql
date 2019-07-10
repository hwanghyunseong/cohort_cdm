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
16 @PROCEDURE_MAPPINGTABLE : mapping table between Korean procedure and OMOP vocabulary 
17 @DEVICE_MAPPINGTABLE : mapping table between EDI and OMOP vocabulary 
18   
19  --Description: Cost 테이블 생성 
20  --Generating Table: COST 
21 ***************************************/ 
22 
 
23 /************************************** 
24  1. 테이블 생성 
25 ***************************************/  
26 CREATE TABLE @ResultDatabaseSchema.COST ( 
27 	cost_id	bigint	primary key, 
28 	cost_event_id	bigint	not null, 
29 	cost_domain_id	varchar(20)	not null, 
30 	cost_type_concept_id	integer	not null, 
31 	currency_concept_id	integer, 
32 	total_charge	float, 
33 	total_cost	float, 
34 	total_paid	float, 
35 	paid_by_payer	float, 
36 	paid_by_patient	float, 
37 	paid_patient_copay	float, 
38 	paid_patient_coinsurance	float, 
39 	paid_patient_deductiable	float, 
40 	paid_by_primary	float, 
41 	paid_ingredient_cost	float, 
42 	paid_dispensing_fee	float, 
43 	payer_plan_period_id	bigint, 
44 	amount_allowed	float, 
45 	revenue_code_concept_id	integer, 
46 	drg_concept_id	integer, 
47 	revenue_code_source_value	varchar(50), 
48 	drg_source_value	varchar(50) 
49 ); 
50 
 
51 /************************************** 
52  2. 데이터 입력 
53     1) Visit 
54 	2) Drug 
55 	3) Procedure 
56 	4) Device 
57 ***************************************/  
58 
 
59 --------------------------------------------------- 
60 -- 1) Visit 
61 --------------------------------------------------- 
62 INSERT INTO @ResultDatabaseSchema.COST 
63 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
64 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
65 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
66 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
67 	revenue_code_source_value, drg_source_value) 
68 SELECT  
69 	a.visit_occurrence_id as cost_id, 
70 	a.visit_occurrence_id as cost_event_id, 
71 	'Visit' as cost_domain_id, 
72 	5031 as cost_type_concept_id, 
73 	44818598 as currency_concept_id, 
74 	b.dmd_tramt as total_charge, 
75 	null as total_cost, 
76 	b.edec_tramt as total_paid, 
77 	b.edec_jbrdn_amt as paid_by_payer, 
78 	b.edec_sbrdn_amt as paid_by_patient, 
79 	null as paid_patient_copay, 
80 	null as paid_patient_coinsurance,  
81 	null as paid_patient_deductiable, 
82 	null as paid_by_primary, 
83 	null as paid_ingredient_cost, 
84 	null as paid_dispensing_fee, 
85 	convert(bigint, convert(varchar, a.person_id) + left(convert(varchar, visit_start_date, 112), 4)) as payer_plan_period_id, 
86 	null as amount_allowed, 
87 	null as revenue_code_concept_id, 
88 	null as drg_concept_id, 
89 	null as revenue_code_source_value, 
90 	b.dmd_drg_no as drg_source_value 
91 from visit_occurrence a, @NHISDatabaseSchema.@NHIS_20T b 
92 where a.visit_occurrence_id=b.key_seq 
93 and a.person_id=b.person_id; 
94 
 
95 
 
96 
 
97 --------------------------------------------------- 
98 -- 2) Drug 
99 --------------------------------------------------- 
100 
 
101 -- 원본 테이블이 30T인 경우 
102 INSERT INTO COST 
103 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
104 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
105 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
106 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
107 	revenue_code_source_value, drg_source_value) 
108 SELECT  
109 	a.drug_exposure_id as cost_id, 
110 	a.drug_exposure_id as cost_event_id, 
111 	'Drug' as cost_domain_id, 
112 	5031 as cost_type_concept_id, 
113 	44818598 as currency_concept_id, 
114 	null as total_charge, 
115 	b.amt as total_cost, 
116 	null as total_paid, 
117 	null as paid_by_payer, 
118 	null as paid_by_patient, 
119 	null as paid_patient_copay, 
120 	null as paid_patient_coinsurance,  
121 	null as paid_patient_deductiable, 
122 	null as paid_by_primary, 
123 	null as paid_ingredient_cost, 
124 	null as paid_dispensing_fee, 
125 	convert(bigint, convert(varchar, b.person_id) + left(convert(varchar, a.drug_exposure_start_date, 112), 4)) as payer_plan_period_id, 
126 	null as amount_allowed, 
127 	null as revenue_code_concept_id, 
128 	null as drg_concept_id, 
129 	null as revenue_code_source_value, 
130 	null as drg_source_value 
131 from (select person_id, drug_exposure_id, drug_exposure_start_date 
132 	from drug_exposure 
133 	where drug_type_concept_id=38000180) a,  
134 	(select m.master_seq, m.key_seq, m.seq_no, m.person_id, n.amt 
135 	from seq_master m, @NHISDatabaseSchema.@NHIS_30T n 
136 	where m.source_table='130' 
137 	and m.key_seq=n.key_seq 
138 	and m.seq_no=n.seq_no) b 
139 where left(a.drug_exposure_id, 10)=b.master_seq 
140 and a.person_id=b.person_id; 
141 
 
142 
 
143 -- 원본 테이블이 60T인 경우 
144 INSERT INTO COST 
145 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
146 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
147 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
148 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
149 	revenue_code_source_value, drg_source_value) 
150 SELECT  
151 	a.drug_exposure_id as cost_id, 
152 	a.drug_exposure_id as cost_event_id, 
153 	'Drug' as cost_domain_id, 
154 	5031 as cost_type_concept_id, 
155 	44818598 as currency_concept_id, 
156 	null as total_charge, 
157 	b.amt as total_cost, 
158 	null as total_paid, 
159 	null as paid_by_payer, 
160 	null as paid_by_patient, 
161 	null as paid_patient_copay, 
162 	null as paid_patient_coinsurance,  
163 	null as paid_patient_deductiable, 
164 	null as paid_by_primary, 
165 	null as paid_ingredient_cost, 
166 	null as paid_dispensing_fee, 
167 	convert(bigint, convert(varchar, b.person_id) + left(convert(varchar, a.drug_exposure_start_date, 112), 4)) as payer_plan_period_id, 
168 	null as amount_allowed, 
169 	null as revenue_code_concept_id, 
170 	null as drg_concept_id, 
171 	null as revenue_code_source_value, 
172 	null as drg_source_value 
173 from (select person_id, drug_exposure_id, drug_exposure_start_date 
174 	from drug_exposure 
175 	where drug_type_concept_id=38000177) a,  
176 	(select m.master_seq, m.key_seq, m.seq_no, m.person_id, n.amt 
177 	from (select master_seq, key_seq, seq_no, person_id from seq_master where source_table='160') m,  
178 	@NHISDatabaseSchema.@NHIS_60T n 
179 	where m.key_seq=n.key_seq 
180 	and m.seq_no=n.seq_no) b 
181 where b.master_seq=left(a.drug_exposure_id, 10) 
182 and a.person_id=b.person_id; 
183 
 
184 
 
185 --------------------------------------------------- 
186 -- 3) Procedure 
187 --------------------------------------------------- 
188 
 
189 -- 원본 테이블이 30T인 경우 
190 INSERT INTO COST 
191 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
192 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
193 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
194 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
195 	revenue_code_source_value, drg_source_value) 
196 SELECT  
197 	a.procedure_occurrence_id as cost_id, 
198 	a.procedure_occurrence_id as cost_event_id, 
199 	'Procedure' as cost_domain_id, 
200 	5031 as cost_type_concept_id, 
201 	44818598 as currency_concept_id, 
202 	null as total_charge, 
203 	b.amt as total_cost, 
204 	null as total_paid, 
205 	null as paid_by_payer, 
206 	null as paid_by_patient, 
207 	null as paid_patient_copay, 
208 	null as paid_patient_coinsurance,  
209 	null as paid_patient_deductiable, 
210 	null as paid_by_primary, 
211 	null as paid_ingredient_cost, 
212 	null as paid_dispensing_fee, 
213 	convert(bigint, convert(varchar, b.person_id) + left(convert(varchar, a.procedure_date, 112), 4)) as payer_plan_period_id, 
214 	null as amount_allowed, 
215 	null as revenue_code_concept_id, 
216 	null as drg_concept_id, 
217 	null as revenue_code_source_value, 
218 	null as drg_source_value 
219 from procedure_occurrence a,  
220 	(select m.master_seq, m.key_seq, m.seq_no, m.person_id, n.amt 
221 	from seq_master m, @NHISDatabaseSchema.@NHIS_30T n 
222 	where m.source_table='130' 
223 	and m.key_seq=n.key_seq 
224 	and m.seq_no=n.seq_no) b 
225 where left(a.procedure_occurrence_id, 10)=b.master_seq 
226 and a.person_id=b.person_id; 
227 
 
228 
 
229 -- 원본 테이블이 60T인 경우 
230 INSERT INTO COST 
231 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
232 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
233 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
234 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
235 	revenue_code_source_value, drg_source_value) 
236 SELECT  
237 	a.procedure_occurrence_id as cost_id, 
238 	a.procedure_occurrence_id as cost_event_id, 
239 	'Procedure' as cost_domain_id, 
240 	5031 as cost_type_concept_id, 
241 	44818598 as currency_concept_id, 
242 	null as total_charge, 
243 	b.amt as total_cost, 
244 	null as total_paid, 
245 	null as paid_by_payer, 
246 	null as paid_by_patient, 
247 	null as paid_patient_copay, 
248 	null as paid_patient_coinsurance,  
249 	null as paid_patient_deductiable, 
250 	null as paid_by_primary, 
251 	null as paid_ingredient_cost, 
252 	null as paid_dispensing_fee, 
253 	convert(bigint, convert(varchar, b.person_id) + left(convert(varchar, a.procedure_date, 112), 4)) as payer_plan_period_id, 
254 	null as amount_allowed, 
255 	null as revenue_code_concept_id, 
256 	null as drg_concept_id, 
257 	null as revenue_code_source_value, 
258 	null as drg_source_value 
259 from procedure_occurrence a,  
260 	(select m.master_seq, m.key_seq, m.seq_no, m.person_id, n.amt 
261 	from (select master_seq, key_seq, seq_no, person_id from seq_master where source_table='160') m,  
262 	@NHISDatabaseSchema.@NHIS_60T n 
263 	where m.key_seq=n.key_seq 
264 	and m.seq_no=n.seq_no) b 
265 where left(a.procedure_occurrence_id, 10)=b.master_seq 
266 and a.person_id=b.person_id; 
267 
 
268 
 
269 --------------------------------------------------- 
270 -- 4) Device 
271 --------------------------------------------------- 
272 
 
273 -- 원본 테이블이 30T인 경우 
274 INSERT INTO COST 
275 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
276 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
277 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
278 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
279 	revenue_code_source_value, drg_source_value) 
280 SELECT  
281 	a.device_exposure_id as cost_id, 
282 	a.device_exposure_id as cost_event_id, 
283 	'Device' as cost_domain_id, 
284 	5031 as cost_type_concept_id, 
285 	44818598 as currency_concept_id, 
286 	null as total_charge, 
287 	b.amt as total_cost, 
288 	null as total_paid, 
289 	null as paid_by_payer, 
290 	null as paid_by_patient, 
291 	null as paid_patient_copay, 
292 	null as paid_patient_coinsurance,  
293 	null as paid_patient_deductiable, 
294 	null as paid_by_primary, 
295 	null as paid_ingredient_cost, 
296 	null as paid_dispensing_fee, 
297 	convert(bigint, convert(varchar, b.person_id) + left(convert(varchar, a.device_exposure_start_date, 112), 4)) as payer_plan_period_id, 
298 	null as amount_allowed, 
299 	null as revenue_code_concept_id, 
300 	null as drg_concept_id, 
301 	null as revenue_code_source_value, 
302 	null as drg_source_value 
303 from (select device_exposure_id, person_id, device_exposure_start_date 
304 	from device_exposure  
305 	where device_source_value not in (select sourcecode from procedure_EDI_mapped_20161007)) a,  
306 	(select m.master_seq, m.key_seq, m.seq_no, m.person_id, n.amt 
307 	from seq_master m, @NHISDatabaseSchema.@NHIS_30T n 
308 	where m.source_table='130' 
309 	and m.key_seq=n.key_seq 
310 	and m.seq_no=n.seq_no) b 
311 where left(a.device_exposure_id, 10)=b.master_seq 
312 and a.person_id=b.person_id; 
313 
 
314 
 
315 -- 원본 테이블이 60T인 경우 
316 INSERT INTO COST 
317 	(cost_id, cost_event_id, cost_domain_id, cost_type_concept_id, currency_concept_id, 
318 	total_charge, total_cost, total_paid, paid_by_payer, paid_by_patient, 
319 	paid_patient_copay, paid_patient_coinsurance, paid_patient_deductiable, paid_by_primary, paid_ingredient_cost, 
320 	paid_dispensing_fee, payer_plan_period_id, amount_allowed, revenue_code_concept_id, drg_concept_id, 
321 	revenue_code_source_value, drg_source_value) 
322 SELECT  
323 	a.device_exposure_id as cost_id, 
324 	a.device_exposure_id as cost_event_id, 
325 	'Device' as cost_domain_id, 
326 	5031 as cost_type_concept_id, 
327 	44818598 as currency_concept_id, 
328 	null as total_charge, 
329 	b.amt as total_cost, 
330 	null as total_paid, 
331 	null as paid_by_payer, 
332 	null as paid_by_patient, 
333 	null as paid_patient_copay, 
334 	null as paid_patient_coinsurance,  
335 	null as paid_patient_deductiable, 
336 	null as paid_by_primary, 
337 	null as paid_ingredient_cost, 
338 	null as paid_dispensing_fee, 
339 	convert(bigint, convert(varchar, b.person_id) + left(convert(varchar, a.device_exposure_start_date, 112), 4)) as payer_plan_period_id, 
340 	null as amount_allowed, 
341 	null as revenue_code_concept_id, 
342 	null as drg_concept_id, 
343 	null as revenue_code_source_value, 
344 	null as drg_source_value 
345 from (select device_exposure_id, person_id, device_exposure_start_date 
346 	from device_exposure  
347 	where device_source_value not in (select sourcecode from procedure_EDI_mapped_20161007)) a,   
348 	(select m.master_seq, m.key_seq, m.seq_no, m.person_id, n.amt 
349 	from (select master_seq, key_seq, seq_no, person_id from seq_master where source_table='160') m,  
350 	@NHISDatabaseSchema.@NHIS_60T n 
351 	where m.key_seq=n.key_seq 
352 	and m.seq_no=n.seq_no) b 
353 where left(a.device_exposure_id, 10)=b.master_seq 
354 and a.person_id=b.person_id; 
355 
 
356 
 
357 
 
358 
 
359 
 
360 
 
361 
 
362 
 
363 
 
364 
 
365  
