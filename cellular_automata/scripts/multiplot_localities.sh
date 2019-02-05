#!/bin/bash
# Allows user to compare circlize plots across desired axes
# read input
FOLDER="../results/cities/";

USAGE=$(
cat << EOF
Procedure:
1. Decide on x and y axes (Values are pop_thresh/radius).
2. Set pop_thresh (-p) and radius (-r).
   Note that the variables of x and y axes should be given as ranges.
   The ranges should be specified in the following way: "1 2 3 4".
The function will plot only if all the required files are present.
EOF
)

outFilePrefix='out'

while getopts :h:x:y:p:r:o: OPT;
do
   case "$OPT" in
      h) echo "$USAGE"|less; exit;;
      x) xAxis=$OPTARG;;
      y) yAxis=$OPTARG;;
      p) popThresh=$OPTARG;;
      r) locRad=$OPTARG;;
      o) outFilePrefix=$OPTARG;;
      \?) echo "Invalid option: $OPT"; echo "$usage"|less; exit;;
   esac
done

##### no arguments
if [ "$#" = "0" ]; then
   echo "$USAGE"|less;
   exit;
fi

function setCoordinates(){
if [[ "$xAxis" == "$1" ]]; then
   x=`expr $countX % $numX`;
   ((countX++));
elif [[ "$yAxis" == "$1" ]]; then
   y=`expr $countY % $numY`;
   ((countY++));
fi
}

function setXY(){
titlePop="";
titleLocRad="";
if [[ "$xAxis" == "pop_thresh" ]]; then
   numX=`echo $popThresh | awk '{print NF}'`;
   xVals=$popThresh
   xLabel="pop. thresh.";
   titlePop="";
elif [[ "$xAxis" == "radius" ]]; then
   numX=`echo $locRad | awk '{print NF}'`;
   xVals=$locRad
   xLabel="radius";
   titleLocRad="";
fi

if [[ "$yAxis" == "pop_thresh" ]]; then
   numY=`echo $popThresh | awk '{print NF}'`;
   yVals=$popThresh
   yLabel="pop. thresh.";
   titlePop="";
elif [[ "$yAxis" == "radius" ]]; then
   numY=`echo $locRad | awk '{print NF}'`;
   yVals=$locRad
   yLabel="radius";
   titleLocRad="";
fi

title="$titlePop$titleLocRad";
}

# preamble
cat << EOF > $outFilePrefix.tex
\PassOptionsToPackage{usenames,dvipsnames}{xcolor}
\documentclass[tikz,border=2]{standalone}
%% \usepackage{gillius2}
%% \renewcommand{\familydefault}{\sfdefault}
\usepackage{lmodern} % enhanced version of computer modern
\usepackage[T1]{fontenc} % for hyphenated characters and textsc in section title
\usepackage{amssymb}
\usepackage{microtype} % some compression
\usepackage[skins]{tcolorbox}
\usepackage{grffile}
%%%%%%%%%%
%%
\usetikzlibrary{shadows,arrows,shapes,positioning,calc,backgrounds,
fit,automata,decorations.markings,
decorations.pathreplacing,decorations.pathmorphing}
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
\begin{document}
\newcommand{\cplot}[3]{\node[] at (#2,#3) {\includegraphics[width=1cm]{#1}};}
\begin{tikzpicture}
[scale=1,auto, transform shape,
dedge/.style={>=latex', shorten >=.0pt, shorten <=.0pt},
axis/.style={ultra thin,black!60,dedge},
tic/.style={ultra thin,font=\tiny,black!60},
]
EOF

# create coordinates for all files
## coordinatesFile=.circlize_matrix_coordinates;
## rm -f $coordinatesFile;
countX=0;
countY=0;

numX=0;
numY=0;
setXY

for pt in $popThresh
do
   ((x=-1));
   ((y=-1));
   pt=`echo $pt | awk '{printf("%.0f",$1)}'`; 
   setCoordinates pop_thresh;
   for rad in $locRad
   do
      rad=`echo $rad | awk '{printf("%.0f",$1)}'`; 
      setCoordinates radius;

      pointFile=$FOLDER/localities_${rad}_cities_${pt}.png;
      if ! [[ -a $pointFile ]]; then
         echo "ERROR: $pointFile doesn't exist."
         exit 1
      fi
      echo "\\cplot{$pointFile}{$x}{$y}" >> ${outFilePrefix}.tex;
   done
done

# tics
x=0;
for xVal in $xVals
do
   echo "\draw[tic] ($x,-.5) -- ($x,-.55) node[shift={(0,-.1cm)},tic] {\$$xVal\$};" >> $outFilePrefix.tex
   ((x++))
done

y=0;
for yVal in $yVals
do
   echo "\draw[tic] (-.5,$y) -- (-.55,$y) node[shift={(.1cm,0)},tic,anchor=east] {\$$yVal\$};" >> $outFilePrefix.tex
   ((y++))
done


# postamble
cat << EOF >> $outFilePrefix.tex
\draw[axis,->] (-.6,-.5) -- (\$($numX,-.5)+(-.5,0)\$) node[font=\small,black,midway,below=.2] {$xLabel $\rightarrow$};
\draw[axis,->] (-.5,-.6) -- (\$(-.5,$numY)+(0,-.5)\$) node[font=\small,black,midway,shift={(-.5,.6)},rotate=90] {$yLabel $\rightarrow$};
\node [font=\small,shift={(0,.2cm)}] at (current bounding box.north) {$title};
\end{tikzpicture}
\end{document}
EOF

##### converting to pdf
pdflatex -interaction nonstopmode -halt-on-error -file-line-error ${outFilePrefix}.tex > /dev/null
if [[ $? -ne 0 ]]; then
   echo "Error in pdflatex"
   exit 1;
fi

clean_latex

