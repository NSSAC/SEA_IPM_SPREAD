###########################################################################
# Given two clusters, finds sample average and mean of distances of two
# vectors, one from each list.
# Created: AA 2018-12-25
###########################################################################
import scipy.stats as stats
import numpy as np
import pdb
import sys
import argparse
import pandas as pd
from sklearn.cluster import KMeans

#SIM_FILE="../obj/cell_rank_BD_model_params.csv"
SIM_FILE="../obj/expected_time_BD.csv"
#SIM_FILE="../obj/infection_vector_BD.csv"
SAMPLE_SIZE=10000
CELL_START_IND=11
LOCALITY_CELLS="../../cellular_automata/obj/locality_cells.csv"
REPORTING_CELLS=[651957, 651965, 656282, 659158, 659166, 663477, 663489, 669234]
DESC="""Find average correlation (sample Pearson correlation coefficient)
between different classes of models. Modes:
- All cells considered (default);
- Only cells belonging to a locality are considered;
- Only reporting cells are considered."""

def sample_vector_distances(vectorList1,vectorList2,sampleSize):
    difference=np.zeros(SAMPLE_SIZE)
    for i in xrange(SAMPLE_SIZE):
        vector1=vectorList1.sample().ix[:,CELL_START_IND:]
        vector2=vectorList2.sample().ix[:,CELL_START_IND:]
        #difference[i]=stats.kendalltau(vector1.values[0],vector2.values[0])[0]
        #difference[i]=stats.spearmanr(vector1.values[0],vector2.values[0])[0]
        #difference[i]=stats.pearsonr(vector1.values[0],vector2.values[0])[0]
        difference[i]=np.linalg.norm(vector1.values[0]-vector2.values[0])
    return np.mean(difference),np.var(difference)

if __name__=="__main__":
    parser=argparse.ArgumentParser(description=DESC,
    formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("--locality_cells",help="Only cells belonging to localities will be considered.",action="store_true")
    parser.add_argument("--reporting_cells",help="Only reporting cells will be considered.",action="store_true")

    args=parser.parse_args()

    # read ranks
    rankList = pd.read_csv(SIM_FILE)

    # select only cells belonging to localities
    if args.locality_cells:
        localityCells = set(map(str,pd.read_csv(LOCALITY_CELLS,header=None)[0].tolist()))
        cellsInRankList=set(rankList.columns.tolist()[CELL_START_IND:])
        selectedCells=cellsInRankList.intersection(localityCells)
        selectedColumns=rankList.columns.tolist()[:CELL_START_IND]+sorted(list(selectedCells))
        rankList=rankList.loc[:,selectedColumns]

    # select only reporting cells
    if args.reporting_cells:
        reportingCells = set(map(str,REPORTING_CELLS))
        cellsInRankList=set(rankList.columns.tolist()[CELL_START_IND:])
        selectedCells=cellsInRankList.intersection(reportingCells)
        selectedColumns=rankList.columns.tolist()[:CELL_START_IND]+sorted(list(selectedCells))
        rankList=rankList.loc[:,selectedColumns]

    # filter ranks by class and choose only columns corresponding to cells
    classA=rankList[rankList["a_long"]==0]
    classB=rankList[rankList["a_long"]!=0]
    #classB=rankList[(rankList["a_long"]!=0) & (rankList["moore"]=="m3")].ix[:,CELL_START_IND:]
    
    # distance within class A
    [avg,var]=sample_rank_distances(classA,classA,SAMPLE_SIZE)
    print "A,A:",avg,var

    # distance within class B
    [avg,var]=sample_rank_distances(classB,classB,SAMPLE_SIZE)
    print "B,B:",avg,var

    # distance between class A & B
    [avg,var]=sample_rank_distances(classA,classB,SAMPLE_SIZE)
    print "A,B:",avg,var
