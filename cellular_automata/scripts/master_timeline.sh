#!/bin/bash
DB='../../timeline/data/timeline.db';

function interception(){
sqlite3 $DB <<!
.mode csv
SELECT b.country,b.quality,d.continent FROM border_control_quality AS b
INNER JOIN CountryAttributes AS c ON b.country=c.Alpha3 
INNER JOIN country_continent AS d ON d.Alpha2=c.Alpha2 
WHERE d.continent='AF'
ORDER BY b.quality desc;
!
}

function timeline(){
sqlite3 $DB <<!
.mode csv
SELECT t.Country,t.State,adc.adc_id,t.Year,t.Month FROM timeline AS t
INNER JOIN admin1_adc_id as adc ON t.Country=adc.country AND t.State=adc.name
WHERE t.Country='Nigeria'
OR t.Country='Benin'
OR t.Country='Togo'
OR t.Country='Kenya'
OR t.Country='Botswana'
OR t.Country='South Africa'
OR t.Country='Ethiopia'
ORDER BY t.Year,t.Month
!

cat << EOF
Egypt,Al Qahirah,140001535,-1,-1
Egypt,Aswan,140001547,-1,-1
Egypt,Al Bahr Al Ahmar,140001515,-1,-1
Morocco,Oued Eddahab-Lagouira,140001657,-1,-1
Oman,Zufar,140002572,-1,-1
EOF
}

function old_timeline(){
sqlite3 $DB <<!
.mode csv
SELECT t.Country,t.State,adc.adc_id,t.Year,t.Month FROM timeline AS t
INNER JOIN country_codes AS c ON t.Country=c.Name 
INNER JOIN admin1_adc_id as adc ON t.Country=adc.country AND t.State=adc.name
WHERE c.Alpha3 IN
(SELECT b.country FROM border_control_quality AS b
INNER JOIN country_codes AS c ON b.country=c.Alpha3 
INNER JOIN country_continent AS d ON d.Alpha2=c.Alpha2 
WHERE d.continent='AF')
OR t.Country='Nigeria'
OR t.Country='South Africa'
ORDER BY t.Year,t.Month
!
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1
fi

