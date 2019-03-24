#!/bin/bash
###########################################################################
# OLD
###########################################################################
function cities_sea(){ #IGNORE
cities='../../cellular_automata/obj/cities/cities_250000.csv'
iso=$1
country=$2
grep $iso $cities | sed -e "s/,$iso.*/,$2/" -e 's/^[0-9]*,//' > ${iso}_country_cities.txt
}

function gen_city_list(){
    cities_sea VNM Vietnam
    cities_sea LAO Laos
    cities_sea BGD Bangladesh
    cities_sea THA Thailand
    cities_sea MYS Malaysia
    cities_sea KHM Cambodia
    cities_sea MMR Myanmar
    cities_sea PHL Philippines
    cities_sea BRN Brunei
    cities_sea IDN Indonesia
    # cat them all to cities_250000.txt
}

function dist_between_cities(){
python ../scripts/distance_matrix.py \
    ../obj/cities_250000.txt \
    -o ../results/time_distance_with_country_250000.csv \
    -m address_map.txt -v -u
}

function dist_within_country(){ # IGNORE
cities=../../data/cities.csv
iso=$1
country=$2
grep $iso $cities | sed -e "s/,$iso.*/,$2/" -e 's/^[0-9]*,//' > ${iso}_country_cities.txt
python ../scripts/distance_matrix.py \
    ../results/domestic_distances/${iso}_country_cities.txt \
    -o ../results/domestic_distances/${iso}_time_distance.csv \
    -m ../results/domestic_distances/${iso}_address_map.txt -v -u
sed -e "s/,${country}//g" -e 's/"//g' ../results/old/${iso}_time_distance.csv > ../results/old/${iso}_cities_time_distance.csv
}

function domestic_distances(){
    dist_within_country VNM vietnam # all passed
    dist_within_country LAO Laos # Champasak, Xaignabouli, Attapeu failed
    dist_within_country BGD Bangladesh # all passed
    dist_within_country THA Thailand # all passed
    dist_within_country MYS Malaysia # all passed
    dist_within_country KHM Cambodia # all passed: Kracheh changed to Krong Kracheh
    dist_within_country MMR Myanmar # all passed
    dist_within_country PHL Philippines # all passed
    dist_within_country BRN Brunei # all passed
    dist_within_country IDN Indonesia # all except Tidore, Nabire, Amahai, Telukbutun, Biak
}

function post_compute_time(){   # removing country names, quotes and anything else if required
sed -e "s/,[A-Z][a-zA-Z]*//g" -e 's/"//g' ../results/time_distance_with_country_250000.csv > time_distance_250000.csv
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1
fi

