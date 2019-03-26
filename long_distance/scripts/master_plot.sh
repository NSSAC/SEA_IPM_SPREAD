#!/bin/bash
function domestic_validation(){
python ../scripts/ld_netplot.py 
}

function cities(){ #IGNORE
cities='../../cellular_automata/obj/cities/cities_250000.csv'
iso=$1
grep $iso $cities > ${iso}_cities.txt
if [[ "$iso" == "MYS" ]]; then
    grep SGP $cities >> ${iso}_cities.txt
fi
}

function annual_flow(){ #IGNORE
gawk -F, -v OFS=',' '{if($1!=$2) a[$1][$2]+=$3}END{for(i in a) for(j in a[i]) \
    if(a[i][j]>0) print i,j,a[i][j]}' $1 > $2
}

function domestic_netplot(){ #IGNORE
iso=$1
# generate cities
cities $iso
}

function trade_flows(){
monthlyFlowFile="../obj/locality_flows_precip1_b2_k500.csv"
flowFile=`basename $monthlyFlowFile | sed -e 's/locality/annual/'`
annual_flow $monthlyFlowFile $flowFile

for iso in `echo "BGD VNM THA PHL MYS IDN MMR"`
do
outFile=`basename $monthlyFlowFile | sed -e "s/locality/$iso/" -e 's/.csv//'`
if [ -a ${outFile}.pdf ]; then
    echo "skipping $iso"
    continue
fi
echo $iso
cities $iso
python ../scripts/ld_netplot.py $flowFile ${iso}_cities.txt -o $outFile -t 500
mv ${outFile}.pdf ../results/validation/
mv ${outFile}.tex ../results/validation/
done
}

function net_prod_flows(){ # flows in localities
for monthlyFlowFile in `ls -1 ../obj/locality_flows_precip1_b*csv`
do
#monthlyFlowFile="../obj/locality_flows_precip1_b2_k500.csv"
flowFile=`basename $monthlyFlowFile | sed -e 's/locality/props/'`
plotFile=`basename $flowFile | sed -e 's/.csv//' -e 's/props/prod_netout/'`
# compute net outflow (nof), production (p)
gawk -F, -v OFS=',' '{\
    nof[$1]+=$3;nof[$2]-=$3;p[$1]+=$3;\
    nofm[$1][$4]+=$3;nofm[$2][$4]-=$3}\
    END{for(i in nofm){negm[i]=0;posm[i]=0;\
    for(j in nofm[i])\
    (nofm[i][j]<0)? negm[i]+=nofm[i][j]:posm[i]+=nofm[i][j];}\
    for(i in nof) print i,nof[i],p[i],negm[i]/(posm[i]-negm[i]+.0),posm[i]/(posm[i]-negm[i]+.0)}' $monthlyFlowFile | sort -t, -n -k2,2 -r > $flowFile

../../cellular_automata/scripts/plot.sh -o $plotFile \
   -c mathematica \
   -m lines \
   -x "Localities ordered by outflow" \
   -y "Amount in KTonnes" \
   -f "all:18" \
   -a "set notitle; \
       set key t r width 7; \
       set ytics offset 2,0; \
       set xtics offset 0,-.5; \
       set xlabel offset 0,.4; \
       set ylabel offset -.2,0; \
       set format y \"%.s\"; \
       set xtics font \",15\";" \
   -p "plot \"$flowFile\" u 3 w boxes fs solid .5 ls 7 t \"Production\",\"$flowFile\" u 2 ls 4 lw 10 t \"Net outflow\";"

mv $plotFile.* ../results/

plotFile=`basename $flowFile | sed -e 's/.csv//' -e 's/props/monthly_in_out/'`
../../cellular_automata/scripts/plot.sh -o $plotFile \
   -c mathematica \
   -m lines \
   -x "Localities ordered by outflow" \
   -y "\\\\parbox{7cm}{\\\centering Normalized accumulated monthly flows}" \
   -f "all:18" \
   -a "set notitle; \
       set key t r width 7; \
       set ytics offset 2,0; \
       set xtics offset 0,-.5; \
       set xlabel offset 0,.4; \
       set ylabel offset -4,0; \
       set xtics font \",15\";" \
   -p "plot \"$flowFile\" u 4 w boxes fs solid .5 ls 1 t \"inflow\",\"$flowFile\" u 5 w boxes fs solid .5 ls 2 t \"outflow\";"

mv $plotFile.* ../results/
mv $flowFile ../results/
done
}

function distance_source_sink(){
prodThresh=10000
consThresh=10000
outFile=source_sink_distances_${prodThresh}_${consThresh}.csv
rm -f $outFile

majorProd=`awk -F, -v prod=$prodThresh '{if ($2>prod) print $1}' ../results/props_flows_precip1_b2_k500.csv`
majorCons=`awk -F, -v cons=$consThresh '{if ($2<-cons) print $1}' ../results/props_flows_precip1_b2_k500.csv`
for p in $majorProd
do
for c in $majorCons
do
grep "$p,$c" ../../distance_matrix/results/time_distance_250000.csv >> .temp.distance_prod_cons
grep "$c,$p" ../../distance_matrix/results/time_distance_250000.csv >> .temp.distance_prod_cons
done
done
sort .temp.distance_prod_cons | uniq | sort -n -k4,4 -t, > $outFile
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
