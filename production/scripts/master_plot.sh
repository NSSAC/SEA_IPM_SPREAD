#!/bin/bash
## tags: rotate, rectangle, label
DB="../../data_and_obj.db"

function relative_prod() { #IGNORE
grep $1 ../obj/seasonal_production_precip1.csv | awk -F, \
    '{for(i=1;i<13;i++){m[i]=$(i+2); sum+=$(i+2)} \
    for(i=1;i<13;i++) printf "%g,%g,%g\n",i+.5,m[i],m[i]/sum}'
}

function eggplant_BGD(){ #IGNORE
sqlite3 $DB <<! > .temp.eggplant_BGD 
.mode csv
SELECT (eggplant_1_rabi/(eggplant_1_rabi+eggplant_2_kharif+.0)/6),
(eggplant_2_kharif/(eggplant_1_rabi+eggplant_2_kharif+.0)/6) 
FROM production_BGD
WHERE admin='${1}';
!
awk -F, '{for(m=1;m<=4;m++) printf "%g,%g\n",m+.5,$1; \
    for(m=5;m<=10;m++) printf "%g,%g\n",m+.5,$2; \
    for(m=11;m<=12;m++) printf "%g,%g\n",m+.5,$1}' .temp.eggplant_BGD > ${1}_eggplant.csv
}

function relative_prod_BGD() {
relative_prod "^667798" > rangpur.csv
relative_prod "^654842" > dhaka.csv
relative_prod "^659155" > rajshahi.csv
relative_prod "^647648" > chittagong.csv
relative_prod "^650519" > khulna.csv

../scripts/plot.sh -o prod_tomato_BGD \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set style rect fc lt -1 fs transparent solid 0.15 noborder; \
       set obj rect from 8, graph 0 to 12, graph 1; \
       set label \"\\\parbox{2cm}{Sowing \\\& transplanting}\" at 9,graph 0.5; \
       set style rect fc lt -1 fs transparent solid 0.25 noborder; \
       set obj rect from 12, graph 0 to 13, graph 1; \
       set obj rect from 1, graph 0 to 2, graph 1; \
       set label \"\\\parbox{2cm}{Harvesting}\" at 1.5,graph 0 rotate by 90 left; \
       set label \"\\\parbox{2cm}{Harvesting}\" at 12.5,graph 0 rotate by 90 left; \
       set key c t width 8; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "set style fill transparent solid .5; \
      plot \
      'rangpur.csv' u 1:3 ti 'Rangpur', \
      'dhaka.csv' u 1:3 ti 'Dhaka', \
      'chittagong.csv' u 1:3 ti 'Chittagong', \
      'khulna.csv' u 1:3 ti 'Khulna', \
      'rajshahi.csv' u 1:3 ti 'Rajshahi'"

mv prod_tomato_BGD.tex ../results/
mv prod_tomato_BGD.gp ../results/
mv prod_tomato_BGD.pdf ../results/

../scripts/plot.sh -o prod_potato_BGD \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set style rect fc lt -1 fs transparent solid 0.15 noborder; \
       set obj rect from 9, graph 0 to 13, graph 1; \
       set label \"\\\parbox{2cm}{Sowing \\\& transplanting}\" at 9,graph 0.5; \
       set style rect fc lt -1 fs transparent solid 0.25 noborder; \
       set obj rect from 1, graph 0 to 4, graph 1; \
       set label \"\\\parbox{2cm}{Harvesting}\" at 1.5,graph 0 rotate by 90 left; \
       set key c t width 8; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "set style fill transparent solid .5; \
      plot \
      'rangpur.csv' u 1:3 ti 'Rangpur', \
      'dhaka.csv' u 1:3 ti 'Dhaka', \
      'chittagong.csv' u 1:3 ti 'Chittagong', \
      'khulna.csv' u 1:3 ti 'Khulna', \
      'rajshahi.csv' u 1:3 ti 'Rajshahi'"

mv prod_potato_BGD.tex ../results/
mv prod_potato_BGD.gp ../results/
mv prod_potato_BGD.pdf ../results/

eggplant_BGD Rangpur
eggplant_BGD Dhaka
eggplant_BGD Chittagong
eggplant_BGD Khulna
eggplant_BGD Rajshahi

../scripts/plot.sh -o prod_eggplant_BGD \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key c t width 13; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "plot \
      'rangpur.csv' u 1:3 ls 1 pt 5 ti 'Rangpur model', \
      'Rangpur_eggplant.csv' u 1:2 ls 1 pt 4 ti 'Rangpur reference', \
      'dhaka.csv' u 1:3 ls 2 pt 9 ti 'Dhaka model', \
      'Dhaka_eggplant.csv' u 1:2 ls 2 pt 8 ti 'Dhaka reference', \
      'chittagong.csv' u 1:3 ls 3 pt 11 ti 'Chittagong model', \
      'Chittagong_eggplant.csv' u 1:2 ls 3 pt 10 ti 'Chittagong reference', \
      'khulna.csv' u 1:3 ls 4 pt 13 ti 'Khulna model', \
      'Khulna_eggplant.csv' u 1:2 ls 4 pt 12 ti 'Khulna reference', \
      'rajshahi.csv' u 1:3 ls 5 pt 3 ti 'Rajshahi model', \
      'Rajshahi_eggplant.csv' u 1:2 ls 5 pt 2 ti 'Rajshahi reference'"

mv prod_eggplant_BGD.tex ../results/
mv prod_eggplant_BGD.gp ../results/
mv prod_eggplant_BGD.pdf ../results/
}

function tom_PHL() { #IGNORE
region="$1"
outFile=$2
sqlite3 $DB <<! > .temp.tom_PHL
.mode csv
SELECT (tom1/(tom1+tom2+tom3+tom4+.0)/3.0),
(tom2/(tom1+tom2+tom3+tom4+.0)/3.0),
(tom3/(tom1+tom2+tom3+tom4+.0)/3.0),
(tom4/(tom1+tom2+tom3+tom4+.0)/3.0) 
FROM production_PHL
WHERE
region='$region'
!

awk -F, '{for(m=1;m<=3;m++) printf "%g,%g\n",m+.5,$1; \
    for(m=4;m<=6;m++) printf "%g,%g\n",m+.5,$2; \
    for(m=7;m<=9;m++) printf "%g,%g\n",m+.5,$3; \
    for(m=10;m<=12;m++) printf "%g,%g\n",m+.5,$4}' .temp.tom_PHL > $outFile
}

function precip_PHL() {
grep "$1" ../obj/8.1_combined_elevation_precip_temperature_prodrate_PH_for_reg.csv | \
    awk -F, '{printf "%g,",exp(-.208-.008*$4)}' | \
    awk -F, '{for(i=1;i<=4;i++) sum+=$i; \
        for(m=1;m<=3;m++) printf "%g,%g\n",m+.5,$2/sum/3.0; \
        for(m=4;m<=6;m++) printf "%g,%g\n",m+.5,$1/sum/3.0; \
        for(m=7;m<=9;m++) printf "%g,%g\n",m+.5,$3/sum/3.0; \
        for(m=10;m<=12;m++) printf "%g,%g\n",m+.5,$4/sum/3.0}' > $2
}

function relative_prod_PHL() {
# north
#relative_prod "^617523" > ilocos.csv
#relative_prod "^617528" > cagayan.csv
#relative_prod "^600245" > calabarzon.csv
#relative_prod "^607443" > cl.csv
precip_PHL "CAR" car.csv
tom_PHL "CAR" car_ref.csv
precip_PHL "Ilocos" ilocos.csv
tom_PHL "Ilocos" ilocos_ref.csv
precip_PHL "Cagayan Valley" cagayan.csv
tom_PHL "Cagayan Valley" cagayan_ref.csv
precip_PHL "CALABARZON" calabarzon.csv
tom_PHL "CALABARZON" calabarzon_ref.csv
precip_PHL "Central Luzon" cl.csv
tom_PHL "Central Luzon" cl_ref.csv

../scripts/plot.sh -o prod_tomato_PHL_north \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key r t width 13; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "plot \
      'car.csv' u 1:2 ls 1 pt 5 ti 'CAR model', \
      'car_ref.csv' u 1:2 ls 1 pt 4 ti 'CAR reference', \
      'ilocos.csv' u 1:2 ls 2 pt 7 ti 'Ilocos model', \
      'ilocos_ref.csv' u 1:2 ls 2 pt 6 ti 'Ilocos reference', \
      'calabarzon.csv' u 1:2 ls 4 pt 13 ti 'Calabarzon model', \
      'calabarzon_ref.csv' u 1:2 ls 4 pt 12 ti 'Calabarzon reference', \
      'cl.csv' u 1:2 ls 5 pt 3 ti 'Cent. Luz. model', \
      'cl_ref.csv' u 1:2 ls 5 pt 2 ti 'Cent. Luz. reference'"

mv prod_tomato_PHL_north.tex ../results/
mv prod_tomato_PHL_north.gp ../results/
mv prod_tomato_PHL_north.pdf ../results/

# central
precip_PHL "Bicol Region" br.csv
tom_PHL "Bicol Region" br_ref.csv
precip_PHL "Western Visaya" wv.csv
tom_PHL "Western Visaya" wv_ref.csv
precip_PHL "Central Visayas" cv.csv
tom_PHL "Central Visayas" cv_ref.csv
precip_PHL "Northern Mindanao" nm.csv
tom_PHL "Northern Mindanao" nm_ref.csv
precip_PHL "Davao Region" davao.csv
tom_PHL "Davao Region" davao_ref.csv
precip_PHL "SOCCSKSARGEN" soc.csv
tom_PHL "SOCCSKSARGEN" soc_ref.csv

../scripts/plot.sh -o prod_tomato_PHL_central \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key r t width 13; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "plot \
      'soc.csv' u 1:2 ls 1 pt 5 ti 'Soccks. model', \
      'soc_ref.csv' u 1:2 ls 1 pt 4 ti 'Soccks. reference', \
      'wv.csv' u 1:2 ls 2 pt 7 ti 'West. Vis. model', \
      'wv_ref.csv' u 1:2 ls 2 pt 6 ti 'West. Vis. reference', \
      'br.csv' u 1:2 ls 3 pt 11 ti 'Bicol reg. model', \
      'br_ref.csv' u 1:2 ls 3 pt 10 ti 'Bicol reg. reference'"

mv prod_tomato_PHL_central.tex ../results/
mv prod_tomato_PHL_central.gp ../results/
mv prod_tomato_PHL_central.pdf ../results/

# exceptions
## relative_prod "^595934" > br.csv
## tom_PHL "Bicol Region" br_ref.csv
precip_PHL "Northern Mindanao" nm.csv
tom_PHL "Northern Mindanao" nm_ref.csv
precip_PHL "Davao Region" davao.csv
tom_PHL "Davao Region" davao_ref.csv

../scripts/plot.sh -o prod_tomato_PHL_exceptions \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key r t width 13; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "plot \
      'cagayan.csv' u 1:2 ls 1 pt 5 ti 'Cagayan model', \
      'cagayan_ref.csv' u 1:2 ls 1 pt 4 ti 'Cagayan reference', \
      'nm.csv' u 1:2 ls 4 pt 13 ti 'Nor. Mind. model', \
      'nm_ref.csv' u 1:2 ls 4 pt 12 ti 'Nor. Mind. reference', \
      'davao.csv' u 1:2 ls 5 pt 3 ti 'Davao model', \
      'davao_ref.csv' u 1:2 ls 5 pt 2 ti 'Davao reference', \
      'cv.csv' u 1:2 ls 3 pt 11 ti 'Cent. Vis. model', \
      'cv_ref.csv' u 1:2 ls 3 pt 10 ti 'Cent. Vis. reference'"

mv prod_tomato_PHL_exceptions.tex ../results/
mv prod_tomato_PHL_exceptions.gp ../results/
mv prod_tomato_PHL_exceptions.pdf ../results/
}


function relative_prod_IDN() {
relative_prod "^476351" > pangalengan.csv

../scripts/plot.sh -o prod_tomato_IDN \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key l t width 8; \
       set style rect fc lt -1 fs transparent solid 0.15 noborder; \
       set obj rect from 5, graph 0 to 10, graph 1; \
       set label \"\\\parbox{2cm}{Growing}\" at 7.5,graph 0 rotate by 90 left; \
       set style rect fc lt -1 fs transparent solid 0.25 noborder; \
       set obj rect from 10, graph 0 to 12, graph 1; \
       set label \"\\\parbox{2cm}{Harvesting}\" at 10.5,graph 0 rotate by 90 left; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "set style fill transparent solid .5; \
      plot \
      'pangalengan.csv' u 1:3 ti 'Pangalengan'" \

mv prod_tomato_IDN.tex ../results/
mv prod_tomato_IDN.gp ../results/
mv prod_tomato_IDN.pdf ../results/
## relative_prod "^640504" > hanoi.csv
}

function relative_prod_KHM() {
relative_prod "^584341" > kandal.csv
sqlite3 $DB <<! > kandal_genova.csv
.mode csv
SELECT * FROM kandal_genova_2006
!
awk -F, '{sum+=$3;p[$1]=$3}END{for(i=1;i<=12;i++) printf "%g,%g\n",i+.5,p[i]/sum}' kandal_genova.csv > ref.csv

../scripts/plot.sh -o prod_tomato_KHM \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key r t width 8; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "set style fill transparent solid .5; \
      plot \
      'kandal.csv' u 1:3 ti 'Kandal', \
      'ref.csv' u 1:2 ti 'reference'"

mv prod_tomato_KHM.tex ../results/
mv prod_tomato_KHM.gp ../results/
mv prod_tomato_KHM.pdf ../results/
}

function relative_prod_LAO() {
relative_prod "^627529" > vientiane.csv

../scripts/plot.sh -o prod_tomato_LAO \
   -c mathematica \
   -y "Relative production" \
   -f "all:15" \
   -a "unset title; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key r t width 8; \
       set style rect fc lt -1 fs transparent solid 0.15 noborder; \
       set obj rect from 11, graph 0 to 13, graph 1; \
       set obj rect from 1, graph 0 to 5, graph 1; \
       set label \"\\\parbox{4cm}{Tomato season}\" at 12,graph 0 rotate by 90 left; \
       set xrange [1:13]; \
       set xtics (\"Jan\" 1,\"Feb\" 2,\"Mar\" 3,\"Apr\" 4,\"May\" 5,\
       \"Jun\" 6,\"Jul\" 7,\"Aug\" 8,\"Sep\" 9,\"Oct\" 10,\"Nov\" 11,\"Dec\" 12) offset 0.5,0;" \
   -p "set style fill transparent solid .5; \
      plot \
      'vientiane.csv' u 1:3 ti 'Vientiane'" \

mv prod_tomato_LAO.tex ../results/
mv prod_tomato_LAO.gp ../results/
mv prod_tomato_LAO.pdf ../results/
}

function all() {
relative_prod_BGD
relative_prod_IDN
relative_prod_KHM
relative_prod_LAO
relative_prod_PHL
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
