#!/bin/bash
DATA="../data";

function evaluate_ca() { # evaluate CAs based on different metrics
rm -f results.txt
for f in `ls -1 $1/output_*csv` # example ../results/output_ndvi2
do
    for u in `seq 1 3`
    do
        python ../scripts/evaluate_ca.py $f -u $u >> results.txt;
    done
done
}

function create_ca() { # run this to create cellular automata files for different moore neighborhoods
for moore in `seq 1 4`
do
   python ../scripts/create_ca.py -M $moore --lat_min -40 --lat_max 40 --lon_min -20 --lon_max 60 -o ca_model_1x1_africa_M${moore}.pkl
done
}

function run_ca() { # parameter sweep for run_ca
eval "rm out/evaluation1.csv";
eval "rm out/evaluation2.csv";
eval "rm out/evaluation3.csv";
eval "touch out/evaluation1.csv";
eval "touch out/evaluation2.csv";
eval "touch out/evaluation3.csv";

ndviList="0.12 0.14 0.16 0.18 0.2";
tempList="28";
humidityList="60";
mooreList=`seq 1 4`;
prodList="100 1000 10";

for ndvi in $ndviList
do
   for temp in $tempList
   do
      for humidity in $humidityList
      do
         for moore in $mooreList
         do
	    for prod in $prodList
	    do
                echo $ndvi $temp $humidity $moore $prod
                expName="dummy"
                logFile=${expName}.log;
            
	        # eval "python ../scripts/run_ca.py -T $temp -H $humidity -n 24 -M $moore -ndvi2 $ndvi -p $prod";  
		eval "sbatch --export=prod=$prod,moore=$moore,humidity=$humidity,temp=$temp,ndvi=$ndvi ../scripts/jobs.sbatch";
	    done
         done
      done
   done
done
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi

