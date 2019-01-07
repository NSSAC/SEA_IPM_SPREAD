#!/bin/bash
TRADE_MATRIX='../data/south_east_asia_trade_matrix.csv'

function create_networks(){  # creates network from trade matrix
for year in `echo 2011 2012 2013`
do
    echo $year
    python ../scripts/create_trade_network.py -p "Tomatoes" -y $year
    python ../scripts/convert_name_to_alpha.py out.csv > sea_${year}_tomato.csv
    ##
    python ../scripts/create_trade_network.py -p "Eggplants (aubergines)" -y $year
    python ../scripts/convert_name_to_alpha.py out.csv > sea_${year}_eggplant.csv
    ##
    python ../scripts/create_trade_network.py -p "Potatoes" -y $year
    python ../scripts/convert_name_to_alpha.py out.csv > sea_${year}_potato.csv
    ##
    python ../scripts/create_trade_network.py -p "Chillies and peppers, green" -y $year
    python ../scripts/convert_name_to_alpha.py out.csv > sea_${year}_pepper.csv
    ##
    python ../scripts/create_trade_network.py -p "Tobacco, unmanufactured" -y $year
    python ../scripts/convert_name_to_alpha.py out.csv > sea_${year}_tobacco.csv
done
}

function example_plot_network(){    # plots trade networks
python ../scripts/sea_netplot.py -h
python ../scripts/sea_netplot.py ../results/networks/sea_2011_tomato.csv
clean_latex
}

function plot_network(){    # IGNORE: plots trade network
inEdgeFile=$1
outPrefix=`basename $inEdgeFile | sed -e 's/.csv$//'`
awk -F, -v OFS=',' '{max=$4; if ($3>$4) max=$3; print $1,$2,max}' $inEdgeFile > out.csv
python ../scripts/sea_netplot.py out.csv -o $outPrefix 
}

function plot_networks(){    # plots trade networks
for year in `echo 2011 2012 2013`
do
    echo $year
    plot_network ../results/networks/sea_${year}_tomato.csv
    plot_network ../results/networks/sea_${year}_eggplant.csv
    plot_network ../results/networks/sea_${year}_potato.csv
    plot_network ../results/networks/sea_${year}_tobacco.csv
    plot_network ../results/networks/sea_${year}_pepper.csv
done
clean_latex
mv -v sea_20*csv ../results/networks/
mv -v sea_20*tex ../results/network_plots/
mv -v sea_20*pdf ../results/network_plots/
}

function prod(){  # Production yearly
for year in `seq 2004 2013`
do
    ## out=production_tomato_${year}.csv
    ## python ../scripts/create_production.py -p "Tomatoes" -y $year -o $out
    ## out=production_eggplant_${year}.csv
    ## python ../scripts/create_production.py -p "Eggplants (aubergines)" -y $year -o $out
    ## out=production_tobacco_${year}.csv
    ## python ../scripts/create_production.py -p "Tobacco, unmanufactured" -y $year -o $out
    out=production_potato_${year}.csv
    python ../scripts/create_production.py -p "Potatoes" -y $year -o $out
done
}

function trends(){  # trend of production, trade and imports
prodFile="prod.csv"
tradeFile="trade.csv"
rm -f $prodFile $tradeFile

for year in `seq 2004 2013`
do
    # production
    total=`awk -F, '{sum+=$2}END{print sum}' ../results/production/production_tomato_${year}.csv`
    echo "$year,$total" >> $prodFile
    # trade
    python ../scripts/trade_within_imports.py -y $year >> $tradeFile
done
}

function plot_trends(){
../scripts/plot.sh -o trends \
   -c mathematica \
   -y "Normalized aggregate production and trade" \
   -f "all:15" \
   -a "set notitle; unset xlabel; unset mxtics; unset mytics; \
       set xtic rotate by -30 offset -2,-.5 scale 0 autojustify; \
       set key width 8; \
       stats '../results/stats/prod.csv' using 2 name 'prod'; \
       stats '../results/stats/trade.csv' using 2:3 name 'within'; \
       stats '../results/stats/trade.csv' using 4:5 name 'imp'; \
       stats '../results/stats/trade.csv' using 6:7 name 'exp';" \
   -p "set style fill transparent solid .5; \
      plot \
      '../results/stats/trade.csv' u 1:((\$2+\$3)/(within_max_x+within_max_y)/2.0) ti 'Internal trade' with linespoints ls 2, \
      '../results/stats/trade.csv' u 1:((\$4+\$5)/(imp_max_x+imp_max_y)/2.0) ti 'Imports' with linespoints ls 3, \
      '../results/stats/trade.csv' u 1:((\$6+\$7)/(exp_max_x+exp_max_y)/2.0) ti 'Exports' with linespoints ls 4, \
      '../results/stats/prod.csv' u 1:(\$2/prod_max) ti 'Production' with linespoints ls 1"
mv -v trends.pdf ../results/stat_plots/
mv -v trends.tex ../results/stat_plots/
mv -v trends.gp ../results/stat_plots/
##       '../results/stats/trade.csv' u 1:(\$2/(within_max_x+within_max_y)):(\$3/(within_max_y+within_max_y)) noti with filledcu ls 2, \
##       '../results/stats/trade.csv' u 1:(\$4/(imp_max_x+imp_max_y)):(\$5/(imp_max_x+imp_max_y)) noti with filledcu ls 3, \
##       '../results/stats/trade.csv' u 1:(\$6/(exp_max_x+exp_max_y)):(\$7/(exp_max_y+exp_max_y)) noti with filledcu ls 4, \
}

function update_results(){    # plots trade network
mv -v production*_20*csv ../results/production/
mv -v prod.csv ../results/stats/
mv -v trade.csv ../results/stats/
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2 $3
fi
