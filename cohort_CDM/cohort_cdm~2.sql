1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 이성원 
4  --Date: 2017.01.20 
5   
6  @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7  @NHIS_JK: JK table in NHIS NSC 
8  @NHIS_20T: 20 table in NHIS NSC 
9  @NHIS_30T: 30 table in NHIS NSC 
10  @NHIS_40T: 40 table in NHIS NSC 
11  @NHIS_60T: 60 table in NHIS NSC 
12  @NHIS_GJ: GJ table in NHIS NSC 
13  --Description: Person 테이블 생성 
14 			   1) 표본코호트DB에는 person이 년도별로 중복 입력되어 있음. 사람들의 소득수준 변화지역이동, 설립구분의 변화등이 추적 가능함 
15 			      하지만, CDM에서는 1개의 person이 들어가야 하므로, 최근 person 데이터를 변환함 
16 			   2) 출생년도를 5년 간격 연령대 데이터를 이용하여 추정, 입력 
17  --Generating Table: PERSON 
18 ***************************************/ 
19 
 
20 /************************************** 
21  1. 테이블 생성 
22 ***************************************/   
23 CREATE TABLE @ResultDatabaseSchema.PERSON ( 
24      person_id						INTEGER		PRIMARY key ,  
25      gender_concept_id				INTEGER		NOT NULL ,  
26      year_of_birth					INTEGER		NOT NULL ,  
27      month_of_birth					INTEGER		NULL,  
28      day_of_birth					INTEGER		NULL,  
29 	 time_of_birth					VARCHAR(50)	NULL, 
30      race_concept_id				INTEGER		NOT NULL,  
31      ethnicity_concept_id			INTEGER		NOT NULL,  
32      location_id					integer		NULL,  
33      provider_id					INTEGER		NULL,  
34      care_site_id					INTEGER		NULL,  
35      person_source_value			VARCHAR(50) NULL,  
36      gender_source_value			VARCHAR(50) NULL, 
37 	 gender_source_concept_id		INTEGER		NULL,  
38      race_source_value				VARCHAR(50) NULL,  
39 	 race_source_concept_id			INTEGER		NULL,  
40      ethnicity_source_value			VARCHAR(50) NULL, 
41 	 ethnicity_source_concept_id	INTEGER		NULL 
42 ); 
43 
 
44 
 
45 /************************************** 
46  2. 데이터 입력 
47 	: 5년 간격의 연령대를 이용해 출생년도를 추정해야 함. 
48 	  총 8개의 추정 포인트에 맞춰 8개의 쿼리를 따로 실행 
49 ***************************************/   
50 
 
51 /** 
52 	1) 1개 이상 구간 + 5개 풀 구간 있음 
53 */ 
54 INSERT INTO @ResultDatabaseSchema.PERSON 
55 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
56 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
57 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
58 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
59 select  
60 	m.person_id as person_id, 
61 	case when o.sex=1 then 8507 
62 		 when o.sex=2 then 8532 end as gender_concept_id, 
63 	m.stnd_y - ((m.age_group-1) * 5) as year_of_birth, 
64 	null as month_of_birth, 
65 	null as day_of_birth, 
66 	null as time_of_birth, 
67 	38003585 as race_concept_id, --인종 
68 	38003564 as ethnicity_concept_id, --민족성 
69 	o.sgg as location_id, 
70 	null as provider_id, 
71 	null as care_site_id, 
72 	m.person_id as person_source_value, 
73 	o.sex as gender_source_value, 
74 	null as gender_source_concept_id, 
75 	null as race_source_value, 
76 	null as race_source_concept_id, 
77 	null as ethnicity_source_value, 
78 	null as ethnicity_source_concept_id 
79 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
80 	(select x.person_id, min(x.stnd_y) as stnd_y 
81 	from @NHISDatabaseSchema.@NHIS_JK x, ( 
82 	select person_id, max(age_group) as age_group 
83 	from ( 
84 		select distinct person_id, age_group 
85 		from @NHISDatabaseSchema.@NHIS_JK 
86 		where person_id in ( 
87 			select distinct person_id 
88 			from ( 
89 				select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
90 				from @NHISDatabaseSchema.@NHIS_JK 
91 				group by person_id, age_group 
92 			) a 
93 			group by person_id 
94 			having count(person_id)>1 
95 		) 
96 		group by person_id, age_group 
97 		having count(age_group) = 5 
98 	) b 
99 	group by person_id) y 
100 	where x.person_id=y.person_id 
101 	and x.age_group=y.age_group 
102 	group by x.person_id, y.person_id, x.age_group, y.age_group) n, --추정포인트 조건에 맞는 person 목록 추출 
103 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
104 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
105 		select person_id, max(stnd_y) as stnd_y 
106 		from @NHISDatabaseSchema.@NHIS_JK 
107 		group by person_id) w 
108 	where q.person_id=w.person_id 
109 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
110 where m.person_id=n.PERSON_ID 
111 and m.stnd_y=n.stnd_y 
112 and m.person_id=o.person_id 
113 
 
114 /** 
115 	2) 1개 이상 구간 + 5개 풀 구간 없음 + 0구간 포함 
116 		: 자격 테이블 전체에 0구간이 2개 이상인 사람이 12명 있음. 이에 0구간 중 min(stnd_y)를 기준으로 출생년도를 정함 
117 */ 
118 INSERT INTO @ResultDatabaseSchema.PERSON 
119 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
120 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
121 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
122 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
123 select  
124 	m.person_id as person_id, 
125 	case when o.sex=1 then 8507 
126 		 when o.sex=2 then 8532 end as gender_concept_id, 
127 	m.stnd_y as year_of_birth, 
128 	null as month_of_birth, 
129 	null as day_of_birth, 
130 	null as time_of_birth, 
131 	38003585 as race_concept_id, --인종 
132 	38003564 as ethnicity_concept_id, --민족성 
133 	o.sgg as location_id, 
134 	null as provider_id, 
135 	null as care_site_id, 
136 	m.person_id as person_source_value, 
137 	o.sex as gender_source_value, 
138 	null as gender_source_concept_id, 
139 	null as race_source_value, 
140 	null as race_source_concept_id, 
141 	null as ethnicity_source_value, 
142 	null as ethnicity_source_concept_id 
143 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
144 	(select x.person_id, min(x.stnd_y) as stnd_y 
145 	from @NHISDatabaseSchema.@NHIS_JK x, ( 
146 		select distinct person_id 
147 		from @NHISDatabaseSchema.@NHIS_JK 
148 		where age_group=0 
149 		and person_id in ( 
150 		select person_id 
151 		from ( 
152 		select person_id, age_group, count(age_group) as age_group_cnt 
153 		from @NHISDatabaseSchema.@NHIS_JK 
154 		where person_id in ( 
155 			select distinct person_id 
156 			from ( 
157 				select distinct person_id 
158 				from ( 
159 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
160 					from @NHISDatabaseSchema.@NHIS_JK 
161 					group by person_id, age_group 
162 				) a 
163 				group by person_id 
164 				having count(person_id)>1 
165 			) b 
166 			where b.person_id not in ( 
167 				select person_id  
168 				from @NHISDatabaseSchema.@NHIS_JK 
169 				where person_id =b.person_id 
170 				group by person_id, age_group 
171 				having count(age_group) = 5 
172 			)  
173 		) 
174 		group by person_id, age_group 
175 		) x 
176 		group by x.person_id 
177 		having max(x.age_group_cnt) < 5 
178 		) ) y 
179 	where x.person_id=y.person_id 
180 	and x.age_group=0 
181 	group by x.person_id) n, --추정포인트 조건에 맞는 person 목록 추출 
182 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
183 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
184 		select person_id, max(stnd_y) as stnd_y 
185 		from @NHISDatabaseSchema.@NHIS_JK 
186 		group by person_id) w 
187 	where q.person_id=w.person_id 
188 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
189 where m.person_id=n.person_id 
190 and m.stnd_y=n.stnd_y 
191 and m.person_id=o.person_id 
192 
 
193 
 
194 /** 
195 	3-1) 1개 이상 구간 + 5개 풀 구간 없음 + 0구간 비포함 + 구간 변경 시점에 년도가 연속 
196 	: 총 76,594 건 
197 */ 
198 -- 연속 구간 데이터 
199 INSERT INTO @ResultDatabaseSchema.PERSON 
200 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
201 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
202 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
203 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
204 select  
205 	d1.person_id as person_id, 
206 	case when d3.sex=1 then 8507 
207 		 when d3.sex=2 then 8532 end as gender_concept_id, 
208 	d1.stnd_y - ((d1.age_group-1) * 5) as year_of_birth, 
209 	null as month_of_birth, 
210 	null as day_of_birth, 
211 	null as time_of_birth, 
212 	38003585 as race_concept_id, --인종 
213 	38003564 as ethnicity_concept_id, --민족성 
214 	d3.sgg as location_id, 
215 	null as provider_id, 
216 	null as care_site_id, 
217 	d1.person_id as person_source_value, 
218 	d3.sex as gender_source_value, 
219 	null as gender_source_concept_id, 
220 	null as race_source_value, 
221 	null as race_source_concept_id, 
222 	null as ethnicity_source_value, 
223 	null as ethnicity_source_concept_id 
224 from @NHISDatabaseSchema.@NHIS_JK d1, --출생년도 추정에 사용되는 person 데이터 
225 (select x.person_id, min(y.min_stnd_y) as stnd_y 
226 from  
227 
 
228 ( 
229 select distinct m.person_id, m.age_group, min(m.stnd_y) as min_stnd_y, max(m.stnd_y) as max_stnd_y 
230 from @NHISDatabaseSchema.@NHIS_JK m,  
231 (select distinct person_id, min_age_group 
232 from ( 
233 	select person_id, min(age_group) as min_age_group 
234 	from ( 
235 	select person_id, age_group, count(age_group) as age_group_cnt 
236 	from @NHISDatabaseSchema.@NHIS_JK 
237 	where person_id in ( 
238 		select distinct person_id 
239 		from ( 
240 			select distinct person_id 
241 			from ( 
242 				select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
243 				from @NHISDatabaseSchema.@NHIS_JK 
244 				group by person_id, age_group 
245 			) a 
246 			group by person_id 
247 			having count(person_id)>1 
248 		) b 
249 		where b.person_id not in ( 
250 			select person_id  
251 			from @NHISDatabaseSchema.@NHIS_JK 
252 			where person_id =b.person_id 
253 			group by person_id, age_group 
254 			having count(age_group) = 5 
255 		)  
256 	) 
257 	group by person_id, age_group 
258 	) x 
259 	group by x.person_id 
260 	having max(x.age_group_cnt) < 5 
261 ) y 
262 where y.person_id not in ( 
263 select distinct person_id 
264 from @NHISDatabaseSchema.@NHIS_JK 
265 where person_id=y.person_id 
266 and age_group=0)) n 
267 where m.person_id=n.person_id 
268 group by m.person_id, m.age_group 
269 ) x, 
270 
 
271 ( 
272 select distinct m.person_id, m.age_group, min(m.stnd_y) as min_stnd_y, max(m.stnd_y) as max_stnd_y 
273 from @NHISDatabaseSchema.@NHIS_JK m,  
274 (select distinct person_id, min_age_group 
275 from ( 
276 	select person_id, min(age_group) as min_age_group 
277 	from ( 
278 	select person_id, age_group, count(age_group) as age_group_cnt 
279 	from @NHISDatabaseSchema.@NHIS_JK 
280 	where person_id in ( 
281 		select distinct person_id 
282 		from ( 
283 			select distinct person_id 
284 			from ( 
285 				select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
286 				from @NHISDatabaseSchema.@NHIS_JK 
287 				group by person_id, age_group 
288 			) a 
289 			group by person_id 
290 			having count(person_id)>1 
291 		) b 
292 		where b.person_id not in ( 
293 			select person_id  
294 			from @NHISDatabaseSchema.@NHIS_JK 
295 			where person_id =b.person_id 
296 			group by person_id, age_group 
297 			having count(age_group) = 5 
298 		)  
299 	) 
300 	group by person_id, age_group 
301 	) x 
302 	group by x.person_id 
303 	having max(x.age_group_cnt) < 5 
304 ) y 
305 where y.person_id not in ( 
306 select distinct person_id 
307 from @NHISDatabaseSchema.@NHIS_JK 
308 where person_id=y.person_id 
309 and age_group=0)) n 
310 where m.person_id=n.person_id 
311 group by m.person_id, m.age_group 
312 ) y 
313 
 
314 where x.person_id=y.person_id 
315 and x.age_group + 1=y.age_group 
316 and x.max_stnd_y + 1=y.min_stnd_y 
317 
 
318 group by x.person_id) d2, --추정포인트 조건에 맞는 person 목록 추출 
319 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
320 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
321 		select person_id, max(stnd_y) as stnd_y 
322 		from @NHISDatabaseSchema.@NHIS_JK 
323 		group by person_id) w 
324 	where q.person_id=w.person_id 
325 	and q.stnd_y=w.stnd_y) d3 --최신 지역 데이터를 가져오기 위해 조인 
326 where d1.person_id=d2.person_id 
327 and d1.stnd_y=d2.stnd_y 
328 and d1.person_id=d3.person_id 
329 
 
330 
 
331 /** 
332 	3-2) 1개 이상 구간 + 5개 풀 구간 없음 + 0구간 비포함 + 구간 변경 시점에 년도가 비연속 
333 	: 새 구간 시작년도에 구간대가 시작된 것으로 추정함 
334 	: 총 2,862 건 
335 */ 
336 -- 연속 구간 데이터 
337 INSERT INTO @ResultDatabaseSchema.PERSON 
338 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
339 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
340 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
341 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
342 select  
343 	d1.person_id as person_id, 
344 	case when d3.sex=1 then 8507 
345 		 when d3.sex=2 then 8532 end as gender_concept_id, 
346 	d1.stnd_y - ((d1.age_group-1) * 5) as year_of_birth, 
347 	null as month_of_birth, 
348 	null as day_of_birth, 
349 	null as time_of_birth, 
350 	38003585 as race_concept_id, --인종 
351 	38003564 as ethnicity_concept_id, --민족성 
352 	d3.sgg as location_id, 
353 	null as provider_id, 
354 	null as care_site_id, 
355 	d1.person_id as person_source_value, 
356 	d3.sex as gender_source_value, 
357 	null as gender_source_concept_id, 
358 	null as race_source_value, 
359 	null as race_source_concept_id, 
360 	null as ethnicity_source_value, 
361 	null as ethnicity_source_concept_id 
362 from @NHISDatabaseSchema.@NHIS_JK d1, --출생년도 추정에 사용되는 person 데이터 
363 	( 
364 	select s1.person_id, s1.age_group, min(s1.stnd_y) as stnd_y 
365 	from @NHISDatabaseSchema.@NHIS_JK s1, 
366 	( 
367 	select distinct person_id, max_age_group, min_age_group 
368 	from ( 
369 	select distinct person_id, max_age_group, min_age_group 
370 	from ( 
371 		select person_id, max(age_group) as max_age_group, min(age_group) as min_age_group 
372 		from ( 
373 		select person_id, age_group, count(age_group) as age_group_cnt 
374 		from @NHISDatabaseSchema.@NHIS_JK 
375 		where person_id in ( 
376 			select distinct person_id 
377 			from ( 
378 				select distinct person_id 
379 				from ( 
380 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
381 					from @NHISDatabaseSchema.@NHIS_JK 
382 					group by person_id, age_group 
383 				) a 
384 				group by person_id 
385 				having count(person_id)>1 
386 			) b 
387 			where b.person_id not in ( 
388 				select person_id  
389 				from @NHISDatabaseSchema.@NHIS_JK 
390 				where person_id =b.person_id 
391 				group by person_id, age_group 
392 				having count(age_group) = 5 
393 			)  
394 		) 
395 		group by person_id, age_group 
396 		) x 
397 		group by x.person_id 
398 		having max(x.age_group_cnt) < 5 
399 	) y 
400 	where y.person_id not in ( 
401 	select distinct person_id 
402 	from @NHISDatabaseSchema.@NHIS_JK 
403 	where person_id=y.person_id 
404 	and age_group=0)) x 
405 	where person_id not in ( 
406 
 
407 
 
408 	--  
409 	select distinct x.person_id 
410 	from  
411 
 
412 	( 
413 	select distinct m.person_id, m.age_group, min(m.stnd_y) as min_stnd_y, max(m.stnd_y) as max_stnd_y 
414 	from @NHISDatabaseSchema.@NHIS_JK m,  
415 	(select distinct person_id, min_age_group 
416 	from ( 
417 		select person_id, min(age_group) as min_age_group 
418 		from ( 
419 		select person_id, age_group, count(age_group) as age_group_cnt 
420 		from @NHISDatabaseSchema.@NHIS_JK 
421 		where person_id in ( 
422 			select distinct person_id 
423 			from ( 
424 				select distinct person_id 
425 				from ( 
426 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
427 					from @NHISDatabaseSchema.@NHIS_JK 
428 					group by person_id, age_group 
429 				) a 
430 				group by person_id 
431 				having count(person_id)>1 
432 			) b 
433 			where b.person_id not in ( 
434 				select person_id  
435 				from @NHISDatabaseSchema.@NHIS_JK 
436 				where person_id =b.person_id 
437 				group by person_id, age_group 
438 				having count(age_group) = 5 
439 			)  
440 		) 
441 		group by person_id, age_group 
442 		) x 
443 		group by x.person_id 
444 		having max(x.age_group_cnt) < 5 
445 	) y 
446 	where y.person_id not in ( 
447 	select distinct person_id 
448 	from @NHISDatabaseSchema.@NHIS_JK 
449 	where person_id=y.person_id 
450 	and age_group=0)) n 
451 	where m.person_id=n.person_id 
452 	group by m.person_id, m.age_group 
453 	) x, 
454 
 
455 	( 
456 	select distinct m.person_id, m.age_group, min(m.stnd_y) as min_stnd_y, max(m.stnd_y) as max_stnd_y 
457 	from @NHISDatabaseSchema.@NHIS_JK m,  
458 	(select distinct person_id, min_age_group 
459 	from ( 
460 		select person_id, min(age_group) as min_age_group 
461 		from ( 
462 		select person_id, age_group, count(age_group) as age_group_cnt 
463 		from @NHISDatabaseSchema.@NHIS_JK 
464 		where person_id in ( 
465 			select distinct person_id 
466 			from ( 
467 				select distinct person_id 
468 				from ( 
469 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
470 					from @NHISDatabaseSchema.@NHIS_JK 
471 					group by person_id, age_group 
472 				) a 
473 				group by person_id 
474 				having count(person_id)>1 
475 			) b 
476 			where b.person_id not in ( 
477 				select person_id  
478 				from @NHISDatabaseSchema.@NHIS_JK 
479 				where person_id =b.person_id 
480 				group by person_id, age_group 
481 				having count(age_group) = 5 
482 			)  
483 		) 
484 		group by person_id, age_group 
485 		) x 
486 		group by x.person_id 
487 		having max(x.age_group_cnt) < 5 
488 	) y 
489 	where y.person_id not in ( 
490 	select distinct person_id 
491 	from @NHISDatabaseSchema.@NHIS_JK 
492 	where person_id=y.person_id 
493 	and age_group=0)) n 
494 	where m.person_id=n.person_id 
495 	group by m.person_id, m.age_group 
496 	) y 
497 
 
498 	where x.person_id=y.person_id 
499 	and x.age_group + 1=y.age_group 
500 	and x.max_stnd_y + 1=y.min_stnd_y 
501 	) 
502 	) s2 
503 	where s1.person_id=s2.person_id 
504 	and s1.age_group=s2.min_age_group 
505 	group by s1.person_id, s1.age_group 
506 	) d2, --추정포인트 조건에 맞는 person 목록 추출 
507 
 
508 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
509 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
510 		select person_id, max(stnd_y) as stnd_y 
511 		from @NHISDatabaseSchema.@NHIS_JK 
512 		group by person_id) w 
513 	where q.person_id=w.person_id 
514 	and q.stnd_y=w.stnd_y) d3 --최신 지역 데이터를 가져오기 위해 조인 
515 
 
516 where d1.person_id=d2.person_id 
517 and d1.stnd_y=d2.stnd_y 
518 and d1.person_id=d3.person_id 
519 
 
520 
 
521 
 
522 /** 
523 	4) 1개 이상 구간 + 5개 풀 구간 없음 + 맥스 구간 데이터 건수가 5개보다 많음 
524 		: 맥스 구간이 최고령 구간대가 아닌 데이터가 236건 
525 		: 동일하게 맥스 구간의 min(stnd_y)를 기준으로 출생년도 추정 
526 */ 
527 INSERT INTO @ResultDatabaseSchema.PERSON 
528 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
529 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
530 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
531 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
532 select  
533 	m.person_id as person_id, 
534 	case when o.sex=1 then 8507 
535 		 when o.sex=2 then 8532 end as gender_concept_id, 
536 	m.stnd_y - ((m.age_group-1) * 5) as year_of_birth, 
537 	null as month_of_birth, 
538 	null as day_of_birth, 
539 	null as time_of_birth, 
540 	38003585 as race_concept_id, --인종 
541 	38003564 as ethnicity_concept_id, --민족성 
542 	o.sgg as location_id, 
543 	null as provider_id, 
544 	null as care_site_id, 
545 	m.person_id as person_source_value, 
546 	o.sex as gender_source_value, 
547 	null as gender_source_concept_id, 
548 	null as race_source_value, 
549 	null as race_source_concept_id, 
550 	null as ethnicity_source_value, 
551 	null as ethnicity_source_concept_id 
552 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
553 	(select x.person_id, min(stnd_y) as stnd_y 
554 	from @NHISDatabaseSchema.@NHIS_JK x, ( 
555 		select distinct person_id, age_group 
556 		from ( 
557 		select person_id, age_group, count(age_group) as age_group_cnt 
558 		from @NHISDatabaseSchema.@NHIS_JK 
559 		where person_id in ( 
560 			select distinct person_id 
561 			from ( 
562 				select distinct person_id 
563 				from ( 
564 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
565 					from @NHISDatabaseSchema.@NHIS_JK 
566 					group by person_id, age_group 
567 				) a 
568 				group by person_id 
569 				having count(person_id)>1 
570 			) b 
571 			where b.person_id not in ( 
572 				select person_id  
573 				from @NHISDatabaseSchema.@NHIS_JK 
574 				where person_id =b.person_id 
575 				group by person_id, age_group 
576 				having count(age_group) = 5 
577 			)  
578 		) 
579 		group by person_id, age_group 
580 		) x 
581 		group by x.person_id, age_group 
582 		having max(x.age_group_cnt) > 5 
583 	) y 
584 	where x.PERSON_ID=y.PERSON_ID 
585 	and x.age_group=y.age_group 
586 	group by x.person_id, x.age_group 
587 	) n, --추정포인트 조건에 맞는 person 목록 추출 
588 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
589 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
590 		select person_id, max(stnd_y) as stnd_y 
591 		from @NHISDatabaseSchema.@NHIS_JK 
592 		group by person_id) w 
593 	where q.person_id=w.person_id 
594 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
595 where m.person_id=n.person_id 
596 and m.stnd_y=n.stnd_y 
597 and m.person_id=o.person_id 
598 
 
599 
 
600 /** 
601 	5) 1개 구간 + 5개 풀 구간임 
602 	: 2002년에 최고령 구간에 포함되어 5년째 사망한 사람 데이터 있음. 정확한 추정 불가능 
603 */ 
604 INSERT INTO @ResultDatabaseSchema.PERSON 
605 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
606 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
607 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
608 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
609 select  
610 	m.person_id as person_id, 
611 	case when o.sex=1 then 8507 
612 		 when o.sex=2 then 8532 end as gender_concept_id, 
613 	m.stnd_y - ((m.age_group-1) * 5) as year_of_birth, 
614 	null as month_of_birth, 
615 	null as day_of_birth, 
616 	null as time_of_birth, 
617 	38003585 as race_concept_id, --인종 
618 	38003564 as ethnicity_concept_id, --민족성 
619 	o.sgg as location_id, 
620 	null as provider_id, 
621 	null as care_site_id, 
622 	m.person_id as person_source_value, 
623 	o.sex as gender_source_value, 
624 	null as gender_source_concept_id, 
625 	null as race_source_value, 
626 	null as race_source_concept_id, 
627 	null as ethnicity_source_value, 
628 	null as ethnicity_source_concept_id 
629 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
630 (select person_id, age_group, min(stnd_y) as stnd_y 
631 from @NHISDatabaseSchema.@NHIS_JK 
632 where person_id in ( 
633 	select distinct person_id 
634 	from ( 
635 		select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
636 		from @NHISDatabaseSchema.@NHIS_JK 
637 		group by person_id, age_group 
638 	) a 
639 	group by person_id 
640 	having count(person_id)=1 
641 ) 
642 group by person_id, age_group 
643 having count(age_group) = 5) n, --추정포인트 조건에 맞는 person 목록 추출 
644 (select w.person_id, w.stnd_y, q.sex, q.sgg 
645 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
646 		select person_id, max(stnd_y) as stnd_y 
647 		from @NHISDatabaseSchema.@NHIS_JK 
648 		group by person_id) w 
649 	where q.person_id=w.person_id 
650 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
651 where m.person_id=n.person_id 
652 and m.stnd_y=n.stnd_y 
653 and m.person_id=o.person_id 
654 
 
655 
 
656 /** 
657 	6) 1개 구간 + 5개 풀 구간 아님 + 0구간 포함 
658 	: 0 구간 데이터가 2개인 데이터 1건 있음 
659 */ 
660 INSERT INTO @ResultDatabaseSchema.PERSON 
661 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
662 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
663 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
664 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
665 select  
666 	m.person_id as person_id, 
667 	case when o.sex=1 then 8507 
668 		 when o.sex=2 then 8532 end as gender_concept_id, 
669 	m.stnd_y as year_of_birth, 
670 	null as month_of_birth, 
671 	null as day_of_birth, 
672 	null as time_of_birth, 
673 	38003585 as race_concept_id, --인종 
674 	38003564 as ethnicity_concept_id, --민족성 
675 	o.sgg as location_id, 
676 	null as provider_id, 
677 	null as care_site_id, 
678 	m.person_id as person_source_value, 
679 	o.sex as gender_source_value, 
680 	null as gender_source_concept_id, 
681 	null as race_source_value, 
682 	null as race_source_concept_id, 
683 	null as ethnicity_source_value, 
684 	null as ethnicity_source_concept_id 
685 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
686 	(select person_id, min(stnd_y) as stnd_y 
687 	from @NHISDatabaseSchema.@NHIS_JK 
688 	where age_group=0 
689 	and person_id in ( 
690 	select person_id 
691 	from ( 
692 	select person_id, age_group, count(age_group) as age_group_cnt 
693 	from @NHISDatabaseSchema.@NHIS_JK 
694 	where person_id in ( 
695 		select distinct person_id 
696 		from ( 
697 			select distinct person_id 
698 			from ( 
699 				select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
700 				from @NHISDatabaseSchema.@NHIS_JK 
701 				group by person_id, age_group 
702 			) a 
703 			group by person_id 
704 			having count(person_id)=1 
705 		) b 
706 		where b.person_id not in ( 
707 			select person_id  
708 			from @NHISDatabaseSchema.@NHIS_JK 
709 			where person_id =b.person_id 
710 			group by person_id, age_group 
711 			having count(age_group) = 5 
712 		)  
713 	) 
714 	group by person_id, age_group 
715 	) x 
716 	group by x.person_id 
717 	having max(x.age_group_cnt) < 5 
718 	)  
719 	group by person_id) n, --추정포인트 조건에 맞는 person 목록 추출 
720 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
721 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
722 		select person_id, max(stnd_y) as stnd_y 
723 		from @NHISDatabaseSchema.@NHIS_JK 
724 		group by person_id) w 
725 	where q.person_id=w.person_id 
726 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
727 where m.person_id=n.person_id 
728 and m.stnd_y=n.stnd_y 
729 and m.person_id=o.person_id 
730 
 
731 
 
732 /** 
733 	7) 1개 구간 + 5개 풀 구간 아님 + 0구간 비포함 
734 	: 정확한 추정 불가 
735 	: 구간 시작 년도에 구간대의 최소값을 갖도록 추정함 (예: 2002년에 20~24세 구간이면, 2002년에 22세로 추정) 
736 */ 
737 INSERT INTO @ResultDatabaseSchema.PERSON 
738 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
739 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
740 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
741 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
742 select  
743 	m.person_id as person_id, 
744 	case when o.sex=1 then 8507 
745 		 when o.sex=2 then 8532 end as gender_concept_id, 
746 	m.stnd_y - ((m.age_group-1) * 5) as year_of_birth, 
747 	null as month_of_birth, 
748 	null as day_of_birth, 
749 	null as time_of_birth, 
750 	38003585 as race_concept_id, --인종 
751 	38003564 as ethnicity_concept_id, --민족성 
752 	o.sgg as location_id, 
753 	null as provider_id, 
754 	null as care_site_id, 
755 	m.person_id as person_source_value, 
756 	o.sex as gender_source_value, 
757 	null as gender_source_concept_id, 
758 	null as race_source_value, 
759 	null as race_source_concept_id, 
760 	null as ethnicity_source_value, 
761 	null as ethnicity_source_concept_id 
762 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
763 	(select x.person_id, x.age_group, min(x.stnd_y) as stnd_y 
764 	from @NHISDatabaseSchema.@NHIS_JK x, 
765 	(select person_id, age_group 
766 	from ( 
767 		select person_id, min(age_group) as age_group 
768 		from ( 
769 		select person_id, age_group, count(age_group) as age_group_cnt 
770 		from @NHISDatabaseSchema.@NHIS_JK 
771 		where person_id in (												 
772 			select distinct person_id 
773 			from ( 
774 				select distinct person_id 
775 				from ( 
776 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
777 					from @NHISDatabaseSchema.@NHIS_JK 
778 					group by person_id, age_group 
779 				) a 
780 				group by person_id 
781 				having count(person_id)=1 
782 			) b 
783 			where b.person_id not in ( 
784 				select person_id  
785 				from @NHISDatabaseSchema.@NHIS_JK 
786 				where person_id =b.person_id 
787 				group by person_id, age_group 
788 				having count(age_group) = 5 
789 			)  
790 		) 
791 		group by person_id, age_group 
792 		) x 
793 		group by x.person_id 
794 		having max(x.age_group_cnt) < 5 
795 	) y					 
796 	where y.person_id not in ( 
797 	select distinct person_id 
798 	from @NHISDatabaseSchema.@NHIS_JK 
799 	where person_id=y.person_id 
800 	and age_group=0)) y 
801 	where x.person_id=y.person_id 
802 	and x.age_group=y.age_group 
803 	group by x.person_id, x.age_group) n, --추정포인트 조건에 맞는 person 목록 추출 
804 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
805 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
806 		select person_id, max(stnd_y) as stnd_y 
807 		from @NHISDatabaseSchema.@NHIS_JK 
808 		group by person_id) w 
809 	where q.person_id=w.person_id 
810 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
811 where m.person_id=n.person_id 
812 and m.stnd_y=n.stnd_y 
813 and m.person_id=o.person_id 
814 
 
815 
 
816 /** 
817 	8) 1개 구간 + 5개 풀 구간 아님 + 구간 건수가 5개보다 많음 
818 	: 정확한 추정 불가 
819 	: 구간 시작 년도에 구간대의 중간값을 갖도록 추정함 (예: 2002년에 20~24세 구간이면, 2002년에 22세로 추정) 
820 */ 
821 INSERT INTO @ResultDatabaseSchema.PERSON 
822 	(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, 
823 	time_of_birth, race_concept_id, ethnicity_concept_id, location_id, provider_id, 
824 	care_site_id, person_source_value, gender_source_value, gender_source_concept_id, race_source_value, 
825 	race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id) 
826 select  
827 	m.person_id as person_id, 
828 	case when o.sex=1 then 8507 
829 		 when o.sex=2 then 8532 end as gender_concept_id, 
830 	m.stnd_y - ((m.age_group-1) * 5) as year_of_birth, 
831 	null as month_of_birth, 
832 	null as day_of_birth, 
833 	null as time_of_birth, 
834 	38003585 as race_concept_id, --인종 
835 	38003564 as ethnicity_concept_id, --민족성 
836 	o.sgg as location_id, 
837 	null as provider_id, 
838 	null as care_site_id, 
839 	m.person_id as person_source_value, 
840 	o.sex as gender_source_value, 
841 	null as gender_source_concept_id, 
842 	null as race_source_value, 
843 	null as race_source_concept_id, 
844 	null as ethnicity_source_value, 
845 	null as ethnicity_source_concept_id 
846 from @NHISDatabaseSchema.@NHIS_JK m, --출생년도 추정에 사용되는 person 데이터 
847 	(select m.person_id, min(m.age_group) as age_group, min(m.stnd_y) as stnd_y 
848 	from @NHISDatabaseSchema.@NHIS_JK m, 
849 		(select distinct person_id 
850 		from ( 
851 		select person_id, age_group, count(age_group) as age_group_cnt 
852 		from @NHISDatabaseSchema.@NHIS_JK 
853 		where person_id in ( 
854 			select distinct person_id 
855 			from ( 
856 				select distinct person_id 
857 				from ( 
858 					select person_id, age_group, count(age_group) as age_group_cnt, min(year) as min_year, max(year) as max_year 
859 					from @NHISDatabaseSchema.@NHIS_JK 
860 					group by person_id, age_group 
861 				) a 
862 				group by person_id 
863 				having count(person_id)=1 
864 			) b 
865 			where b.person_id not in ( 
866 				select person_id  
867 				from @NHISDatabaseSchema.@NHIS_JK 
868 				where person_id =b.person_id 
869 				group by person_id, age_group 
870 				having count(age_group) = 5 
871 			)  
872 		) 
873 		group by person_id, age_group 
874 		) x 
875 		group by x.person_id 
876 		having max(x.age_group_cnt) > 5) n 
877 	where m.person_id=n.person_id 
878 	group by m.person_id) n, --추정포인트 조건에 맞는 person 목록 추출 
879 	(select w.person_id, w.stnd_y, q.sex, q.sgg 
880 	from @NHISDatabaseSchema.@NHIS_JK q, ( 
881 		select person_id, max(stnd_y) as stnd_y 
882 		from @NHISDatabaseSchema.@NHIS_JK 
883 		group by person_id) w 
884 	where q.person_id=w.person_id 
885 	and q.stnd_y=w.stnd_y) o --최신 지역 데이터를 가져오기 위해 조인 
886 where m.person_id=n.person_id 
887 and m.stnd_y=n.stnd_y 
888 and m.person_id=o.person_id 
