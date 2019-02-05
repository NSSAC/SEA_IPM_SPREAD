##### terminal
clear
# set loadpath '~/Dropbox/proj/gp/src'
set term tikz standalone size 12.5cm,8.75cm font ",14" gparrows scale 2,2 textscale 2
set datafile separator ','

##### output
set output 'concentration_with_radius.tex'

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
# cb_paired
LightBlue=  '#A6CEE3'
DarkBlue=   '#1F78B4'
LightGreen= '#B2DF8A'
DarkGreen=  '#33A02C'
LightRed=   '#FB9A99'
DarkRed=    '#E31A1C'
LightOrange='#FDBF6F'
DarkOrange= '#FF7F00'
CB_PAIRED="#A6CEE3 #1F78B4 #B2DF8A #33A02C #FB9A99 #E31A1C #FDBF6F #FF7F00"
do for[i=1:8] {set style line i lc rgb word(CB_PAIRED,i)}
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
set key t l Left spacing 4 width 5 opaque font ",12"

##### tics (note that tics are also set in theme)
set xtics font ",10" offset 0,.1
set ytics font ",10" offset 1.5,0

##### plot
set title font ",14" "Production and population" offset -3,.3
set xlabel "radius" offset 0,-.7 font ",12"
set ylabel "concentration" offset -2,0 font ",12"


set style line 1 lw 7 ps 2.75 pi -1 pt 5 lc rgb '#5e82b5';         set style line 2 lw 7 ps 2.75 pi -1 pt 7 lc rgb '#e09c24';         set style line 3 lw 7 ps 2.75 pi -1 pt 13 lc rgb '#8fb030';         set style line 4 lw 7 ps 2.75 pi -1 pt 5 lc rgb '#5e82b5';         set style line 5 lw 7 ps 2.75 pi -1 pt 7 lc rgb '#e09c24';         set style line 6 lw 7 ps 2.75 pi -1 pt 13 lc rgb '#8fb030';         set style increment user;
        set key r b width 8;
        set yrange [0:1];
        set xrange [50:100];
        

plot for [file in "concentrations_pt100000.csv concentrations_pt250000.csv concentrations_pt500000.csv"] file u 1:3 ti columnheader(1),         for [file in "concentrations_pt100000.csv concentrations_pt250000.csv concentrations_pt500000.csv"] file u 1:4 noti dashtype 2;

set term x11 reset;
