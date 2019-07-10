1 /********************************************************************************* 
2 # Copyright 2014 Observational Health Data Sciences and Informatics 
3 # 
4 #  
5 # Licensed under the Apache License, Version 2.0 (the "License"); 
6 # you may not use this file except in compliance with the License. 
7 # You may obtain a copy of the License at 
8 #  
9 #     http://www.apache.org/licenses/LICENSE-2.0 
10 #  
11 # Unless required by applicable law or agreed to in writing, software 
12 # distributed under the License is distributed on an "AS IS" BASIS, 
13 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
14 # See the License for the specific language governing permissions and 
15 # limitations under the License. 
16 ********************************************************************************/ 
17 
 
18 /************************ 
19  
20  ####### #     # ####### ######      #####  ######  #     #           #######    ###                                            
21  #     # ##   ## #     # #     #    #     # #     # ##   ##    #    # #           #  #    # #####  ###### #    # ######  ####   
22  #     # # # # # #     # #     #    #       #     # # # # #    #    # #           #  ##   # #    # #       #  #  #      #       
23  #     # #  #  # #     # ######     #       #     # #  #  #    #    # ######      #  # #  # #    # #####    ##   #####   ####   
24  #     # #     # #     # #          #       #     # #     #    #    #       #     #  #  # # #    # #        ##   #           #  
25  #     # #     # #     # #          #     # #     # #     #     #  #  #     #     #  #   ## #    # #       #  #  #      #    #  
26  ####### #     # ####### #           #####  ######  #     #      ##    #####     ### #    # #####  ###### #    # ######  ####   
27                                                                                
28  
29 script to create the required indexes within OMOP common data model, version 5.0 for SQL Server database 
30  
31 last revised: 12 Oct 2014 
32  
33 author:  Patrick Ryan 
34  
35 description:  These indices are considered a minimal requirement to ensure adequate performance of analyses. 
36  
37 *************************/ 
38 
 
39 /*Modified for Korean OHDSI from Patrick Ryan 
40 last revised: 03 Nov 2016 
41 author:  jung hyun byun 
42 */ 
43 
 
44 /**************************************************************************************************************************************** 
45 *****************************************************	Cluster Index  ****************************************************************** 
46 ***************************************************************************************************************************************** 
47  **********************************/ 
48 
 
49 /************************ 
50  
51 Standardized vocabulary 
52  
53 ************************/ 
54 
 
55 CREATE UNIQUE CLUSTERED INDEX idx_concept_concept_id ON @ResultDatabaseSchema.concept (concept_id ASC); 
56 CREATE INDEX idx_concept_code ON @ResultDatabaseSchema.concept (concept_code ASC); 
57 CREATE INDEX idx_concept_vocabluary_id ON @ResultDatabaseSchema.concept (vocabulary_id ASC); 
58 CREATE INDEX idx_concept_domain_id ON @ResultDatabaseSchema.concept (domain_id ASC); 
59 CREATE INDEX idx_concept_class_id ON @ResultDatabaseSchema.concept (concept_class_id ASC); 
60 
 
61 
 
62 CREATE UNIQUE CLUSTERED INDEX idx_vocabulary_vocabulary_id ON @ResultDatabaseSchema.vocabulary (vocabulary_id ASC); 
63 --CREATE UNIQUE CLUSTERED INDEX idx_domain_domain_id ON domain (domain_id ASC); 
64 CREATE UNIQUE CLUSTERED INDEX idx_concept_class_class_id ON @ResultDatabaseSchema.concept_class (concept_class_id ASC); 
65 CREATE INDEX idx_concept_relationship_id_1 ON @ResultDatabaseSchema.concept_relationship (concept_id_1 ASC);  
66 CREATE INDEX idx_concept_relationship_id_2 ON @ResultDatabaseSchema.concept_relationship (concept_id_2 ASC);  
67 CREATE INDEX idx_concept_relationship_id_3 ON @ResultDatabaseSchema.concept_relationship (relationship_id ASC);  
68 CREATE UNIQUE CLUSTERED INDEX idx_relationship_rel_id ON @ResultDatabaseSchema.relationship (relationship_id ASC); 
69 CREATE CLUSTERED INDEX idx_concept_synonym_id ON @ResultDatabaseSchema.concept_synonym (concept_id ASC); 
70 CREATE CLUSTERED INDEX idx_concept_ancestor_id_1 ON @ResultDatabaseSchema.concept_ancestor (ancestor_concept_id ASC); 
71 CREATE INDEX idx_concept_ancestor_id_2 ON @ResultDatabaseSchema.concept_ancestor (descendant_concept_id ASC); 
72 --CREATE CLUSTERED INDEX idx_source_to_concept_map_id_3 ON source_to_concept_map (target_concept_id ASC); 
73 --CREATE INDEX idx_source_to_concept_map_id_1 ON source_to_concept_map (source_vocabulary_id ASC); 
74 --CREATE INDEX idx_source_to_concept_map_id_2 ON source_to_concept_map (target_vocabulary_id ASC); 
75 --CREATE INDEX idx_source_to_concept_map_code ON source_to_concept_map (source_code ASC); 
76 CREATE CLUSTERED INDEX idx_drug_strength_id_1 ON @ResultDatabaseSchema.drug_strength (drug_concept_id ASC); 
77 CREATE INDEX idx_drug_strength_id_2 ON @ResultDatabaseSchema.drug_strength (ingredient_concept_id ASC); 
78 --CREATE CLUSTERED INDEX idx_cohort_definition_id ON cohort_definition (cohort_definition_id ASC); 
79 --CREATE CLUSTERED INDEX idx_attribute_definition_id ON attribute_definition (attribute_definition_id ASC); 
80 
 
81 /************************ 
82  
83 Standardized clinical data 
84  
85 ************************/ 
86 
 
87 CREATE UNIQUE CLUSTERED INDEX idx_person_id ON @ResultDatabaseSchema.person (person_id ASC); 
88 
 
89 CREATE CLUSTERED INDEX idx_observation_period_id ON @ResultDatabaseSchema.observation_period (person_id ASC); 
90 
 
91 CREATE CLUSTERED INDEX idx_specimen_person_id ON @ResultDatabaseSchema.specimen (person_id ASC); 
92 
 
93 CREATE INDEX idx_specimen_concept_id ON @ResultDatabaseSchema.specimen (specimen_concept_id ASC); 
94 
 
95 CREATE CLUSTERED INDEX idx_death_person_id ON @ResultDatabaseSchema.death (person_id ASC); 
96 
 
97 CREATE CLUSTERED INDEX idx_visit_person_id ON @ResultDatabaseSchema.visit_occurrence (person_id ASC); 
98 
 
99 CREATE INDEX idx_visit_concept_id ON @ResultDatabaseSchema.visit_occurrence (visit_concept_id ASC); 
100 
 
101 CREATE CLUSTERED INDEX idx_procedure_person_id ON @ResultDatabaseSchema.procedure_occurrence (person_id ASC); 
102 
 
103 CREATE INDEX idx_procedure_concept_id ON @ResultDatabaseSchema.procedure_occurrence (procedure_concept_id ASC); 
104 
 
105 CREATE INDEX idx_procedure_visit_id ON @ResultDatabaseSchema.procedure_occurrence (visit_occurrence_id ASC); 
106 
 
107 CREATE CLUSTERED INDEX idx_drug_person_id ON @ResultDatabaseSchema.drug_exposure (person_id ASC); 
108 
 
109 CREATE INDEX idx_drug_concept_id ON @ResultDatabaseSchema.drug_exposure (drug_concept_id ASC); 
110 
 
111 CREATE INDEX idx_drug_visit_id ON @ResultDatabaseSchema.drug_exposure (visit_occurrence_id ASC); 
112 
 
113 CREATE CLUSTERED INDEX idx_device_person_id ON @ResultDatabaseSchema.device_exposure (person_id ASC); 
114 
 
115 CREATE INDEX idx_device_concept_id ON @ResultDatabaseSchema.device_exposure (device_concept_id ASC); 
116 
 
117 CREATE INDEX idx_device_visit_id ON @ResultDatabaseSchema.device_exposure (visit_occurrence_id ASC); 
118 
 
119 CREATE CLUSTERED INDEX idx_condition_person_id ON @ResultDatabaseSchema.condition_occurrence (person_id ASC); 
120 
 
121 CREATE INDEX idx_condition_concept_id ON @ResultDatabaseSchema.condition_occurrence (condition_concept_id ASC); 
122 
 
123 CREATE INDEX idx_condition_visit_id ON @ResultDatabaseSchema.condition_occurrence (visit_occurrence_id ASC); 
124 
 
125 CREATE CLUSTERED INDEX idx_measurement_person_id ON @ResultDatabaseSchema.measurement (person_id ASC); 
126 
 
127 CREATE INDEX idx_measurement_concept_id ON @ResultDatabaseSchema.measurement (measurement_concept_id ASC); 
128 
 
129 CREATE INDEX idx_measurement_visit_id ON @ResultDatabaseSchema.measurement (visit_occurrence_id ASC); 
130 
 
131 CREATE CLUSTERED INDEX idx_note_person_id ON @ResultDatabaseSchema.note (person_id ASC); 
132 
 
133 CREATE INDEX idx_note_concept_id ON @ResultDatabaseSchema.note (note_type_concept_id ASC); 
134 
 
135 CREATE INDEX idx_note_visit_id ON @ResultDatabaseSchema.note (visit_occurrence_id ASC); 
136 
 
137 CREATE CLUSTERED INDEX idx_observation_person_id ON @ResultDatabaseSchema.observation (person_id ASC); 
138 
 
139 CREATE INDEX idx_observation_concept_id ON @ResultDatabaseSchema.observation (observation_concept_id ASC); 
140 
 
141 CREATE INDEX idx_observation_visit_id ON @ResultDatabaseSchema.observation (visit_occurrence_id ASC); 
142 
 
143 
 
144 
 
145 /************************ 
146  
147 Standardized health economics 
148  
149 ************************/ 
150 
 
151 CREATE CLUSTERED INDEX idx_period_person_id ON @ResultDatabaseSchema.payer_plan_period (person_id ASC); 
152 
 
153 /************************ 
154  
155 Standardized derived elements 
156  
157 ************************/ 
158 
 
159 
 
160 CREATE INDEX idx_cohort_subject_id ON @ResultDatabaseSchema.cohort (subject_id ASC); 
161 
 
162 CREATE INDEX idx_cohort_c_definition_id ON @ResultDatabaseSchema.cohort (cohort_definition_id ASC); 
163 
 
164 CREATE INDEX idx_ca_subject_id ON @ResultDatabaseSchema.cohort_attribute (subject_id ASC); 
165 
 
166 CREATE INDEX idx_ca_definition_id ON @ResultDatabaseSchema.cohort_attribute (cohort_definition_id ASC); 
167 
 
168 CREATE CLUSTERED INDEX idx_drug_era_person_id ON @ResultDatabaseSchema.drug_era (person_id ASC); 
169 
 
170 CREATE INDEX idx_drug_era_concept_id ON @ResultDatabaseSchema.drug_era (drug_concept_id ASC); 
171 
 
172 CREATE CLUSTERED INDEX idx_dose_era_person_id ON @ResultDatabaseSchema.dose_era (person_id ASC); 
173 
 
174 CREATE INDEX idx_dose_era_concept_id ON @ResultDatabaseSchema.dose_era (drug_concept_id ASC); 
175 
 
176 CREATE CLUSTERED INDEX idx_condition_era_person_id ON @ResultDatabaseSchema.condition_era (person_id ASC); 
177 
 
178 CREATE INDEX idx_condition_era_concept_id ON @ResultDatabaseSchema.condition_era (condition_concept_id ASC); 
179 
 
180 
 
181 /**************************************************************************************************************************************** 
182 *****************************************************	Non Cluster Index  ************************************************************** 
183  **************************************************************************************************************************************** 
184  **********************************/ 
185 
 
186  /* PERSON */ 
187 
 
188 
 
189 	CREATE NONCLUSTERED INDEX [<PERSON_1, sysname,>] 
190 		ON @ResultDatabaseSchema.PERSON ([person_id]) 
191 			INCLUDE ([year_of_birth],[gender_concept_id] ); 
192 			 
193 				 			 
194 
 
195 
 
196 	CREATE NONCLUSTERED INDEX [<PERSON_2, sysname,>] 
197 		ON @ResultDatabaseSchema.PERSON ([location_id]) 
198 			INCLUDE ([person_id]); 
199 
 
200 				  
201 
 
202 	CREATE NONCLUSTERED INDEX [<PERSON_3, sysname,>] 
203 		ON @ResultDatabaseSchema.PERSON ([provider_id]); 
204 
 
205 				 
206 
 
207 	CREATE NONCLUSTERED INDEX [<PERSON_4, sysname,>] 
208 		ON @ResultDatabaseSchema.PERSON ([care_site_id]); 
209 
 
210 			 
211 /* OBSERVATION */  
212 	CREATE NONCLUSTERED INDEX [<OBSERVATION_1, sysname,>] 
213 		ON @ResultDatabaseSchema.[OBSERVATION] ([provider_id]); 
214 	CREATE NONCLUSTERED INDEX [<OBSERVATION_2, sysname,>] 
215 		ON @ResultDatabaseSchema.[OBSERVATION] ([visit_occurrence_id]); 
216 	CREATE NONCLUSTERED INDEX [<OBSERVATION_3, sysname,>] 
217 		ON @ResultDatabaseSchema.[OBSERVATION] ([value_as_number],[unit_concept_id]) 
218 			INCLUDE ([observation_concept_id]); 
219 
 
220 			  
221 
 
222 /* OBSERVATION_PERIOD */ 
223 
 
224 	CREATE NONCLUSTERED INDEX [<OBSERVATION_PERIOD_4, sysname,>] 
225 		ON @ResultDatabaseSchema.[OBSERVATION_PERIOD] ([PERSON_ID]) 
226 			INCLUDE ([OBSERVATION_PERIOD_START_DATE]); 
227 
 
228 			  
229 
 
230 	CREATE NONCLUSTERED INDEX [<OBSERVATION_PERIOD_5, sysname,>] 
231 		ON @ResultDatabaseSchema.[OBSERVATION_PERIOD] ([OBSERVATION_PERIOD_START_DATE],[OBSERVATION_PERIOD_END_DATE]) 
232 			INCLUDE ([PERSON_ID]); 
233 
 
234 			  
235 
 
236 /* VISIT */ 
237 
 
238 
 
239 	CREATE NONCLUSTERED INDEX [<VISIT_1, sysname,>] 
240 		ON @ResultDatabaseSchema.[VISIT_OCCURRENCE] ([care_site_id]); 
241 
 
242 		  
243 
 
244 /* CONDITION */ 
245 
 
246 
 
247 	CREATE NONCLUSTERED INDEX [<CONDITION_1, sysname,>] 
248 		ON @ResultDatabaseSchema.[CONDITION_OCCURRENCE] ([provider_id]); 
249 
 
250 		 
251 
 
252 	CREATE NONCLUSTERED INDEX [<CONDITION_2, sysname,>] 
253 		ON @ResultDatabaseSchema.[CONDITION_OCCURRENCE] ([visit_occurrence_id]); 
254 
 
255 		 
256 
 
257 /* CONDITION_ERA */ 
258 
 
259 
 
260 	CREATE NONCLUSTERED INDEX [<CONDITION_ERA_1, sysname,>] 
261 		ON @ResultDatabaseSchema.[CONDITION_ERA] ([person_id]) 
262 			INCLUDE ([condition_concept_id],[condition_era_start_date]); 
263 
 
264 			 
265 
 
266 /* PROCEDURE */ 
267 
 
268 
 
269 	CREATE NONCLUSTERED INDEX [<PROCEDURE_1, sysname,>] 
270 		ON @ResultDatabaseSchema.[PROCEDURE_OCCURRENCE] ([provider_id], [visit_occurrence_id]); 
271 
 
272 		 
273 		 
274 
 
275 /* DRUG */ 
276 
 
277 	CREATE NONCLUSTERED INDEX [<DRUG_1, sysname,>] 
278 		ON @ResultDatabaseSchema.[DRUG_EXPOSURE] ([provider_id]); 
279 
 
280 		 
281   
282 	CREATE NONCLUSTERED INDEX [<DRUG_2, sysname,>] 
283 		ON @ResultDatabaseSchema.[DRUG_EXPOSURE] ([visit_occurrence_id]) 
284 
 
285 		 
286 
 
287 	CREATE NONCLUSTERED INDEX [<DRUG_3, sysname,>] 
288 		ON @ResultDatabaseSchema.[DRUG_EXPOSURE] ([days_supply]) 
289 			INCLUDE ([drug_concept_id]) 
290 
 
291 			 
292 
 
293 	CREATE NONCLUSTERED INDEX [<DRUG_4, sysname,>] 
294 		ON @ResultDatabaseSchema.[DRUG_EXPOSURE] ([refills]) 
295 			INCLUDE ([drug_concept_id]) 
296 
 
297 			 
298 
 
299 	CREATE NONCLUSTERED INDEX [<DRUG_5, sysname,>] 
300 		ON @ResultDatabaseSchema.[DRUG_EXPOSURE] ([quantity]) 
301 			INCLUDE ([drug_concept_id]) 
302 
 
303 			 
304 
 
305 	CREATE NONCLUSTERED INDEX [<DRUG_6, sysname,>] 
306 		ON @ResultDatabaseSchema.[DRUG_EXPOSURE] ([drug_concept_id]) 
307 			INCLUDE ([drug_source_value]) 
308 
 
309 			 
310 
 
311 /* DRUG_ERA */ 
312 
 
313 	CREATE NONCLUSTERED INDEX [<DRUG_ERA_1, sysname,>] 
314 		ON @ResultDatabaseSchema.[DRUG_ERA] ([person_id]) 
315 			INCLUDE ([drug_concept_id],[drug_era_start_date]) 
316 
 
317 		 
318 
 
319 /* MEASUREMENT */ 
320 
 
321 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_1, sysname,>] 
322 		ON @ResultDatabaseSchema.[MEASUREMENT] ([person_id]) 
323 			INCLUDE ([measurement_concept_id],[measurement_date]); 
324 
 
325 			 
326 
 
327 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_2, sysname,>] 
328 		ON @ResultDatabaseSchema.[MEASUREMENT] ([provider_id]); 
329 
 
330 		 
331 
 
332 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_3, sysname,>] 
333 		ON @ResultDatabaseSchema.[MEASUREMENT] ([visit_occurrence_id]); 
334 
 
335 		 
336 
 
337 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_4, sysname,>] 
338 		ON @ResultDatabaseSchema.[MEASUREMENT] ([value_as_number],[value_as_concept_id]); 
339 
 
340 		 
341 
 
342 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_5, sysname,>] 
343 		ON @ResultDatabaseSchema.[MEASUREMENT] ([value_as_number],[unit_concept_id]) 
344 			INCLUDE ([measurement_concept_id]); 
345 
 
346 			 
347 
 
348 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_6, sysname,>] 
349 		ON @ResultDatabaseSchema.[MEASUREMENT] ([value_as_number],[unit_concept_id],[range_low],[range_high]) 
350 			INCLUDE ([measurement_concept_id]); 
351 
 
352 			 
353 		 
354 	CREATE NONCLUSTERED INDEX [<MEASUREMENT_7, sysname,>] 
355 		ON @ResultDatabaseSchema.[MEASUREMENT] ([value_as_number]); 
356 
 
357 			 
358 
 
359 /* PROVIDER */ 
360 
 
361 	CREATE NONCLUSTERED INDEX [<PROVIDER_1, sysname,>] 
362 		ON @ResultDatabaseSchema.[PROVIDER] ([care_site_id]); 
363 			 
364 			 
365 
 
366 /* PAYER_PLAN_PERIOD */ 
367 
 
368 	CREATE NONCLUSTERED INDEX [<PAYER_PLAN_PERIOD_1, sysname,>] 
369 		ON @ResultDatabaseSchema.[PAYER_PLAN_PERIOD] ([person_id]) 
370 			INCLUDE ([payer_plan_period_start_date],[payer_plan_period_end_date]); 
371 
 
372 			 
373 
 
374 /* ACHILLES_results */ 
375 
 
376 	--CREATE NONCLUSTERED INDEX [<ACHILLES_RESULTS, sysname,>] 
377 		--ON @ResultDatabaseSchema.[ACHILLES_results] ([count_value]); 
378 
 
379  
