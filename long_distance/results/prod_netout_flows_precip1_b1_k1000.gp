##### terminal
set term tikz standalone size 12.5cm,8.75cm font ",14" gparrows scale 2,2 textscale 2
set datafile separator ','

##### output
set output 'prod_netout_flows_precip1_b1_k1000.tex'

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
set style data lines

# NOTE: offsets should be a function of font sizes
##### key
set key t l Left spacing 2 width 5 opaque font ",18"

##### tics (note that tics are also set in theme)
set xtics font ",18" offset 0,.2
set ytics font ",18" offset 1.5,0

##### plot
set title font ",18" "" offset -3,.3
set xlabel "Localities ordered by outflow" offset 0,0 font ",18"
set ylabel "Amount in KTonnes" offset -2,0 font ",18"


set notitle;        set key t r width 7;        set ytics offset 2,0;        set xtics offset 0,-.5;        set xlabel offset 0,.4;        set ylabel offset -.2,0;        set format y "%.s";        set xtics font ",15";

plot "props_flows_precip1_b1_k1000.csv" u 3 w boxes fs solid .5 ls 7 t "Production","props_flows_precip1_b1_k1000.csv" u 2 ls 4 lw 10 t "Net outflow";

