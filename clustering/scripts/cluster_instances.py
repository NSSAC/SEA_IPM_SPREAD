###########################################################################
# Given two clusters, finds sample average and mean of distances of two
# vectors, one from each list.
# Created: AA 2018-12-25
# https://www.nltk.org/api/nltk.cluster.html
# http://ai.intelligentonlinetools.com/ml/tag/k-means-clustering-example/
# tags: numpy argparse sys pandas nltk kmeans csv
###########################################################################
import numpy as np
import pdb
import argparse
import pandas as pd
import logging
import time
from nltk.cluster.kmeans import KMeansClusterer
from nltk.cluster.util import euclidean_distance

#SIM_FILE="../obj/cell_rank_BD_model_params.csv"
#SIM_FILE="../obj/expected_time_BD.csv"
SIM_FILE="../obj/infection_vector_BD.csv"
SAMPLE_SIZE=10000
CELL_START_IND=11
LOCALITY_CELLS="../../cellular_automata/obj/locality_cells.csv"
REPORTING_CELLS=[651957, 651965, 656282, 659158, 659166, 663477, 663489, 669234]
DESC="""Find average correlation (sample Pearson correlation coefficient)
between different classes of models. Modes:
- All cells considered (default);
- Only cells belonging to a locality are considered;
- Only reporting cells are considered."""


def clusterSimulationData(simulationData,numClusters):
    # Prepare data (clipping to remove model parameters)
    selectedColumns=simulationData.columns.tolist()[CELL_START_IND:]
    simulationData=simulationData.loc[:,selectedColumns]

    logging.info("Clustering ...")
    start=time.time()

    # Cluster
    ## initialization
    kclusterer = KMeansClusterer(numClusters, distance=euclidean_distance, repeats=100)
    ## cluster
    assignedClusters = kclusterer.cluster(simulationData.values, assign_clusters=True)
    logging.info("done. %g minutes" %((time.time()-start)/60))

    # Find average distance
    # Can be used to find BIC
    means=kclusterer.means()
    simulationData["cluster"]=np.asarray(assignedClusters)
    simulationData["dist"]=simulationData.apply(lambda row: euclidean_distance(row[:-1],means[int(row[-1])]),axis=1)
    # BIC=simulationData["dist_squared"].sum()+.5*numClusters*

    return assignedClusters,simulationData["dist"].mean()

if __name__=="__main__":
    parser=argparse.ArgumentParser(description=DESC,
    formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("--locality_cells",help="Only cells belonging to localities will be considered.",action="store_true")
    parser.add_argument("--reporting_cells",help="Only reporting cells will be considered.",action="store_true")
    parser.add_argument("-k","--num_clusters",type=int,help="number of clusters",action="store")

    args=parser.parse_args()

    logging.basicConfig(level=logging.INFO)

    # read simulation outputs
    simData = pd.read_csv(SIM_FILE)

    # cluster
    [clusters,avgDistance]=clusterSimulationData(simData,args.num_clusters)

    # write outputt
    selectedColumns=simData.columns.tolist()[:CELL_START_IND]
    simData=simData.loc[:,selectedColumns]
    simData["cluster"]=np.asarray(clusters)
    
    simData.to_csv("instance_cluster_%d.csv" %args.num_clusters,index=False,float_format="%g")
    print "Number of clusters: %d" %args.num_clusters
    print "Average distance: %g" %avgDistance
