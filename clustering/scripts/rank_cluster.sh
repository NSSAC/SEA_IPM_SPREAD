#!/bin/bash
###########################################################################
# Extracting cell order from simulation output
###########################################################################
DB="../../cellular_automata/results/results.db"

function query_to_filenames(){
rootDir=$1
queryResult=$2  #csv file
    
awk -F, -v OFS="_" -v prefix="$rootDir" '
NR>1{
if ($1==1) seasonInd="uniform";
if ($1==2) seasonInd="precip1";
printf "cp -n %s/res_%s_b%g_k%g_s%g_sm%g_m%g_st%g_ed%g_a-%g-%g-%g.csv results_BGD_6/\n",prefix,seasonInd,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
}' .to_be_deleted.exp.csv > .to_be_deleted.mov.sh
wc -l .to_be_deleted.mov.sh
bash .to_be_deleted.mov.sh
}

function extract_files(){
rm -f .to_be_deleted.exp.csv
sqlite3 ../../cellular_automata/results/results.db <<! >> .to_be_deleted.exp.csv
.mode csv
.header on
SELECT * FROM eval_BGD WHERE 
likelihood>=6 
!
# construct filename
#query_to_filenames ../../cellular_automata/sim_out_files/results_BGD_2018-08-01 .to_be_deleted.exp.csv
#query_to_filenames ../../cellular_automata/sim_out_files/results_BGD_2018-06-19 .to_be_deleted.exp.csv
query_to_filenames ../../cellular_automata/sim_out_files/results_BGD_2018-06-18 .to_be_deleted.exp.csv
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
