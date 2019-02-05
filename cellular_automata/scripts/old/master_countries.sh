#!/bin/bash
# sbatch for discovery is run_ca_countries
function run_local() {
#countryList="BD KH LA ID TH SG MY MM PH VN"
countryList="VN"
# radius=100
beta=2
kappa=300
gridFile="../obj/ca_precip1_b${beta}_k${kappa}.pkl"
timeSteps=16
simRuns=2
startMonth=5
moore=2
suitThresh=0
expDelay=1
alphaSD=200
alphaFM=100
alphaMM=300

for country in $countryList
do
    append="_radial.csv"
    seedFile="../data/seed_files/seed_$country$append"
    outFile="sim_out_$country.csv"
    echo "python ../scripts/run_ca.py\
    --grid_file $gridFile \
    --seed_file $seedFile \
    -o $outFile \
    -n $timeSteps \
    --sim_runs $simRuns \
    -s $startMonth \
    -m $moore \
    --suitability_threshold $suitThresh \
    --exp_delay $expDelay \
    --alpha_sd $alphaSD \
    --alpha_fm $alphaFM \
    --alpha_mm $alphaMM \
    --countries $country"

    eval "python ../scripts/run_ca.py\
    --grid_file $gridFile \
    --seed_file $seedFile \
    -o $outFile \
    -n $timeSteps \
    --sim_runs $simRuns \
    -s $startMonth \
    -m $moore \
    --suitability_threshold $suitThresh \
    --exp_delay $expDelay \
    --alpha_sd $alphaSD \
    --alpha_fm $alphaFM \
    --alpha_mm $alphaMM \
    --countries $country"

    

done
}

function run_all_local() {
countryList="BD KH LA ID TH SG MY MM PH VN"
# radius=100
beta=2
kappa=300
gridFile="../obj/ca_precip1_b${beta}_k${kappa}.pkl"
timeSteps=16
simRuns=10
startMonth=5
moore=2
suitThresh=0
expDelay=1
alphaSD=200
alphaFM=100
alphaMM=300

for country in $countryList
do
    append="_radial.csv"
    seedFile="../data/seed_files/seed_$country$append"
    outFile="../results/results$country.csv"
    echo "python ../scripts/run_ca.py\
    --grid_file $gridFile \
    --seed_file $seedFile \
    -o $outFile \
    -n $timeSteps \
    --sim_runs $simRuns \
    -s $startMonth \
    -m $moore \
    --suitability_threshold $suitThresh \
    --exp_delay $expDelay \
    --alpha_sd $alphaSD \
    --alpha_fm $alphaFM \
    --alpha_mm $alphaMM \
    --countries $country"

    eval "python ../scripts/run_ca.py\
    --grid_file $gridFile \
    --seed_file $seedFile \
    -o $outFile \
    -n $timeSteps \
    --sim_runs $simRuns \
    -s $startMonth \
    -m $moore \
    --suitability_threshold $suitThresh \
    --exp_delay $expDelay \
    --alpha_sd $alphaSD \
    --alpha_fm $alphaFM \
    --alpha_mm $alphaMM \
    --countries $country"

    echo "python ../scripts/plot_ca_timeline.py\
    $outFile \
    --countries $country \
    -o plot$country"

    eval "python ../scripts/plot_ca_timeline.py\
    $outFile \
    --countries $country \
    -o plot$country"

done
}


## Plot
function plot_countries() {
countryList="BD KH LA ID TH SG MY MM PH VN"
for country in $countryList
do
    echo "python ../scripts/plot_ca_timeline.py\
    $outFile \
    --countries $country \
    -o plot$country"

    eval "python ../scripts/plot_ca_timeline.py\
    $outFile \
    --countries $country \
    -o plot$country"
done
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else
   eval $1 $2
fi

