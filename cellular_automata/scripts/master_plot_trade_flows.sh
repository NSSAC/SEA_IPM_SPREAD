#!/bin/bash
function inter_country_flow(){
cat ../../international_trade/results/significant_internal_flows.csv
}

function validation_malaysia(){
spamFile="../obj/ca_mapspam_pop.csv"
seasonalProd="../../production/obj/ca_seasonal_production.csv"
grep MY- $spamFile | awk -F, '{print $1}' > .malaysia_cells
rm -f .to_be_deleted_malaysia
for cell in `cat .malaysia_cells`
do
    grep $cell $seasonalProd | \
        awk -F, '{sum=0; for(i=3;i<15;i++) sum+=$i; if (sum) print $1","sum}' >> .to_be_deleted_malaysia
done
sort -t, -k2,2 -n -r .to_be_deleted_malaysia > malaysia_production.csv
echo "total: " `awk -F, '{sum+=$2}END{print sum}' malaysia_production.csv`
cameron=`grep -E "542564|542565|542566|542567|542568|542569|542570|542571|542572" malaysia_production.csv | awk -F, '{sum+=$2}END{print sum}'`
echo "Cameron:" $cameron
}

function validation_singapore(){
beta=2
kappa=300
timeNet="../../long_distance/obj/locality_flows_b${beta}_k${kappa}.csv"

# Singapore flows
grep ,Singapore $timeNet | grep -v ^Singapore | awk -F, '{sum+=$3}END{print sum}'
}

function validation_singapore(){
beta=2
kappa=300
timeNet="../../long_distance/obj/locality_flows_b${beta}_k${kappa}.csv"

# Singapore flows
grep ,Singapore $timeNet | grep -v ^Singapore | awk -F, '{sum+=$3}END{print sum}'
}

function filter_reports(){
reportingCells="669234|656282|659166|663489|663477|659158|651965|651957"
# reporting months ordered in ascending order of cell ids
cat << EOF >.reporting_months 
15
15
13
14
14
15
14
5
EOF
head -n1 $1 | sed -e 's/cell_id/cellid/' -e 's/,\([0-9]\)/,  \1  /g' -e 's/\([0-9]\)  *\([0-9]\)/\1\2 /g'
grep -E "$reportingCells" $1 | sort -t, -n > .t1
paste -d"|" .t1 .reporting_months
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
