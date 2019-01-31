###########################################################################
# Given two clusters, finds sample average and mean of distances of two
# vectors, one from each list.
# Created: AA 2019-01-28
# tags: numpy argparse sys pandas pyclustering xmeans csv
###########################################################################
import numpy as np
import pdb
import argparse
import pandas as pd
import logging
import time
from pyclustering.cluster.xmeans import xmeans
from pyclustering.cluster.center_initializer import kmeans_plusplus_initializer
#from nltk.cluster.util import euclidean_distance

#SIM_FILE="../obj/cell_rank_BD_model_params.csv"
#SIM_FILE="../obj/expected_time_BD.csv"
SIM_FILE="../obj/infection_vector_BD.csv"
CELL_START_IND=11
START_NUM_CENTERS=2
KMAX=20
LOCALITY_CELLS="../../cellular_automata/obj/locality_cells.csv"
REPORTING_CELLS=[651957, 651965, 656282, 659158, 659166, 663477, 663489, 669234]
DESC="""Find average correlation (sample Pearson correlation coefficient)
between different classes of models. Modes:
- All cells considered (default);
- Only cells belonging to a locality are considered;
- Only reporting cells are considered."""

def clusterSimulationData(simulationData,kmax):
    # Prepare data (clipping to remove model parameters)
    selectedColumns=simulationData.columns.tolist()[CELL_START_IND:]
    simulationData=simulationData.loc[:,selectedColumns]

    logging.info("Clustering ...")
    start=time.time()

    # Cluster
    ## initialization
    initialCenters = kmeans_plusplus_initializer(simulationData.values.tolist(),START_NUM_CENTERS).initialize()
    clusterInstance = xmeans(simulationData.values.tolist(),tolerance=.001,initial_centers=initialCenters,kmax=kmax)

    ## cluster
    clusterInstance.process()
    clusters = clusterInstance.get_clusters()

    logging.info("Number of clusters: %d" %len(clusters))

    assignedClusters=np.zeros(simulationData.shape[0],dtype=int)
    clusterIndex=1
    for cluster in clusters:
        for cell in cluster:
            assignedClusters[cell]=clusterIndex 
        clusterIndex+=1

    # check if every vector belongs to a cluster
    if np.any(assignedClusters==0):
        logging.warning("At least one object does not belong to any cluster.")

    logging.info("done. %g minutes" %((time.time()-start)/60))

    ## # Find average distance
    ## # Can be used to find BIC
    ## means=kclusterer.means()
    ## simulationData["cluster"]=np.asarray(assignedClusters)
    ## simulationData["dist"]=simulationData.apply(lambda row: euclidean_distance(row[:-1],means[int(row[-1])]),axis=1)
    ## # BIC=simulationData["dist_squared"].sum()+.5*numClusters*

    return assignedClusters #,simulationData["dist"].mean()

if __name__=="__main__":
    parser=argparse.ArgumentParser(description=DESC,
    formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("-k","--kmax",type=int,default=KMAX,help="max. number of clusters",action="store")
    parser.add_argument("-o","--output_file",default="clusters.csv",help="output file of cluster assignments",action="store")

    args=parser.parse_args()

    logging.basicConfig(level=logging.INFO)

    # read simulation outputs
    simData = pd.read_csv(SIM_FILE)

    # filter
    # simData=simData[(simData["start_month"]==5) & (simData["seed"]==0)]
    logging.info("Shape of data:")
    logging.info(simData.shape)

    # cluster
    clusters=clusterSimulationData(simData,args.kmax)

    # write outputt
    selectedColumns=simData.columns.tolist()[:CELL_START_IND]
    simData=simData.loc[:,selectedColumns]
    simData["cluster"]=np.asarray(clusters)
    
    simData.to_csv(args.output_file,index=False,float_format="%g")
