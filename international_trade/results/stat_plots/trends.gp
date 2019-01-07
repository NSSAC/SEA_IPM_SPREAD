##### terminal
clear
# set loadpath '~/Dropbox/proj/gp/src'
set term tikz standalone size 12.5cm,8.75cm font ",14" gparrows scale 2,2 textscale 2
set datafile separator ','

##### output
set output 'trends.tex'

##### bg: bg color, axes, grid, tics
##### http://www.colourlovers.com/palette/268142/Danger_Mouse
Danger='#F84934'; # red
Shoes='#4D5E5F'; # grey
##### Rand Olson
roBlue='#1F77B4';
roRed='#D62728';
# border
set style line 21 lt 1 lc rgb '#808080' 
set border 3 back ls 21 lw 5
# grid
set style line 22 lt 2 lc rgb '#CCCCCC' lw 2
set style line 23 lt 2 lc rgb '#DDDDDD' lw 1
set grid xtics mxtics ytics mytics back ls 22, ls 23
# tics
set tics textcolor rgb '#303030'
set tics nomirror out scale 1,.1
set mxtics 2
set mytics 2

##### load default linestyles
set style increment user
# taken care of in terminal
do for [i=1:15] { set style line i lt 1 lw 7 }

##### line colors
# mathematica default
DarkBlue= '#5e82b5'
Orange=   '#e09c24'
Green=    '#8fb030'
Red=      '#eb634f'
Purple=   '#8778b3'
Brown=    '#c46e1a'
LightBlue='#5c9ec7'
Yellow=   '#FDBF6F'
MATHEMATICA="#5e82b5 #e09c24 #8fb030 #eb634f #8778b3 #c46e1a #5c9ec7 #FDBF6F"
do for[i=1:8] {set style line i lc rgb word(MATHEMATICA,i)}
####

##### data style
set style data linespoints;
set style line 1 pt 5
set style line 2 pt 7
set style line 3 pt 13
set style line 4 pt 17
set style line 5 pt 4
set style line 6 pt 6
set style line 7 pt 12
set style line 8 pt 16
#
set pointintervalbox 4.5
do for [i=1:15] {set style line i ps 2.75 pi -1}

# NOTE: offsets should be a function of font sizes
##### key
set key t l Left spacing 4 width 5 opaque font ",15"

##### tics (note that tics are also set in theme)
set xtics font ",15" offset 0,.2
set ytics font ",15" offset 1.5,0

##### plot
set title font ",15" "" offset -3,.3
set xlabel "" offset 0,0 font ",15"
set ylabel "Normalized aggregate production and trade" offset -2,0 font ",15"


set notitle; unset xlabel; unset mxtics; unset mytics;        set xtic rotate by -30 offset -2,-.5 scale 0 autojustify;        set key width 8;        stats '../results/stats/prod.csv' using 2 name 'prod';        stats '../results/stats/trade.csv' using 2:3 name 'within';        stats '../results/stats/trade.csv' using 4:5 name 'imp';        stats '../results/stats/trade.csv' using 6:7 name 'exp';

set style fill transparent solid .5;       plot       '../results/stats/trade.csv' u 1:(($2+$3)/(within_max_x+within_max_y)/2.0) ti 'Internal trade' with linespoints ls 2,       '../results/stats/trade.csv' u 1:(($4+$5)/(imp_max_x+imp_max_y)/2.0) ti 'Imports' with linespoints ls 3,       '../results/stats/trade.csv' u 1:(($6+$7)/(exp_max_x+exp_max_y)/2.0) ti 'Exports' with linespoints ls 4,       '../results/stats/prod.csv' u 1:($2/prod_max) ti 'Production' with linespoints ls 1

set term x11 reset;
