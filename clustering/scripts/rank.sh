#!/bin/bash
###########################################################################
# Extracting cell order from simulation output
###########################################################################
DB="../../cellular_automata/results/results.db"

function query_to_filenames(){
    rootDir=$1
    query=$2
    
    echo
}

if [[ $# == 0 ]]; then
   echo "Here are the options:"
   grep "^function" $BASH_SOURCE | sed -e 's/function/  /' -e 's/[(){]//g' -e '/IGNORE/d'
else 
   eval $1 $2
fi
