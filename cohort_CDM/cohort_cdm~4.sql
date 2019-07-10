1 /************************************** 
2  --encoding : UTF-8 
3  --Author: 이성원, 조재형 
4  --Date: 2017.09.12 
5   
6  @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
7  @NHIS_JK: JK table in NHIS NSC 
8  @NHIS_20T: 20 table in NHIS NSC 
9  @NHIS_30T: 30 table in NHIS NSC 
10  @NHIS_40T: 40 table in NHIS NSC 
11  @NHIS_60T: 60 table in NHIS NSC 
12  @NHIS_GJ: GJ table in NHIS NSC 
13  --Description: Observation_period 테이블 생성 
14  --Generating Table: OBSERVATION_PERIOD 
15 ***************************************/ 
16 
 
17 /************************************** 
18  1. 데이터 입력 
19     1) 관측시작일: 자격년도.01.01이 디폴트. 출생년도가 그 이전이면 출생년도.01.01 
20 	2) 관측종료일: 자격년도.12.31이 디폴트. 사망년월이 그 이후면 사망년.월.마지막날 
21 	3) 사망 이후 가지는 자격 제외 
22 ***************************************/  
23 
 
24 
 
25 -- step 1 
26 select 
27       a.person_id as person_id,  
28       case when a.stnd_y >= b.year_of_birth then convert(date, convert(varchar, a.stnd_y) + '0101', 112)  
29             else convert(date, convert(varchar, b.year_of_birth) + '0101', 112)  
30       end as observation_period_start_date, --관측시작일 
31       case when convert(date, a.stnd_y + '1231', 112) > c.death_date then c.death_date 
32             else convert(date, a.stnd_y + '1231', 112) 
33       end as observation_period_end_date --관측종료일 
34 into #observation_period_temp1 
35 from @NHISDatabaseSchema.@NHIS_JK a, 
36       @ResultDatabaseSchema.person b left join @ResultDatabaseSchema.death c 
37       on b.person_id=c.person_id 
38 where a.person_id=b.person_id 
39 --(12132633개 행이 영향을 받음), 00:05 
40 
 
41 -- step 2 
42 select *, row_number() over(partition by person_id order by observation_period_start_date, observation_period_end_date) AS id 
43 into #observation_period_temp2 
44 from #observation_period_temp1 
45 where observation_period_start_date < observation_period_end_date -- 사망 이후 가지는 자격을 제외시키는 쿼리 
46 --(12132529개 행이 영향을 받음), 00:08 
47 
 
48 
 
49 -- step 3 
50 select  
51 	a.*, datediff(day, a.observation_period_end_date, b.observation_period_start_date) as days 
52 	into #observation_period_temp3 
53 	from #observation_period_temp2 a 
54 		left join 
55 		#observation_period_temp2 b 
56 		on a.person_id = b.person_id 
57 			and a.id = cast(b.id as int)-1 
58 	order by person_id, id 
59 --(12132529개 행이 영향을 받음), 00:15 
60 
 
61 -- step 4 
62 select 
63 	a.*, CASE WHEN id=1 THEN 1 
64    ELSE SUM(CASE WHEN DAYS>1 THEN 1 ELSE 0 END) OVER(PARTITION BY person_id ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)+1 
65    END AS sumday 
66    into #observation_period_temp4 
67    from #observation_period_temp3 a 
68    order by person_id, id 
69 --(12132529개 행이 영향을 받음), 00:12 
70 
 
71 
 
72 -- step 5 
73 select identity(int, 1, 1) as observation_period_id, 
74 	person_id, 
75 	min(observation_period_start_date) as observation_period_start_date, 
76 	max(observation_period_end_date) as observation_period_end_date, 
77 	44814725 as PERIOD_TYPE_CONCEPT_ID 
78 INTO @ResultDatabaseSchema.OBSERVATION_PERIOD 
79 from #observation_period_temp4 
80 group by person_id, sumday 
81 order by person_id, observation_period_start_date 
82 --(1256091개 행이 영향을 받음), 00:10 
83 
 
84 drop table #observation_period_temp1, #observation_period_temp2, #observation_period_temp3, #observation_period_temp4 
