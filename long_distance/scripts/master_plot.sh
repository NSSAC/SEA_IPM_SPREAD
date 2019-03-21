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
montlyFlowFile="../obj/locality_flows_precip1_b2_k500.csv"
flowFile=`basename $montlyFlowFile | sed -e 's/locality/annual/'`
annual_flow $montlyFlowFile $flowFile

for iso in `echo "BGD VNM THA PHL MYS IDN MMR"`
do
outFile=`basename $montlyFlowFile | sed -e "s/locality/$iso/" -e 's/.csv//'`
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

function net_flows(){
montlyFlowFile="../obj/locality_flows_precip1_b2_k500.csv"
flowFile=`basename $montlyFlowFile | sed -e 's/locality/netout/'`
gawk -F, -v OFS=',' '{a[$1]+=$3;a[$2]-=$3}END{for(i in a) print i,a[i]}' $montlyFlowFile | sort -t, -n -k2,2 -r > $flowFile
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
