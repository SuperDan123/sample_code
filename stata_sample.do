/*
Project Name: Product Differentiation
Author: Dan Song
Date: 2023/06/08
Modify Date: 2024/05/01
*/
********************************************************************************


/* Part_1: Set $root */
********************************************************************************
return clear
capture project, doinfo
if (_rc == 0 & !mi(r(pname))) global root `r(pdir)'  // using -project-
else {  // running directly
    if ("${product_root}" == "") do `"`c(sysdir_personal)'product_diff.do"'
    do "${product_root}/code/set_environment.do"
}
********************************************************************************



/* Part_2: Clear data */
********************************************************************************
import delimited product_differentiation_books_20151001.txt
** Handling missing values
sort isbn
egen mis = rowmiss(publisher id author id print time idbook namerecommend price)
drop if mis > 0
drop mis
drop in 4949085/4949103 // Delete non-numeric values
destring isbn, replace
drop if isbn < 1000
** Property variation among the same ISBN
local regex_patterns "正版|正品|正品保证|原版|官方直营|官网直营|老店|旗舰店" ///
                    "特价" "[送赠]" "免费" "现货" "当天发货|速发" ///
                    "运费险" "包邮" "假一赔十" "配套" "优惠" "精品" ///
                    "超好用" "2015" "全套"
local num_patterns : word count `regex_patterns'
foreach pattern of local regex_patterns {
    local i = 1
    regexm title, gen(b`i') pattern("`pattern'")
    local i = `i' + 1
}
egen b_sd1-b_sd`num_patterns' = .
forvalues i = 1/`num_patterns' {
    bys isbn: egen b`i'_sd = sd(b`i')
}
** Calculate differences
egen diff_rough = rowtotal(b1_sd - b19_sd)
egen diff_rough1 = rowtotal(b1_sd - b18_sd)
********************************************************************************




/* Part_3: Summary Statistics */
********************************************************************************
sum diff_rough diff_rough1
codebook diff_rough diff_rough1
** Calculate standard deviations for variables b1 to b5
forvalues i = 1/5 {
    bys isbn: egen b`i'_sd = sd(b`i')
}
** Calculate differences and sum
local b_variables "b1 b2 b3 b4 b5"
local sd_variables "b1_sd b2_sd b3_sd b4_sd b5_sd"
local diff_variable "diff_rough"
forvalues i = 1/5 {
    local b_var : word `i' of `b_variables'
    local sd_var : word `i' of `sd_variables'
    quietly replace `diff_variable' = b`i'_sd - `diff_variable' if !missing(b`i'_sd)
}
sum `diff_variable'
** Generate binary indicator variable bi
gen bi = 1
replace bi = 0 if diff_sum == 0
** Calculate statistics by isbn
local variables "bi_sd amount ord_cnt count"
foreach var in `variables' {
    bys isbn: egen total_`var' = sum(`var')
}
** Keep only the first observation for each isbn
bys isbn: keep if _n == 1
** Rank by total sales ord
gsort -total_sales_ord
gen ranking_ord = _n
** Remove observations with missing values in spu title
rop if missing(spu_title)
** Rank by total sales ord again
gsort total_sales_ord
gen ranking_ord = _n
** Create binary variable binary
gen binary = 0 
replace binary = 1 if bl1_sd == .
** Remove observations with missing b1_sd
drop if missing(b1_sd)
* Plot graph
binscatter len_ratio ranking_ord, line(qfit) n(100)
binscatter len_ratio ranking_ord if binary == 1, line(qfit) n(28)
********************************************************************************



/* Part_4: Regressions and Results */
********************************************************************************
* Set loop variables
local loopvar group1
local num_regressions 10  // Number of regressions to run
forvalues i = 1/`num_regressions' {
    quietly reghdfe log_weekly_ord_cnt if tot_shipping_fee > 0 ///
        & `loopvar' == `i' [weight = weekly_ord_cnt], absorb(i.county_code_2015#i.quater) ///
        residuals(res_q)

    quietly reghdfe log_weekly_price if tot_shipping_fee > 0 ///
        & `loopvar' == `i' [weight = weekly_ord_cnt], absorb(i.county_code_2015#i.quater) ///
        residuals(res_p)

    quietly reghdfe res_q res_p if tot_shipping_fee > 0 ///
        & `loopvar' == `i' [weight = weekly_ord_cnt], absorb(i.item_id#i.week_of_year) ///
        vce(cluster county_code_2015)

    est store o`i'
    drop res*
}

* Generate esttab and coefplot commands using a loop
local esttab_commands ""
local coefplot_commands ""
forvalues i = 1/`num_regressions' {
    local esttab_cmd "esttab o`i', keep(res p) scalars(r2 within) "
    local coefplot_cmd "coefplot o`i', vertical graphregion(color(white)) ciopts(recast(rcep) keep(res p) mlabel format(%9.2g) xlabel("") ///
        yscale(r(-1.5(0.3)-8.3)) ytick(-1.5(0.3)-8.3) ylabel(-1.5(0.3)-8.3) /// 
		title(\"Demand Elasticity Using OLS: Method 1\")
    
    local esttab_commands `esttab_commands' `esttab_cmd' 
    local coefplot_commands `coefplot_commands' `coefplot_cmd' 
}

* Execute esttab and coefplot commands
`esttab_commands'
`coefplot_commands'
********************************************************************************



