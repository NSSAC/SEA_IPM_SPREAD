#!/bin/bash
# Plotting script based on gnuplot with tikz terminal. Do
# plot.sh -h for help.
# by none other than abhijin adiga

# REM
export GP_PATH='~/Dropbox/proj/gp/src';
usage=$(
cat << EOF
plot.sh [OPTION]
-----
DESCRIPTION: This script is intended to make plotting with gnuplot easier,
and also aesthetically pleasing (subjective).  The idea is to set up the
basic theme, line styles, plot styles, title, xlabel, ylabel, etc. quickly
by passing them as arguments. Since every plot is different from the
previous one, it also provides handles to customize these styles and plot
commands. The idea will become clear with examples: see the .egg files in
\$GP/examples/. Also see \$GP/examples/examples.pdf for the output of these
examples. It uses the Tikz terminal. The outputs are a gnuplot source file
and a tex file.
----- help & example
-h    this help
-e    example mode (will give a plot without any data)
----- i/o
-o    output plot file (pdf)
----- plot ingredients
-t    title string
-S    size "<x>cm,<y>cm"
-x    x label
-P    axis position (regular <default>/2y/xzero)
   --- regular/xzero
   -y    y label
   -i    input files list in two column format with first row as header (optional)
   --- y2
   -y    y1 label
   -Y    y2 label
   -i    input files list for y1
   -I    input files list for y2
----- look & feel
-m    mode (linespoints <default>/lines/points/hist/pie/donut)
-c    line color theme: see below for a list
-l    line type (solid <default>/dashed)
-T    theme (compact <default>/classic/hist/pie)
-f    fonts: string format: "<type>:<fontsize> <type>:<fontsize> ..."
         types currently supported: title; label (x,y labels); key; tics; all (wild card, every font the same size)
      (default: "title:14 label:12 key:12 tics:10")
----- plotting
-a    aux string (this is where you customize before plotting) (default is empty)
-p    plot string (if you want something different from default) (default is empty)
----- additional magic
-s    smooth functionality (e.g. "smooth bezier/smooth freq")
-u    using columns string (default "1:2")
----- Latex attachments
-z    This will append any tikz code to the tex before compiling.
-----
Line color themes (also see examples)
cb_paired   color brewer qualitative paired (default)
mathematica Mathematica default scheme
-----
Pending:
- histograms
- grayscale
EOF
)

##### set defaults
theme="compact";
mode="linespoints";
axisPosition="regular";
lineType="solid";
lineColor="cb_paired";
plotString="";
sizeString=12.5cm,8.75cm;
usingString="1:2";
## font sizes
titleFont=14;
labelFont=12;
keyFont=12;
ticsFont=10;
##
exampleMode=0;

while getopts :i:I:o:ht:x:y:Y:a:u:m:T:s:P:l:c:p:f:S:z:e OPT;
do
   case "$OPT" in
      a) auxString=$OPTARG;;
      c) lineColor=$OPTARG;;
      f) fontString=$OPTARG;;
      e) exampleMode=1;;
      l) lineType=$OPTARG;;
      h) echo "$usage"|less; exit;;
      i) inFileList=$OPTARG;;
      I) y2inFileList=$OPTARG;;
      m) mode=$OPTARG;;
      o) outFileString=$OPTARG;;
      s) smoothString=$OPTARG;;
      S) sizeString=$OPTARG;;
      T) theme=$OPTARG;;
      t) title=$OPTARG;;
      x) x=$OPTARG;;
      P) axisPosition=$OPTARG;;
      p) plotString="$OPTARG";;
      u) usingString="$OPTARG";;
      y) y=$OPTARG;;
      Y) Y=$OPTARG;;
      z) tikz=$OPTARG;;
      \?) echo "Invalid option: $OPT"; echo "$usage"|less; exit;;
   esac
done

##### no arguments
if [ "$#" = "0" ]; then
   echo "$usage"|less;
   exit;
fi

##### line color theme
lsCBPaired=$(
cat << EOF
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
EOF
)

lsCBPaired_9=$(
cat << EOF
CB_PAIRED_9="#A6CEE3 #1F78B4 #B2DF8A #33A02C #FB9A99 #E31A1C #FDBF6F #FF7F00 #CAB2D6"
do for[i=1:9] {set style line i lc rgb word(CB_PAIRED_9,i)}
####
EOF
)

lsCBQualSet1_9=$(
cat << EOF
CB_QUAL_SET1_9="#E41A1C #377EB8 #4DAF4A #984EA3 #FF7F00 #FFFF33 #A65628 #F781BF #999999"
do for[i=1:9] {set style line i lc rgb word(CB_QUAL_SET1_9,i)}
####
EOF
)

lsCBQualSet3_9=$(
cat << EOF
CB_QUAL_SET3_9="#8DD3C7 #FFFFB3 #BEBADA #FB8072 #80B1D3 #FDB462 #B3DE69 #FCCDE5 #D9D9D9"
do for[i=1:9] {set style line i lc rgb word(CB_QUAL_SET3_9,i)}
####
EOF
)

lsCBPuBu_9=$(
cat << EOF
CB_PUBU_9="#FFF7FB #ECE7F2 #D0D1E6 #A6BDDB #74A9CF #3690C0 #0570B0 #045A8D #023858"
do for[i=1:9] {set style line i lc rgb word(CB_PUBU_9,i)}
####
EOF
)

lsCBSpectral_9=$(
cat << EOF
CB_SPECTRAL_9="#D53E4F #F46D43 #FDAE61 #FEE08B #FFFFBF #E6F598 #ABDDA4 #66C2A5 #3288BD"
do for[i=1:9] {set style line i lc rgb word(CB_SPECTRAL_9,i)}
####
EOF
)

lsMathematicaDefault=$(
cat << EOF
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
EOF
)

if [[ "$lineColor" = "cb_paired" ]]; then
   lineColorString=$lsCBPaired;
elif [[ "$lineColor" = "cb_paired_9" ]]; then
   lineColorString=$lsCBQual_1_9;
elif [[ "$lineColor" = "cb_qual_set1_9" ]]; then
   lineColorString=$lsCBQualSet1_9;
elif [[ "$lineColor" = "cb_qual_set3_9" ]]; then
   lineColorString=$lsCBQualSet3_9;
elif [[ "$lineColor" = "cb_pubu_9" ]]; then
   lineColorString=$lsCBPuBu_9;
elif [[ "$lineColor" = "cb_spectral_9" ]]; then
   lineColorString=$lsCBSpectral_9;
elif [[ "$lineColor" = "mathematica" ]]; then
   lineColorString=$lsMathematicaDefault;
else
   printf "ERROR: %s line color theme unsupported\n" $lineColor;
   exit 1;
fi

##### mode
if [[ "$mode" = "linespoints" ]]; then
   modeString=$(
cat << EOF
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
EOF
)
elif [[ "$mode" = "lines" ]]; then
   modeString="set style data lines";
elif [[ "$mode" = "points" ]]; then
   modeString=$(
cat << EOF
set style data points
set style line 1 pt 7
set style line 2 pt 7
set style line 3 pt 7
set style line 4 pt 7
set style line 5 pt 7
set style line 6 pt 7
set style line 7 pt 7
set style line 8 pt 7
#
do for [i=1:15] {set style line i ps 2}
EOF
)
elif [[ "$mode" = "hist" ]]; then
   modeString=$(
cat << EOF
set style fill solid noborder
set boxwidth 0.9
set style data histogram; 
set style histogram cluster gap 1 
EOF
)
elif [[ "$mode" = "pie" ]] || [[ "$mode" = "donut" ]]; then
   modeString=$(
cat << EOF
set style fill solid 1
stats '$inFileList' u 2 noout
ang(x)=x*360.0/STATS_sum        # get angle (grades)
perc(x)=x*100.0/STATS_sum       # get percentage
#
Ai = 0.0; Bi = 0.0;             # init angle
Ou=.8                           # outward shift
i = 0; j = 0;                   # color
yi  = .75; yi2 = .75;           # label position
Cs = .35;                       # inner circle size for donut
# canvas
set size ratio -1
set xrange [-1:2.5]
set yrange [-1.25:1.25]
EOF
)
else
   printf "ERROR: %s mode unsupported\n" $mode;
   exit 1;
fi

##### axisPosition
if [ "$plotString" == "" ]; then
   if [[ "$axisPosition" = "regular" ]]; then
      plotString=$(
cat << EOF
plot for [file in "`echo ${inFileList}`"] file using $usingString title columnheader(1) $smoothString $afterPlotString;
EOF
      )
   elif [[ "$axisPosition" = "y2" ]]; then
      plotString=$(
cat << EOF
plot for [file in "`echo ${inFileList}`"] file using $usingString title columnheader(1) $smoothString $afterPlotString axes x1y1, for [file in "`echo ${y2inFileList}`"] file using $usingString title columnheader(1) $smoothString $afterPlotString axes x1y2
EOF
      )
   else
      printf "ERROR: %s axis position unsupported\n" $axisPosition;
      exit 1;
   fi
   if [[ "$mode" = "pie" ]] || [[ "$mode" = "donut" ]]; then
      plotString=$(
cat << EOF
plot '$inFileList' u (0):(0):(1):(Ai):(Ai=Ai+ang(\$2)):(i=i+1) with circle noti linecolor var, \
     '$inFileList' u (1.3):(yi=yi-1/STATS_records):(\$1) w labels noti left font ",10", \
     '$inFileList' u (1.3):(yi2=yi2-1/STATS_records):(j=j+1) w p pt 5 ps 3 linecolor var noti, \
     '$inFileList' u (mid=Bi+ang(\$2)*pi/360.0, Bi=2.0*mid-Bi, Ou*cos(mid)):(Ou*sin(mid)):(sprintf('%.1f\\\%', perc(\$2))) w labels noti font ",8"
EOF
      )
   fi
   if [[ "$mode" = "donut" ]]; then
      plotString="$plotString, '$inFileList' u (0):(0):(Cs) with circle noti lc rgb 'white'"
   fi
fi

##### font string
for typePairs in `echo $fontString`
do
   type=`echo $typePairs | awk -F ':' '{print $1}'`;
   size=`echo $typePairs | awk -F ':' '{print $2}'`;
   ## if [[ "$size" != "[0-9]+$" ]]; then
   ##    echo "ERROR: font size should be an integer -> \"$type:$size\"";
   ##    exit;
   ## fi

   case "$type" in
      title) titleFont=$size;;
      tics)  ticsFont=$size;;
      label) labelFont=$size;;
      key)   keyFont=$size;;
      all)   titleFont=$size; ticsFont=$size; labelFont=$size; keyFont=$size; break;;
      \?) echo "ERROR: invalid type: $type"; exit;;
   esac
done

##### setting the key
keyString="set key t l Left spacing 2 width 5 opaque font \",$keyFont\"";
if [[ "$keyFont" = "12" ]]; then
   keyString="set key t l Left spacing 2 width 5 opaque font \",$keyFont\"";
elif [[ "$keyFont" = "15" ]]; then
   keyString="set key t l Left spacing 2 width 5 opaque font \",$keyFont\"";
elif [[ "$keyFont" = "16" ]]; then
   keyString="set key t l Left spacing 3 width 5 opaque font \",$keyFont\"";
elif [[ "$keyFont" = "20" ]]; then
   keyString="set key t l Left spacing 4 width 5 opaque font \",$keyFont\"";
fi

##### setting the title
titleString="set title font \",$titleFont\" \"${title}\" offset -3,.3";

##### setting the xlabel
xlabelString="set xlabel \"$x\" offset 0,0 font \",$labelFont\"";
if [[ "$labelFont" = "12" ]]; then
   xlabelString="set xlabel \"$x\" offset 0,-.7 font \",$labelFont\"";
elif [[ "$labelFont" = "16" ]]; then
   xlabelString="set xlabel \"$x\" offset 0,-1 font \",$labelFont\"";
elif [[ "$labelFont" = "20" ]]; then
   xlabelString="set xlabel \"$x\" offset 0,-2 font \",$labelFont\"";
fi

##### setting the ylabel
ylabelString="set ylabel \"$y\" offset -2,0 font \",$labelFont\"";
if [[ "$labelFont" = "12" ]]; then
   ylabelString="set ylabel \"$y\" offset -2,0 font \",$labelFont\"";
elif [[ "$labelFont" = "20" ]]; then
   ylabelString="set ylabel \"$y\" offset -4.5,0 font \",$labelFont\"";
fi

##### setting the y2label
y2labelString="set y2label \"$Y\" offset 1,0 font \",$labelFont\"";
if [[ "$labelFont" = "12" ]]; then
   y2labelString="set y2label \"$Y\" offset 1,0 font \",$labelFont\"";
fi

if [ "$mode" = "pie" ] || [[ "$mode" = "donut" ]]; then
   xlabelString=""
   ylabelString=""
fi

##### setting the tics
xticsString="set xtics font \",$ticsFont\" offset 0,.2";
yticsString="set ytics font \",$ticsFont\" offset 1.5,0"; 
if [[ "$ticsFont" = "10" ]]; then
   xticsString="set xtics font \",$ticsFont\" offset 0,.1";
   yticsString="set ytics font \",$ticsFont\" offset 1.5,0"; 
elif [[ "$ticsFont" = "16" ]]; then
   xticsString="set xtics font \",$ticsFont\" offset 0,-.1";
   yticsString="set ytics font \",$ticsFont\" offset 1.5,-.2"; 
elif [[ "$ticsFont" = "20" ]]; then
   xticsString="set xtics font \",$ticsFont\" offset 0,-1";
   yticsString="set ytics font \",$ticsFont\" offset 1.7,-.4"; 
fi

if [ "$mode" = "pie" ] || [[ "$mode" = "donut" ]]; then
   xticsString="unset xtics"
   yticsString="unset ytics"
fi

##### example mode: bypasses plotString
if [ "$exampleMode" = "1" ]; then
   title="example";
   x="\$x\$";
   y="\$f(x)\$";
   plotString=$(
   cat << EOF
   set xrange[0:3];
   set yrange[0:1];
   set key t r;
   plot 0.9*sin(2*x) with lines ti "sin(2*x)", exp(-x) with lines ti "exp(-x)";
   )

   if [ "$outFileString" = "" ]; then
      outFileString=example;
   fi
fi

# Background
if [ "$theme" = "classic" ] && [ "$axisPosition" = "regular" ]; then
   bgTheme=$(
cat << EOF
# border
set style line 11 lt 1 lc rgb '#808080' 
set border 3 back ls 11
# axes
set arrow 1 from graph 0,0 to graph 1.02,0 size screen 0.025,15,60 filled ls 11 lw 3 
set arrow 2 from graph 0,0 to graph 0,1.01 size screen 0.025,15,60 filled ls 11 lw 3
# grid
set style line 12 lt 2 lc rgb '#CCCCCC' lw 2
set style line 13 lt 2 lc rgb '#DDDDDD' lw 1
set grid xtics mxtics ytics mytics back ls 12, ls 13
#tics
set tics textcolor rgb '#303030'
set tics nomirror out scale .5,.1
set mxtics 2
set mytics 2
EOF
   )
elif [ "$theme" = "compact" ] && [ "$axisPosition" = "regular" ]; then
   bgTheme=$(
cat << EOF
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
EOF
   )
elif [ "$theme" = "compact" ] && [ "$axisPosition" = "y2" ]; then
   bgTheme=$(
cat << EOF
# border
set style line 11 lt 1 lc rgb '#808080' 
set border 3 back ls 11 lw 5
set arrow 1 from graph 1.0,0 to graph 1.0,1.0 nohead ls 11 lw 5 
# grid
set style line 12 lt 2 lc rgb '#CCCCCC' lw 2
set style line 13 lt 2 lc rgb '#DDDDDD' lw 1
set grid x y xtics mxtics ytics mytics back ls 12, ls 13
#tics
set tics textcolor rgb '#303030'
set tics nomirror out scale 1
set y2tics offset -1,0
set mxtics 2
set mytics 2
EOF
   )
elif [ "$theme" = "hist" ] && [ "$axisPosition" = "regular" ]; then
   bgTheme=$(
cat << EOF
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
EOF
   )
elif [ "$theme" = "pie" ] || [[ "$mode" = "donut" ]]; then
   bgTheme=$(
cat << EOF
# border
unset border
unset xlabel
unset ylabel
# grid
unset grid
# tics
unset key
EOF
   )
fi

# Line type
if [ "$lineType" = "solid" ]; then
   lineType=$(
cat << EOF
set style increment user
# taken care of in terminal
do for [i=1:15] { set style line i lt 1 lw 7 }
EOF
   )
elif [ "$lineType" = "dashed" ]; then
   lineType=$(
cat << EOF
set style increment user
# taken care of in terminal
set style line 1 lt 1 lw 7
set style line 2 lt 2 lw 7
set style line 3 lt 3 lw 7
set style line 4 lt 5 lw 7
set style line 5 lt 8 lw 7
set style line 6 lt 13 lw 7
EOF
   )
fi

# set of predefined colors
colorSpace=$(
cat << EOF
##### http://www.colourlovers.com/palette/268142/Danger_Mouse
Danger='#F84934'; # red
Shoes='#4D5E5F'; # grey
##### Rand Olson
roBlue='#1F77B4';
roRed='#D62728';
EOF
)

#######################################################################
cat << EOF > ${outFileString}.gp
##### terminal
set term tikz standalone size $sizeString font ",14" gparrows scale 2,2 textscale 2
set datafile separator ','

##### output
set output '${outFileString}.tex'

##### bg: bg color, axes, grid, tics
$colorSpace
$bgTheme

##### load default linestyles
$lineType

##### line colors
$lineColorString

##### data style
$modeString

# NOTE: offsets should be a function of font sizes
##### key
$keyString

##### tics (note that tics are also set in theme)
$xticsString
$yticsString

##### plot
$titleString
$xlabelString
$ylabelString
$y2labelSting

$auxString

$plotString

EOF

gnuplot ${outFileString}.gp #> /dev/null;

if [[ $? -ne 0 ]]; then
   echo "Skipping pdflatex"
   rm ${outFileString}.tex;
   exit 1;
fi

##### append tikz code
#gsed -i "s/\\\end{tikzpicture}/$tikz\n\\\end{tikzpicture}/" ${outFileString}.tex:

##### converting to pdf
pdflatex -interaction nonstopmode -halt-on-error -file-line-error ${outFileString}.tex > /dev/null

if [[ $? -ne 0 ]]; then
   echo "Error converting to pdf"
   exit 1;
fi

##### cleaning up
rm ${outFileString}.aux ${outFileString}.log;

