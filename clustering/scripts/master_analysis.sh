#!/bin/bash
###########################################################################
# Analysis of clusters
###########################################################################
DB="../../cellular_automata/results/results.db"

function formatVar(){ #IGNORE
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

function plotRF(){ #IGNORE
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

function cartAndRF(){ # CART and RF analysis of clusters
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

for f in `ls -1 ../results/rf_*means_*csv`
do
echo $f 
plotFile=`basename $f | sed -e 's/\.csv$//'`
plotRF $f $plotFile 1
done
}

function createParFile(){ #IGNORE
grep "$1" par_all.csv | awk -F, 'NR==1{print $2}' > $2.csv
grep "$1" par_all.csv >> $2.csv
}

function rfClusterSize(){
algo=$1
# make files per variable with normalized 4th column
rm -f par_*.csv
for k in `seq 2 10`
do
inFile=../results/rf_${algo}_$k.csv
awk -F, -v OFS=, 'FNR==NR{max=($3>max)?$3:max;next}{print $1,$2,$3/max}' $inFile $inFile > .temp_rf_clustersize
sed -e "s/^/$k,/" .temp_rf_clustersize >> par_all.csv
done

createParFile "alpha.*ell d" par_ald
createParFile "ell..," par_l
createParFile "season" par_season
createParFile "r_" par_moore
createParFile "seed" par_seed
createParFile "beta" par_beta
createParFile "kappa" par_kappa
createParFile "t_s" par_start
createParFile "alpha.*ell...," par_local
createParFile "alpha..s" par_short

# plot
../../cellular_automata/scripts/plot.sh -o rf_k_$algo \
   -c mathematica \
   -m lines \
   -x "\\\%Normalized mean decrease accuracy" \
   -f "all:18" \
   -a "unset title; \
       set key out Right spacing 2.3 t r; \
       set ytics textcolor 'black' offset .5,0; \
       set xtics font \",15\";" \
   -p "plot 'par_ald.csv' u 1:4 ls 1 t columnheader(1), \
            'par_l.csv' u 1:4 ls 2 t columnheader(1), \
            'par_moore.csv' u 1:4 ls 3 t columnheader(1), \
            'par_start.csv' u 1:4 ls 4 t columnheader(1), \
            'par_season.csv' u 1:4 ls 1 dt 7 t columnheader(1), \
            'par_local.csv' u 1:4 ls 2 dt 7 t columnheader(1), \
            'par_seed.csv' u 1:4 ls 3 dt 7 t columnheader(1), \
            'par_short.csv' u 1:4 ls 4 dt 7 t columnheader(1), \
            'par_beta.csv' u 1:4 ls 5 dt 7 t columnheader(1), \
            'par_kappa.csv' u 1:4 ls 6 dt 7 t columnheader(1) \
            "
}

# < head -n1 par_ald.csv | awk -F, \'{print $2}\'

###########################################################################
# old
###########################################################################
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

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
