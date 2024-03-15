
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
                    )
                    ,'yyyymmdd'),1,6) IN ('202106')
AND bc_type = 'B'
AND item_id IN (
    SELECT item_id 
    FROM lha_research_dev.new_item_growth_plan_tstage_june_2021_cohort_item_list
    );
;


CREATE TABLE new_item_growth_plan_tstage_june_2021_cohort_all AS
SELECT t3.item_id
 ,t3.ds
 ,t4.city
 ,t4.prov
 ,t4.cate_id
 ,t4.cate_level1_id
 ,t4.rdm_seller_id
 ,t4.seller_bc_type
 ,t4.bc_type
 ,t4.old_starts
 ,t4.starts
 ,t4.first_starts_time
 ,t3.ipv
 ,t3.ipv_uv
 ,t3.amount
 ,t3.ord_cnt
 ,t3.sys_def_pos_comt_tra_num
 ,t3.pos_comt_trade_num
 ,t3.mid_comt_trade_num
 ,t3.neg_comt_trade_num
 ,t3.comt_trade_num
 ,t3.item_gmt_create
 ,t3.change_type
 ,t3.level
 ,t3.level_score
 ,t3.last_level
 ,t3.level_change
 ,t3.gmv_today
 ,t3.gmv_total
 ,t3.operate_score
 ,t3.start_time
 ,t3.time_scope
 ,t3.ss_threshold_score
 ,t3.ss_support_status
 ,t3.ss_item_level
 ,t3.ss_support_the_day
 ,t3.ginza_status
 ,t3.ginza_plan_id
 ,t3.qty
FROM (
    SELECT COALESCE(t1.item_id,t2.item_id) AS item_id
    ,COALESCE(t1.ds,t2.ds) AS ds
    ,ipv
    ,ipv_uv
    ,amount
    ,ord_cnt
    ,sys_def_pos_comt_tra_num
    ,pos_comt_trade_num
    ,mid_comt_trade_num
    ,neg_comt_trade_num
    ,comt_trade_num
    ,item_gmt_create
    ,change_type
    ,level
    ,level_score
    ,last_level
    ,level_change
    ,gmv_today
    ,gmv_total
    ,operate_score
    ,start_time
    ,time_scope
    ,ss_threshold_score
    ,ss_support_status
    ,ss_item_level
    ,ss_support_the_day
    ,ginza_status
    ,ginza_plan_id
    ,qty
    FROM (
        SELECT item_id
        ,ds
        ,ipv
        ,ipv_uv
        ,amount
        ,ord_cnt
        ,sys_def_pos_comt_tra_num
        ,pos_comt_trade_num
        ,mid_comt_trade_num
        ,neg_comt_trade_num
        ,comt_trade_num
        FROM lha_research_dev.new_item_growth_plan_tst
        age_june_2021_cohort_item_gmv_ipv_review_merged_1
        ) t1
    FULL OUTER JOIN (
        SELECT item_id
        ,ds
        ,item_gmt_create
        ,change_type
        ,level
        ,level_score
        ,last_level
        ,level_change
        ,gmv_today
        ,gmv_total
        ,operate_score
        ,start_time
        ,time_scope
        ,ss_threshold_score
        ,ss_support_status
        ,ss_item_level
        ,ss_support_the_day
        ,ginza_status
        ,ginza_plan_id
        ,qty
        FROM lha_research_dev.new_item_growth_plan_tstage_june_2021_cohort
        ) t2
        ON t1.item_id = t2.item_id
        AND t1.ds = t2.ds
    ) t3
JOIN lha_research_dev.new_item_growth_plan_tstage_june_2021_cohort_ite
m_base_information_1 t4
ON t3.item_id = t4.item_id
;