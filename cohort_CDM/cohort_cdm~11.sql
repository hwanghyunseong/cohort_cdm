 /************************************** 
  --encoding : UTF-8 
  --Author: �̼��� 
  --Date: 2017.01.18 
   
  @NHISDatabaseSchema : DB containing NHIS National Sample cohort DB 
  @NHIS_JK: JK table in NHIS NSC 
  @NHIS_20T: 20 table in NHIS NSC 
  @NHIS_30T: 30 table in NHIS NSC 
  @NHIS_40T: 40 table in NHIS NSC 
  @NHIS_60T: 60 table in NHIS NSC 
  @NHIS_GJ: GJ table in NHIS NSC 
   
  --Description: Care_site ���̺� ���� 
 			   1) ǥ����ȣƮDB���� ������� �⵵���� �ߺ� �ԷµǾ� ����. �����̵�, ���������� ��ȭ���� ���� ������ 
 			      ������, CDM������ 1���� ������� ���� �ϹǷ�, �ֱ� ����� �����͸� ��ȯ�� 
 			   2) place of service: �ѱ��� ��Ȳ�� ����Ͽ� ���ο� concept�� ������ (ETL ���Ǽ� ������ ��) 
  --Generating Table: CARE_SITE 
 ***************************************/ 
 
 
 /************************************** 
  1. ���̺� ���� 
 ***************************************/   
 Create table @ResultDatabaseSchema.CARE_SITE ( 
 	care_site_id 	integer primary key, 
 	care_site_name	varchar(255), 
 	place_of_service_concept_id	integer, 
 	location_id	integer, 
 	care_site_source_value	varchar(50), 
 	place_of_service_source_value	varchar(50) 
 ); 
 
 
 /************************************** 
  2. ������ �Է� 
 	: place_of_service_source_value - ����������ڵ�/������������� 
 									- ��������������� 1�ڸ� ������ ���, �տ� 0�� �ٿ��� 
 ***************************************/   
 INSERT INTO CARE_SITE 
 SELECT a.ykiho_id, 
 	null as care_site_name, 
 	case when a.ykiho_gubun_cd='10' then 4068130 --���պ���(Tertiary care hospital)  
 		 when a.ykiho_gubun_cd between '20' and '27' then 4318944 --�Ϲݺ���  Hospital 
 		 when a.ykiho_gubun_cd='28' then 82020103 --��纴��   
 		 when a.ykiho_gubun_cd='29' then 4268912 --���ſ�纴�� Psychiatric hospital  
 		 when a.ykiho_gubun_cd between '30' and '39' then 82020105 --�ǿ� 
 		 when a.ykiho_gubun_cd between '40' and '49' then 82020106 --ġ������ 
 		 when a.ykiho_gubun_cd between '50' and '59' then 82020107 --ġ���ǿ� 
 		 when a.ykiho_gubun_cd between '60' and '69' then 82020108 --����� 
 		 when a.ykiho_gubun_cd='70' then 82020109 --���Ǽ� 
 		 when a.ykiho_gubun_cd between '71' and '72' then 82020110 --�������� 
 		 when a.ykiho_gubun_cd between '73' and '74' then 82020111 --��������� 
 		 when a.ykiho_gubun_cd between '75' and '76' then 82020112 --���ں��Ǽ��� 
 		 when a.ykiho_gubun_cd='77' then 82020113 --�����Ƿ�� 
 		 when a.ykiho_gubun_cd between '80' and '89' then 4131032 --�౹ Pharmacy 
 		 when a.ykiho_gubun_cd='91' then 82020115 --�ѹ����պ��� 
 		 when a.ykiho_gubun_cd='92' then 82020116 --�ѹ溴�� 
 		 when a.ykiho_gubun_cd between '93' and '97' then 82020117 --���ǿ� 
 		 when a.ykiho_gubun_cd between '98' and '99' then 82020118 --�Ѿ�� 
 	end as place_of_service_concept_id, 
 	a.ykiho_sido as location_id, 
 	a.ykiho_id as care_site_source_value, 
 	(a.ykiho_gubun_cd + '/' + (case when len(a.org_type) = 1 then '0' + org_type else org_type end)) as place_of_service_source_value 
 FROM @NHISDatabaseSchema.@NHIS_YK a, (select ykiho_id, max(stnd_y) as max_stnd_y 
 	from @NHISDatabaseSchema.@NHIS_YK c 
 	group by ykiho_id) b 
 where a.ykiho_id=b.ykiho_id 
 and a.stnd_y=b.max_stnd_y 
