#!/bin/bash
DB="../../data_and_obj.db"

function import_for_country(){
country=$1
sqlite3 $DB <<! #> export_processed.csv
.separator ","
SELECT "$country",sum(Value) FROM FAOSTAT_solanaceae_trade_matrix WHERE
ReporterCountries='$country' AND
Item='Tomatoes' AND
Year=2013 AND
Element='Import Quantity';
SELECT "$country",sum(Value) FROM FAOSTAT_solanaceae_trade_matrix WHERE
PartnerCountries='$country' AND
Item='Tomatoes' AND
Year=2013 AND
Element='Export Quantity';
SELECT ReporterCountries,Value FROM FAOSTAT_solanaceae_trade_matrix WHERE
PartnerCountries='$country' AND
Item='Tomatoes' AND
Year=2013 AND
Element='Export Quantity';
!
}

function export_for_country(){
country=$1
sqlite3 $DB <<! #> export_processed.csv
.separator ","
SELECT "$country",sum(Value) FROM FAOSTAT_solanaceae_trade_matrix WHERE
ReporterCountries='$country' AND
Item='Tomatoes' AND
Year=2013 AND
Element='Export Quantity';
SELECT "$country",sum(Value) FROM FAOSTAT_solanaceae_trade_matrix WHERE
PartnerCountries='$country' AND
Item='Tomatoes' AND
Year=2013 AND
Element='Import Quantity';
SELECT ReporterCountries,Value FROM FAOSTAT_solanaceae_trade_matrix WHERE
PartnerCountries='$country' AND
Item='Tomatoes' AND
Year=2013 AND
Element='Import Quantity';
!
}

function exp_proc_tom(){
country=$(
cat << EOF
Bangladesh
Cambodia
Indonesia
Laos
Malaysia
Myanmar
Philippines
Singapore
Thailand
Vietnam
EOF
)
for c in $country
do
export_processed_tomato $c
done
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
