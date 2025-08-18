/*Brand elasticity project June 2025*/

gen date_num = date(date, "YMD")
format date_num %td
order date_num, after(date)
sort country panelist brand date

gen price_unit= total_value_sales/ total_unit_sales

/* transform to monthly estimation*/
generate year = year(date_num)
generate month = month(date_num)
generate monthly_date = ym(year, month)
format monthly_date %tm
order monthly_date, after(date_num)
order brand, after(panelist)
order price_unit, after(monthly_date)

/* Aggregating price and sales elasticities*/
sort country panelist brand monthly_date
egen id1 = group(country panelist brand monthly_date)
order id1, after(monthly_date)
egen id2=group(country brand)
order id2, after(id1)

/*cleaning dataset & code*/
bysort country brand id2: gen tag = _n == 1
list country brand id2 if tag
drop tag

keep if id2 == 62 | id2 == 118 | id2 == 140 | id2 == 50 | id2 == 145 | id2 == 36 | id2 == 139 | id2 == 67 | id2 == 207 | id2 == 231 | id2 == 304 | id2 == 173 | id2 == 213 | id2 == 269 | id2 == 171 | id2 == 363 | id2 == 340 | id2 == 252 | id2 == 441 | id2 == 422 | id2 == 396 | id2 == 416 | id2 == 438 | id2 == 399 | id2 == 407 | id2 == 435 | id2 == 704 | id2 == 721 | id2 == 726 | id2 == 728 | id2 == 698 | id2 == 686 | id2 == 773 | id2 == 694 | id2 == 660 | id2 == 758 | id2 == 384 | id2 == 381 | id2 == 380 | id2 == 629 | id2 == 546 | id2 == 610 | id2 == 460 | id2 == 488 | id2 == 508 | id2 == 533 | id2 == 607 | id2 == 461 | id2 == 559 | id2 == 822 | id2 == 806 | id2 == 825 | id2 == 790 | id2 == 818 | id2 == 794 | id2 == 791 | id2 == 824 | id2 == 805 | id2 == 940 | id2 == 895 | id2 == 858 | id2 == 928 | id2 == 845 | id2 == 962 | id2 == 854 | id2 == 885 | id2 == 871 | id2 == 984

/*Creating average value volume sales and price per unit variables - per country, household & brand*/
rename total_volume_sales Q
rename price_unit P
order Q, after (id1)

label variable Q "total volume sales"
label variable P "price per unit"

bysort id1: egen Q1=mean(Q)
order Q1, after(Q)
bysort id1: egen P1=mean(P)
order P1, after(P)

gen lnQ=ln(Q1)
gen lnP=ln(P1)
order lnP lnQ, after (id1)
label variable lnP "log price per unit"
label variable lnQ "log volume sales"

/*Cleaning dataset*/
drop if id1[_n]==id1[_n-1]
drop retailer barcode pl total_unit_sales total_value_sales year month

/*-------------------------------------------------------------------------------------------------------------------------------*/

/*The solution, with monthly fixed effects*/
xtset monthly_date
bysort id2: xtreg lnQ lnP, fe cluster(monthly_date)
