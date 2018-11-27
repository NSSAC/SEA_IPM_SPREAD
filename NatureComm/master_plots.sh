#!/bin/bash
function fao_network(){
cd ../international_trade/work/
../scripts/master_fao.sh plot_networks
../scripts/master_fao.sh update_results
}

function contour_bgd(){
cd ../cellular_automata/work/
../scripts/master_plot.sh contour_bgd
}

function contour_msa(){
cd ../cellular_automata/work/
../scripts/master_plot.sh contour_msa
}

function spread_rate(){
cd ../cellular_automata/work/
../scripts/master_plot.sh dist_inf_moore
}

#-----------------------------------------
# Supplementary
#-----------------------------------------
function prod(){
cd ../production/work/
../scripts/master_plot.sh all
}

function cart(){
cd ../cellular_automata/work
../scripts/master_analysis.sh cartml
}

function trends(){
cd ../international_trade/work/
../scripts/master_fao.sh plot_trends
}


function trade_flows(){
cd ../long_distance/work/
rm *pdf
../scripts/master_plot.sh trade_flows
mv *pdf ../results/
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
