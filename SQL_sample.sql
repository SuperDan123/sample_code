 
CREATE TABLE new_item_growth_plan_tstage_June_2021_cohort_item_list AS
SELECT DISTINCT item_id
FROM bm_dw.dwd_na_growth_plan_item_info_di
WHERE ds>='20210601' AND ds <= '20211231'
AND substr(to_char(first_starts_time, 'yyyymmdd'),1,6) IN ('202106')
AND cate_level1_id = '50008090'
;


CREATE TABLE new_item_growth_plan_tstage_June_2021_cohort_item_base_information_1 AS
SELECT item_id
 ,ds
 ,reserve_price
 ,city
 ,prov
 ,cate_id
 ,cate_level1_id
 ,md5(seller_id) AS rdm_seller_id
 ,seller_bc_type
 ,bc_type
 ,old_starts
 ,starts
 ,to_char(
 FROM_UNIXTIME(
 CAST(
 keyvalue(features, ';', ':', 'first_starts_time') AS BIGINT
 )/1000
 )
 ,'yyyymmdd'
 ) AS first_starts_time
 ,title
FROM tbcdm.dim_tb_itm
WHERE cate_level1_id IN ('50008090')
AND ds IN ('20210630')
AND SUBSTR(
    to_char(
        FROM_UNIXTIME(
            CAST(
                keyvalue(
                    features, ';', ':', 'first_starts_time'
                    ) AS BIGINT 
                )/1000 
                    ),'yyyymmdd'),1,6) IN ('202106')
AND bc_type = 'B'
AND item_id IN (
    SELECT item_id 
    FROM lha_research_dev.new_item_growth_plan_tstage_june_2021_cohort_item_list
    );
;