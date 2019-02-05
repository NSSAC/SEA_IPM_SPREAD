#!/bin/bash
DB="../results/results.db"

function cartall(){
# generating cart output by moore and latency
sqlite3 $DB <<!
.mode csv
.header on
.output simulation_output.csv
SELECT * FROM eval_BGD
WHERE likelihood>6.5 and
alpha_ld>0
!
Rscript ../scripts/cart_multivariate.R
}

function cartml(){
# generating cart output by moore and latency
for m in `seq 1 3`
do
for l in `seq 1 3`
do
sqlite3 $DB <<!
.mode csv
.header on
.output simulation_output.csv
SELECT * FROM eval_BGD
WHERE likelihood>0
AND moore=$m
AND latency_period=$l
!
Rscript ../scripts/cart_multivariate.R
mv cart_tree.pdf m${m}_l${l}_tree.pdf
done
done
mv m*_tree.pdf ../results/cart/
}

function cart(){
# step 3
sqlite3 $DB <<!
.mode csv
.header on
.output simulation_output.csv
SELECT * FROM eval_BGD_2018_06_24
WHERE likelihood>5.5
!
Rscript ../scripts/cart_multivariate.R
mv cart_tree.pdf 3_tree.pdf
exit
# step 1
sqlite3 $DB <<!
.mode csv
.header on
.output simulation_output.csv
SELECT * FROM eval_BGD_2018_06_24
WHERE alpha_sd % 100=0 AND alpha_ld % 100=0 AND alpha_fm % 100=0
!
Rscript ../scripts/cart_multivariate.R
mv cart_tree.pdf 1_tree.pdf
# step 2
sqlite3 $DB <<!
.mode csv
.header on
.output simulation_output.csv
SELECT * FROM eval_BGD_2018_06_24
WHERE alpha_sd % 100=0 AND alpha_ld % 100=0 AND alpha_fm % 100=0
AND likelihood>5.5
!
Rscript ../scripts/cart_multivariate.R
mv cart_tree.pdf 2_tree.pdf
}

function rf(){
../scripts/plot.sh -o rf_importance_all_mse \
   -c mathematica \
   -T hist \
   -x "\\\%IncMSE" \
   -f "all:18" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set xtics font \",15\"; \
       set style data points; \
       set nokey;" \
       -p "plot '< gsort -t, -k2,2 -n -r ../results/rf/rf_importance_all.csv' u 2:(-\$0):yticlabel(1) ls 1 pt 7"

../scripts/plot.sh -o rf_importance_short_mse \
   -c mathematica \
   -T hist \
   -x "\\\%IncMSE" \
   -f "all:16" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set xtics font \",15\"; \
       set style data points; \
       set nokey;" \
       -p "plot '< gsort -t, -k2,2 -n -r ../results/rf/rf_importance_short.csv' u 2:(-\$0):yticlabel(1) ls 2 pt 7"

../scripts/plot.sh -o rf_importance_long_mse \
   -c mathematica \
   -T hist \
   -x "\\\%IncMSE" \
   -f "all:16" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set xtics font \",15\"; \
       set style data points; \
       set nokey;" \
       -p "plot '< gsort -t, -k2,2 -n -r ../results/rf/rf_importance_long.csv' u 2:(-\$0):yticlabel(1) ls 3 pt 7"

../scripts/plot.sh -o rf_importance_all_purity \
   -c mathematica \
   -T hist \
   -x "IncNodePurity" \
   -f "all:18" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set style data points; \
       set nokey;" \
       -p "plot '../results/rf/rf_importance_all.csv' u 3:(-\$0):yticlabel(1) ls 1 pt 7"

../scripts/plot.sh -o rf_importance_short_purity \
   -c mathematica \
   -T hist \
   -x "IncNodePurity" \
   -f "all:16" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set style data points; \
       set nokey;" \
       -p "plot '../results/rf/rf_importance_short.csv' u 3:(-\$0):yticlabel(1) ls 2 pt 7"

../scripts/plot.sh -o rf_importance_long_purity \
   -c mathematica \
   -T hist \
   -x "IncNodePurity" \
   -f "all:16" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set style data points; \
       set nokey;" \
       -p "plot '../results/rf/rf_importance_long.csv' u 3:(-\$0):yticlabel(1) ls 3 pt 7"
../scripts/plot.sh -o rf_importance_long_purity \
   -c mathematica \
   -T hist \
   -x "IncNodePurity" \
   -f "all:16" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set style data points; \
       set nokey;" \
       -p "plot '../results/rf/rf_importance_long.csv' u 3:(-\$0):yticlabel(1) ls 3 pt 7"
mv rf_importance_*tex ../results/rf/
mv rf_importance_*gp ../results/rf/
mv rf_importance_*pdf ../results/rf/
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
