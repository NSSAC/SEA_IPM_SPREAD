#!/bin/bash
function bgd(){
#new
#python ../scripts/plot_contour.py ../sim_out_files/results_BD/res_precip1_b0_k1000_s0_sm5_m1_st0_ed3_a-400-0-50.csv BD -t .8 -n 12 -o ./BGD_model-B_m1_l3.pdf
#old
python ../scripts/plot_contour.py ../sim_out_files/results_BD/res_precip1_b0_k500_s0_sm5_m1_st0_ed3_a-125-0-50.csv BD -t .9 -n 12 -o tp.pdf
#python ../scripts/plot_contour.py ../results/results_BD/res_precip1_b0_k1000_s0_sm5_m1_st0_ed3_a-400-0-50.csv BD -t .8 -n 12 -o ../results/contour/BGD_model-B_m1_l3.pdf
## python ../scripts/plot_contour.py ../results/results_BD/res_precip1_b0_k500_s0_sm5_m1_st0_ed3_a-300-0-50.csv BD -t .8 -n 12 -o ../results/contour/BGD_model-B_m1_l3.pdf
#python ../scripts/plot_contour.py ../results/sim_out/BGD/res_precip1_b0_k1000_s0_sm4_m3_st0_ed2_a-400-400-0.csv BD -t .8 -n 12 -o ../results/contour/BGD_model-A.pdf
#python ../scripts/plot_contour.py ../results/sim_out/BGD/res_precip1_b0_k500_s0_sm5_m1_st0_ed3_a-300-0-50.csv BD -t 1 -n 12 -o ../results/contour/model_B_BGD_1.pdf
}

function bgd_movie(){
#for timeSteps in `seq 1 12`
#do
#echo $timeSteps
python ../scripts/spread_movie.py \
    ../sim_out_files/results_BD/res_precip1_b0_k500_s0_sm5_m1_st0_ed3_a-125-0-50.csv BD \
    -s 5 \
    -t 1 \
    -n 24 \
    -p modelB_BGD

python ../scripts/spread_movie.py \
    ../sim_out_files/results_BD/res_precip1_b0_k1000_s0_sm4_m3_st0_ed2_a-400-400-0.csv BD \
    -t 0.95 \
    -n 24 \
    -p modelA_BGD

}

function msa(){
## #B m1 l1
## #B m1 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30_g6/res_precip1_b1_k1000_s4_sm5_m1_st0_ed2_a-150-0-25.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m1_l2.pdf
## #B m1 l3
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30_g6/res_precip1_b0_k500_s4_sm5_m1_st0_ed3_a-400-0-100.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m1_l3.pdf
## #B m2 l1
## #B m2 l2
## #B m2 l3
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b1_k1000_s4_sm5_m2_st0_ed3_a-100-100-200.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m2_l3.pdf
## #B m3 l1
## #B m3 l2
## #B m3 l3
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b1_k1000_s4_sm5_m3_st0_ed3_a-50-50-150.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m3_l3.pdf
########
#A m1 l1
python ../scripts/plot_contour.py ../results/results_sea_s4_0p_rep30/res_precip1_b0_k500_s4_sm5_m1_st0_ed1_a-200-400-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m1_l1.pdf
#A m1 l2
#A m1 l3
#A m2 l1
python ../scripts/plot_contour.py ../results/results_sea_s4_0p_rep30/res_precip1_b0_k500_s4_sm5_m2_st0_ed1_a-200-0-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m2_l1.pdf
#A m2 l2
python ../scripts/plot_contour.py ../results/results_sea_s4_0p_rep30/res_precip1_b0_k500_s4_sm4_m2_st0_ed2_a-100-50-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m2_l2.pdf
#A m2 l3
#A m3 l1
#A m3 l2
python ../scripts/plot_contour.py ../results/results_sea_s4_0p_rep30/res_precip1_b0_k500_s4_sm4_m3_st0_ed2_a-50-50-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m3_l3.pdf
#A m3 l3
#### intervention
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1-20-100_b1_k1000_s4_sm5_m3_st0_ed3_a-50-0-150.csv MSA -t .5 -n 120 -o ../results/contour/int_MSA_model-B_m3_l3.pdf
}

function msa_g5.5(){
#B m1 l1
python ../scripts/plot_contour.py ../results/results_sea_s4_rep30_g6/res_precip1_b1_k1000_s4_sm5_m1_st0_ed1_a-25-0-25.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m1_l1.pdf
## #B m1 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b1_k1000_s4_sm5_m1_st0_ed2_a-150-0-25.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m1_l2.pdf
#B m1 l3
python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm5_m1_st0_ed3_a-300-0-50.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m1_l3.pdf
## #B m2 l1
## #B m2 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b1_k500_s4_sm5_m2_st0_ed2_a-25-0-10.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m2_l2.pdf
## #B m2 l3
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b1_k1000_s4_sm5_m2_st0_ed3_a-100-25-75.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m2_l3.pdf
## #B m3 l1
## #B m3 l2
## #B m3 l3
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b1_k1000_s4_sm5_m3_st0_ed3_a-50-0-150.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-B_m3_l3.pdf
## ########
## #A m1 l1
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm5_m1_st0_ed1_a-200-400-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m1_l1.pdf
## #A m1 l2
## #A m1 l3
## #A m2 l1
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm5_m2_st0_ed1_a-200-0-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m2_l1.pdf
## #A m2 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm4_m2_st0_ed2_a-100-50-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m2_l2.pdf
## #A m2 l3
## #A m3 l1
## #A m3 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm4_m3_st0_ed2_a-50-50-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m3_l3.pdf
#A m3 l3
#### intervention
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1-20-100_b1_k1000_s4_sm5_m3_st0_ed3_a-50-0-150.csv MSA -t .5 -n 120 -o ../results/contour/int_MSA_model-B_m3_l3.pdf
}

function msa_50p(){
## #B m1 l1
## #B m1 l2
python ../scripts/plot_contour.py ../results/results_sea_s4_rep5_50p_increase/res_precip1_b1_k1000_s4_sm5_m1_st0_ed2_a-225-0-37.5.csv MSA -t .5 -n 120 -o ../results/contour/MSA_50p_model-B_m1_l2.pdf
#B m1 l3
python ../scripts/plot_contour.py ../results/results_sea_s4_rep5_50p_increase/res_precip1_b0_k500_s4_sm5_m1_st0_ed3_a-600-0-150.csv MSA -t .5 -n 120 -o ../results/contour/MSA_50p_model-B_m1_l3.pdf
#B m2 l1
#B m2 l2
#B m2 l3
python ../scripts/plot_contour.py ../results/results_sea_s4_rep5_50p_increase/res_precip1_b1_k1000_s4_sm5_m2_st0_ed3_a-112.5-112.5-187.5.csv MSA -t .5 -n 120 -o ../results/contour/MSA_50p_model-B_m2_l3.pdf
#B m3 l1
#B m3 l2
#B m3 l3
python ../scripts/plot_contour.py ../results/results_sea_s4_rep5_50p_increase/res_precip1_b1_k1000_s4_sm5_m3_st0_ed3_a-75-0-225.csv MSA -t .5 -n 120 -o ../results/contour/MSA_50p_model-B_m3_l3.pdf
## ########
## #A m1 l1
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm5_m1_st0_ed1_a-200-400-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m1_l1.pdf
## #A m1 l2
## #A m1 l3
## #A m2 l1
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm5_m2_st0_ed1_a-200-0-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m2_l1.pdf
## #A m2 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm4_m2_st0_ed2_a-100-50-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m2_l2.pdf
## #A m2 l3
## #A m3 l1
## #A m3 l2
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1_b0_k500_s4_sm4_m3_st0_ed2_a-50-50-0.csv MSA -t .5 -n 120 -o ../results/contour/MSA_model-A_m3_l3.pdf
#A m3 l3
#### intervention
## python ../scripts/plot_contour.py ../results/results_sea_s4_rep30/res_precip1-20-100_b1_k1000_s4_sm5_m3_st0_ed3_a-50-0-150.csv MSA -t .5 -n 120 -o ../results/contour/int_MSA_model-B_m3_l3.pdf
}

function country(){ $IGNORE
country=$1
season=$2
seed=$3
time=$4
#B m1 l1
#B m1 l2
#B m1 l3
python ../scripts/plot_contour.py ../sim_out_files/results_${country}/res_${season}_b0_k500_s${seed}_sm5_m1_st0_ed3_a-400-0-100.csv ${country} -t .5 -n $time -o ../results/contour/${country}_model-B_${season}_m1_l3.pdf
#B m2 l1
#B m2 l2
#B m2 l3
## python ../scripts/plot_contour.py ../results/results_${country}/res_${season}_b1_k1000_s${seed}_sm5_m2_st0_ed3_a-100-100-200.csv ${country} -t .8 -n $time -o ../results/contour/${country}_model-B_${season}_m2_l3.pdf
## #B m3 l1
## #B m3 l2
## #B m3 l3
## python ../scripts/plot_contour.py ../results/results_${country}/res_${season}_b1_k1000_s${seed}_sm5_m3_st0_ed3_a-50-50-150.csv ${country} -t .8 -n $time -o ../results/contour/${country}_model-B_${season}_m3_l3.pdf
}

function countries(){
## country BD precip1 0 24
## country BD precip1-out-50 0 24
## country BD precip1-out-100 0 24
country VN precip1 104 24
country VN precip1-out-50 104 24
country VN precip1-out-100 104 24
## country TH precip1 101 48
## country TH precip1-out-50 101 48
## country TH precip1-out-100 101 48
## country PH precip1 103 48
## country PH precip1-out-50 103 48
## country PH precip1-out-100 103 48
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
