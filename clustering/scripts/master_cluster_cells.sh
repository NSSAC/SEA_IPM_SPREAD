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

function process_sim(){
count=1
for f in `ls -1 results_BGD_6`
do
echo -ne "\r\033[K$count: $f"
outPrefix=rank_time_inf_BD/`echo $f | sed -e "s/.csv$//"`
python ../scripts/post_process_simfile.py \
    results_BGD_6/$f \
    -o $outPrefix -c BD
((count+=1))
done
}

function concat_ranks(){
rm -f cell_ranks_BD.csv
for f in `ls -1 rank_BD`
do
cat rank_BD/$f >> cell_ranks_BD.csv
done
}

function concat_inf(){
colNum=`seq 1 3376 | awk '{printf(",%d",$1)}END{print "\n"}'`
echo "season,beta,kappa,seed,start_month,moore,start_time,latency_period,a_sd,a_local,a_long$colNum" > infection_vector_BD.csv
for f in `find rank_time_inf_BD -iname *infvec.csv`
do
cat $f >> infection_vector_BD.csv
done
}

function concat_time(){
rm -f expected_time_BD.csv
for f in `ls -1 rank_time_BD/*time.csv`
do
tail -1 rank_time_BD/$f >> expected_time_BD.csv
done
}

function cluster(){
Rscript ../scripts/cluster_ranked_cells.R \
    -i ../obj/cell_ranks_BD.csv
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
