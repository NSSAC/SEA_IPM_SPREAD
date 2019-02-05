#!/bin/bash
# This file generates database entries for timeline at the state level for the specified country (iso code)
isoCode=$1;
country=$2;
year=$3;
month=$4;

echo "insert into timeline (Year,Month,Country,State,state_adc_id) values";
grep "${isoCode}-" ../data/admin1_adc_id.csv | \
   sed -e "s/^/($year,$month,'$country','/" \
   -e "s/${isoCode}-[^,]*,//" \
   -e "s/,14/',14/" \
   -e 's/,Province.*/),/'
