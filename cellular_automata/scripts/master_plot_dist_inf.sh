#!/bin/bash
function msa_moore(){
rm -f model-*csv
t=60;
for m in `seq 1 3`
do
# model A
sqlite3 ../results/results.db <<! > model-A_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),avg(cumprob),avg(cumprob*cumprob) FROM dist_inf_0p
WHERE alpha_ld=0
AND season_ind=2
AND time=$t
AND moore=$m
GROUP BY distance
ORDER BY distance;
!
# model B
sqlite3 ../results/results.db <<! > model-B_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),avg(cumprob),avg(cumprob*cumprob) FROM dist_inf_0p
WHERE alpha_ld>0
AND season_ind=2
AND time=$t
AND moore=$m
GROUP BY distance
ORDER BY distance;
!
done #moore

../scripts/plot.sh -o dist_prob_A_moore \
   -c mathematica \
   -y "Accumulated probabilities at \$t=60\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 7; \
       set xrange [1000:3000]; \
       set xlabel offset 0,.7; \
       set xtics offset 0,-.4;" \
   -p "plot \
      'model-A_m1_$t.csv' u 1:2 ls 1 pt 5 ti   '\$\\\r_M=1\$', \
      'model-A_m2_$t.csv' u 1:2 ls 1 pt 7 ti   '\$\\\r_M=2\$', \
      'model-A_m3_$t.csv' u 1:2 ls 1 pt 9 ti   '\$\\\r_M=3\$', \
      '.cell_count_rep.csv' u (1.0):2:(.1):1 ls 4 fill solid .4 ti 'max'"

../scripts/plot.sh -o dist_prob_B_moore \
   -c mathematica \
   -y "Accumulated probabilities at \$t=60\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 7; \
       set xrange [1000:3000]; \
       set xlabel offset 0,.7; \
       set xtics offset 0,-.4;" \
   -p "plot \
      'model-B_m1_$t.csv' u 1:2 ls 1 pt 5 ti   '\$\\\r_M=1\$', \
      'model-B_m2_$t.csv' u 1:2 ls 1 pt 7 ti   '\$\\\r_M=2\$', \
      'model-B_m3_$t.csv' u 1:2 ls 1 pt 9 ti   '\$\\\r_M=3\$', \
      '.cell_count_rep.csv' u (1.0):2:(.1):1 ls 4 fill solid .4 ti 'max'"
mv dist_prob_*_moore.pdf ../results/dist_inf_plots/
mv dist_prob_*_moore.gp ../results/dist_inf_plots/
mv dist_prob_*_moore.tex ../results/dist_inf_plots/
}

function msa_box(){
rm -f model-*csv
t=60;
for m in `seq 1 3`
do
# model A
sqlite3 ../results/results.db <<! > model-A_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),cumprob FROM dist_inf_0p
WHERE alpha_ld=0
AND season_ind=2
AND time=$t
AND moore=$m
AND distance>=1000 AND distance<=3000
ORDER BY distance;
!
# model B
sqlite3 ../results/results.db <<! > model-B_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),cumprob FROM dist_inf_0p
WHERE alpha_ld>0
AND season_ind=2
AND time=$t
AND moore=$m
AND distance>=1000 AND distance<=3000
ORDER BY distance;
!
done #m

# AA: dirty stuff for boxplot
awk -F, -v OFS=, '{if ($1>=1000 && $1<=3000) print}' ../obj/cell_count_distance.csv | sed -e '/^0/d' > .cell_count.csv
cat .cell_count.csv .cell_count.csv .cell_count.csv .cell_count.csv \
    | sort -t, -k1,1 -n > .cell_count_rep.csv

../scripts/plot.sh -o dist_prob_A_box \
   -c mathematica \
   -y "Accumulated probabilities at \$t=60\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key Right r t width 5; \
       set style data boxplot; \
       set style boxplot nooutliers; \
       set xlabel offset 0,-.7; \
       set xtics font \",12\" rotate by -30 offset -2,-.1 scale 0 autojustify;" \
   -p "plot \
      'model-A_m1_$t.csv' u (1.0):2:(.5):1 ls 1 fill solid .4 ti '\$r_\\textrm{M}\$=1', \
      'model-A_m2_$t.csv' u (1.0):2:(.3):1 ls 2 fill solid .4 ti '2', \
      'model-A_m3_$t.csv' u (1.0):2:(.1):1 ls 3 fill solid .4 ti '3', \
      '.cell_count_rep.csv' u (1.0):2:(.1):1 ls 4 fill solid .4 ti 'max'"

../scripts/plot.sh -o dist_prob_B_box \
   -c mathematica \
   -y "Accumulated probabilities at \$t=60\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key Right r t width 5; \
       set style data boxplot; \
       set style boxplot nooutliers; \
       set xlabel offset 0,-.7; \
       set xtics font \",12\" rotate by -30 offset -2,-.1 scale 0 autojustify;" \
   -p "plot \
      'model-B_m1_$t.csv' u (1.0):2:(.5):1 ls 1 fill solid .4 ti '\$r_\\textrm{M}\$=1', \
      'model-B_m2_$t.csv' u (1.0):2:(.3):1 ls 2 fill solid .4 ti '2', \
      'model-B_m3_$t.csv' u (1.0):2:(.1):1 ls 3 fill solid .4 ti '3', \
      '.cell_count_rep.csv' u (1.0):2:(.1):1 ls 4 fill solid .4 ti 'max'"

mv dist_prob_*_box.pdf ../results/dist_inf_plots/
mv dist_prob_*_box.gp ../results/dist_inf_plots/
mv dist_prob_*_box.tex ../results/dist_inf_plots/
}

function msa_perc(){
rm -f model-*csv
t=60;
for m in `seq 1 3`
do
for perc in `echo "0 25 50"`
do
# model A
sqlite3 ../results/results.db <<! > model-A_p${perc}_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),avg(cumprob),avg(cumprob*cumprob) FROM dist_inf_${perc}p
WHERE alpha_ld=0
AND season_ind=2
AND time=$t
AND moore=$m
GROUP BY distance
ORDER BY distance;
!
# model B
sqlite3 ../results/results.db <<! > model-B_p${perc}_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),avg(cumprob),avg(cumprob*cumprob) FROM dist_inf_${perc}p
WHERE alpha_ld>0
AND season_ind=2
AND time=$t
AND moore=$m
GROUP BY distance
ORDER BY distance;
!
done #perc
done #m

../scripts/plot.sh -o dist_prob_A_perc \
   -c mathematica \
   -y "Accumulated probabilities at \$t=60\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 5; \
       set xrange [1000:3000]; \
       set xlabel offset 0,.7; \
       set xtics offset 0,-.4;" \
   -p "plot \
      'model-A_p0_m1_$t.csv' u 1:2 ls 1 pt 5 ti  '1,0.0', \
      'model-A_p25_m1_$t.csv' u 1:2 ls 1 pt 7 ti '1,0.25', \
      'model-A_p50_m1_$t.csv' u 1:2 ls 1 pt 9 ti '1,0.50', \
      'model-A_p0_m2_$t.csv' u 1:2 ls 2 pt 5 ti  '2,0.0', \
      'model-A_p25_m2_$t.csv' u 1:2 ls 2 pt 7 ti '2,0.25', \
      'model-A_p50_m2_$t.csv' u 1:2 ls 2 pt 9 ti '2,0.50', \
      'model-A_p0_m3_$t.csv' u 1:2 ls 3 pt 5 ti  '3,0.0', \
      'model-A_p25_m3_$t.csv' u 1:2 ls 3 pt 7 ti '3,0.25', \
      'model-A_p50_m3_$t.csv' u 1:2 ls 3 pt 9 ti '3,0.50', \
      '../obj/cell_count_distance.csv' u 1:2 ls 4 dashtype 2 ti  'max'"

../scripts/plot.sh -o dist_prob_B_perc \
   -c mathematica \
   -y "Accumulated probabilities at \$t=60\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 5; \
       set xrange [1000:3000]; \
       set xlabel offset 0,.7; \
       set xtics offset 0,-.4;" \
   -p "plot \
      'model-B_p0_m1_$t.csv' u 1:2 ls 1 pt 5 ti  '1,0.0', \
      'model-B_p25_m1_$t.csv' u 1:2 ls 1 pt 7 ti '1,0.25', \
      'model-B_p50_m1_$t.csv' u 1:2 ls 1 pt 9 ti '1,0.50', \
      'model-B_p0_m2_$t.csv' u 1:2 ls 2 pt 5 ti  '2,0.0', \
      'model-B_p25_m2_$t.csv' u 1:2 ls 2 pt 7 ti '2,0.25', \
      'model-B_p50_m2_$t.csv' u 1:2 ls 2 pt 9 ti '2,0.50', \
      'model-B_p0_m3_$t.csv' u 1:2 ls 3 pt 5 ti  '3,0.0', \
      'model-B_p25_m3_$t.csv' u 1:2 ls 3 pt 7 ti '3,0.25', \
      'model-B_p50_m3_$t.csv' u 1:2 ls 3 pt 9 ti '3,0.50', \
      '../obj/cell_count_distance.csv' u 1:2 ls 4 dashtype 2 ti  'max'"

mv dist_prob_*_perc.pdf ../results/dist_inf_plots/
mv dist_prob_*_perc.gp ../results/dist_inf_plots/
mv dist_prob_*_perc.tex ../results/dist_inf_plots/
}

function msa_intervene(){
rm -f model-*csv
t=108
for m in `seq 1 3`
do
for s in `seq 2 3`
do
# model B
sqlite3 ../results/results.db <<! > model-B_s${s}_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),avg(cumprob),avg(cumprob*cumprob) FROM dist_inf_0p
WHERE alpha_ld>0
AND season_ind=$s
AND time=$t
AND moore=$m
GROUP BY distance
ORDER BY distance;
!
done #perc
done #m

../scripts/plot.sh -o dist_prob_B_int \
   -c mathematica \
   -y "Accumulated probabilities at \$t=$t\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 5; \
       set xrange [1000:3000]; \
       set xlabel offset 0,.7; \
       set xtics offset 0,-.4;" \
   -p "plot \
      'model-B_s2_m1_$t.csv' u 1:2 ls 1 pt 5 ti  '1', \
      'model-B_s3_m1_$t.csv' u 1:2 ls 1 pt 7 ti '1', \
      'model-B_s2_m2_$t.csv' u 1:2 ls 2 pt 5 ti  '2', \
      'model-B_s3_m2_$t.csv' u 1:2 ls 2 pt 7 ti '2', \
      'model-B_s2_m3_$t.csv' u 1:2 ls 3 pt 5 ti  '3', \
      'model-B_s3_m3_$t.csv' u 1:2 ls 3 pt 7 ti '3', \
      '../obj/cell_count_distance.csv' u 1:2 ls 4 dashtype 2 ti  'max'"

mv dist_prob_*_int.pdf ../results/dist_inf_plots/
mv dist_prob_*_int.gp ../results/dist_inf_plots/
mv dist_prob_*_int.tex ../results/dist_inf_plots/
}

function dist_inf_country(){ #IGNORE
country=$1
t=48
for m in `seq 1 3`
do
for s in `seq 2 2; seq 4 5`
do
# model B
sqlite3 ../results/results.db <<! > model-B_s${s}_m${m}_$t.csv
.mode csv
SELECT CAST(distance as int),avg(cumprob),avg(cumprob*cumprob) FROM dist_inf_country
WHERE alpha_ld=0
AND country='$country'
AND season_ind=$s
AND time=$t
AND moore=$m
GROUP BY distance
ORDER BY distance;
!
done #perc
done #m

##       'model-B_s2_m1_$t.csv' u 1:2 ls 1 pt 5 ti  '1', \
##       'model-B_s5_m1_$t.csv' u 1:2 ls 1 pt 7 ti '1', \
##       'model-B_s2_m2_$t.csv' u 1:2 ls 2 pt 5 ti  '2', \
##       'model-B_s5_m2_$t.csv' u 1:2 ls 2 pt 7 ti '2', \
##       'model-B_s2_m3_$t.csv' u 1:2 ls 3 pt 5 ti  '3', \
##       'model-B_s5_m3_$t.csv' u 1:2 ls 3 pt 7 ti '3', \

#../scripts/plot.sh -o ${country}_dist_prob_B_int \
../scripts/plot.sh -o ${country}_dist_prob_A_int \
   -c mathematica \
   -y "Accumulated probabilities at \$t=$t\$" \
   -x "Distance from first report location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 5; \
       set xlabel offset 0,.7; \
       set xtics offset 0,-.4;" \
   -p "plot \
      'model-B_s2_m1_$t.csv' u 1:2 ls 2 pt 5 ti  'no int', \
      'model-B_s5_m1_$t.csv' u 1:2 ls 2 pt 7 ti 'int'"
      #'../obj/cell_count_distance_${country}.csv' u 1:2 ls 4 dashtype 2 ti  'max'"
      exit

mv ${country}_dist_prob_*_int.pdf ../results/dist_inf_plots/
mv ${country}_dist_prob_*_int.gp ../results/dist_inf_plots/
mv ${country}_dist_prob_*_int.tex ../results/dist_inf_plots/
}

function master_country_box(){ 
#dist_inf_country VN
#dist_inf_country PH
#dist_inf_country BD
#dist_inf_country TH
country_box BD 48
country_box TH 48
country_box VN 48
country_box PH 48
country_box IN 48
country_box MA 48
}

function country_box(){ #IGNORE
rm -f *csv
country=$1
t=$2
## # extract distances
## dist=$(
## sqlite3 ../results/results.db <<!
## SELECT DISTINCT distance FROM dist_inf_country
## WHERE alpha_ld>0
## AND country='$country'
## AND time=$t
## ORDER BY distance;
## !
## )

## plotString=""
# data files
for s in `seq 2 2; seq 4 5`
do
outFile="model-B_s${s}_$t.csv"
if [[ "$country" == "PH" ]]; then
    PH_SEED='AND seed=103'
else
    PH_SEED=''
fi
# model B
sqlite3 ../results/results.db <<! > $outFile
.mode csv
SELECT CAST(distance as int),cumprob FROM dist_inf_country
WHERE alpha_ld>0
AND country='$country' $PH_SEED
AND season_ind=$s
AND time=$t
AND distance>0 AND distance<=1400
ORDER BY distance,cumprob;
!
#AND moore=1 and beta>0 and kappa=500
##plotString="$plotString '$outFile' u ($d):2 noti, "
## done #dist
## done #m
done #season

wc -l $outFile

# AA: dirty stuff for boxplot
awk -F, -v OFS=, '{if ($1>0 && $1<=1400) print $1,$2,NR-1}' ../obj/cell_count_distance_${country}.csv | sed -e '/^0/d' > .cell_count.csv

## cat .cell_count.csv .cell_count.csv .cell_count.csv .cell_count.csv \
##     | sort -t, -k1,1 -n > .cell_count_rep.csv

../scripts/plot.sh -o ${country}_dist_prob_B_box \
   -c mathematica \
   -y "Accumulated probabilities at \$t=$t\$" \
   -x "Distance from seeded location (kms)" \
   -f "all:15" \
   -a "unset title; \
       set key r t width 8; \
       set xlabel offset 0,.7; \
       set style line 1 lw 7; \
       set style line 2 lw 7; \
       set style line 4 lw 7; \
       set style data boxplot; \
       set style boxplot nooutliers; \
       set xtics offset 0,-.4;" \
   -p "plot \
   'model-B_s2_$t.csv' u (1.0):2:(.5):1 ls 1 fill solid .4 ti 'No interv.', \
   'model-B_s5_$t.csv' u (1.0):2:(.2):1 ls 2 fill solid .4 ti 'Interv.', \
   '.cell_count.csv' u 3:2 w points ls 4 ti 'max'"

##   'model-B_s4_$t.csv' u (1.0):2:(.3):1 ls 2 fill solid .4 ti 'Interv. 50\\%', \
mv ${country}_dist_prob_*_box.pdf ../results/dist_inf_plots/
mv ${country}_dist_prob_*_box.gp ../results/dist_inf_plots/
mv ${country}_dist_prob_*_box.tex ../results/dist_inf_plots/
}

function country_cell_count(){
# AA: search for "AA" in haversine_country and comment out line.
# master_plot_dist_inf.sh country_cell_count TH | sort -k1,1 -n > ../obj/cell_count_distance_TH.csv
country=$1
# set all cells not belonging to the country to 0
#python ../scripts/haversine_country.py ../obj/res_precip1_b0_k0_s0_sm5_m0_st0_ed0_a-0-0-0.csv 5 $country ../data/seed_files/seed_${country}_radial.csv
python ../scripts/haversine_country.py ../obj/res_precip1_b0_k0_s0_sm5_m0_st0_ed0_a-0-0-0.csv 5 $country ../data/seed_files/seed_PHL-MSC.csv
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
