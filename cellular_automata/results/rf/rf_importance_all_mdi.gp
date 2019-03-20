##### terminal
clear
# set loadpath '~/Dropbox/proj/gp/src'
set term tikz standalone size 12.5cm,8.75cm font ",14" gparrows scale 2,2 textscale 2
set datafile separator ','

##### output
set output 'rf_importance_all_mdi.tex'

##### bg: bg color, axes, grid, tics
##### http://www.colourlovers.com/palette/268142/Danger_Mouse
Danger='#F84934'; # red
Shoes='#4D5E5F'; # grey
##### Rand Olson
roBlue='#1F77B4';
roRed='#D62728';
# border
set style line 21 lt 1 lc rgb '#808080' 
set border 1 back ls 21 lw 5
# grid
set style line 22 lt 2 lc rgb '#CCCCCC' lw 2
set style line 23 lt 2 lc rgb '#DDDDDD' lw 1
set grid ytics back ls 22
# tics
set tics textcolor rgb '#666666'
set tics nomirror out scale 1,.1
set ytics scale 0

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
set key t l Left spacing 2 width 5 opaque font ",18"

##### tics (note that tics are also set in theme)
set xtics font ",18" offset 0,-1
set ytics font ",18" offset 1.5,0

##### plot
set title font ",18" "Influence on similarity score" offset -3,.3
set xlabel "IncNodePurity" offset 0,-2 font ",18"
set ylabel "" offset -2,0 font ",18"

set ytics textcolor 'black' offset .5,0;        set style data points;        set nokey;

plot '../rf/rf_importance_all_mdi.csv' u 3:(-$0):yticlabel(1) ls 1 pt 7

