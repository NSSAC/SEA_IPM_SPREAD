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
algo=$1
echo "#!/bin/bash" > run
for k in `seq 2 10`
do
clustersFile=cluster_${algo}_$k.csv
logFile=cluster_${algo}_$k.log
cat << EOF >> run
sbatch -o $logFile \
--export=command="python ../scripts/cluster_instances.py -a $algo -k $k -o $clustersFile" \
../scripts/run_proc.sbatch
EOF
chmod +x run
done
}

function formatVar(){
awk 'NR>1' $1 | sed  -e 's/"//g' \
    -e 's/a_long/\\$\\\\alpha_{\\\\ell d}\\$/' \
    -e 's/latency_period/\\$\\\\ell\\$/' \
    -e 's/moore/\\$r_\\\\textrm{M}\\$/' \
    -e 's/start_month/\\$t_s\\$/' \
    -e 's/a_local/\\$\\\\alpha_{\\\\ell}\\$/' \
    -e 's/a_sd/\\$\\\\alpha_{s}\\$/' \
    -e 's/beta/\\$\\\\beta\\$/' \
    -e 's/kappa/\\$\\\\kappa\\$/' \
    > $2
}

function plotRF(){
../../cellular_automata/scripts/plot.sh -o $2 \
   -c mathematica \
   -T hist \
   -x "\\\%IncMSE (\\$\\\times 10^3\\$)" \
   -f "all:18" \
   -a "unset title; \
       set ytics textcolor 'black' offset .5,0; \
       set xtics font \",15\"; \
       set style data points; \
       set format x \"%.1s\"; \
       set nokey;" \
       -p "plot '< gsort -t, -k2,2 -n -r $1' u 2:(-\$0):yticlabel(1) ls $3 pt 7"
}

function cart_and_rf(){
for f in `ls -1 cluster_*csv`
do
echo $f
cartFile=`echo $f | sed -e 's/cluster/cart/' -e 's/csv/pdf/'`
Rscript ../scripts/cart_cluster.R -f $f -o $cartFile
rfFile=`echo $f | sed -e 's/cluster/rf/' -e 's/.csv/_original.csv/'`
rfFileFormatted=`echo $rfFile | sed -e 's/_original//'`
Rscript ../scripts/random_forest_cluster.R -f $f -o $rfFile
formatVar $rfFile $rfFileFormatted
plotFile=`echo $rfFile | sed -e 's/csv$/pdf/'`
done
}

function rf_plot(){
plotRF $rfFileFormatted $plotFile 1
}

function rf(){
# Partitioning to A and B models
head -n1 ../results/clusters_all.csv > clusters_all_A.csv
cp clusters_all_A.csv clusters_all_B.csv
awk -F, 'NR>1{if ($11==0) print}' ../results/clusters_all.csv >> clusters_all_A.csv
awk -F, 'NR>1{if ($11>0) print}' ../results/clusters_all.csv >> clusters_all_B.csv
# RF
Rscript ../scripts/random_forest_cluster.R -f ../results/clusters_all.csv -o rf_importance_cluster_all_original.csv
Rscript ../scripts/random_forest_cluster.R -f clusters_all_A.csv -o rf_importance_cluster_all_A_original.csv
Rscript ../scripts/random_forest_cluster.R -f clusters_all_B.csv -o rf_importance_cluster_all_B_original.csv
# Format variable names
formatVar rf_importance_cluster_all_original.csv rf_importance_cluster_all.csv
formatVar rf_importance_cluster_all_A_original.csv rf_importance_cluster_all_A.csv
formatVar rf_importance_cluster_all_B_original.csv rf_importance_cluster_all_B.csv
# Plot
plotRF rf_importance_cluster_all.csv rf_importance_cluster_mse_all 1
plotRF rf_importance_cluster_all_A.csv rf_importance_cluster_mse_A 2
plotRF rf_importance_cluster_all_B.csv rf_importance_cluster_mse_B 3
}

## # old attempt with R
## function cluster(){
## Rscript ../scripts/cluster_ranked_cells.R \
##     -i ../obj/cell_ranks_BD.csv
## }

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
