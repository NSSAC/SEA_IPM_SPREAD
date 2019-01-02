#!/bin/bash
function gen_prod() {
python ../scripts/production.py -m precip2 -o seasonal_production_precip2.csv
python ../scripts/production.py -m precip_temp -o seasonal_production_precip_temp.csv
python ../scripts/production.py -m precip1 -o seasonal_production_precip1.csv
python ../scripts/production.py -m uniform -o seasonal_production_uniform.csv
mv seasonal_production* ../obj/
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
