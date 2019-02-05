import argparse
import os
from os import listdir
from evaluate_probs import seasonInd2Int
import math
import pandas as pd
import pdb
import numpy as np
from fill_data_ca import haversine, load_object
#from plot_ca import cumulate

SEED_FILE = "../data/seed_files/seed_BGD_moore0.csv"
GRID_FILE = "../obj/ca_precip1_b2_k500.pkl"
TEMPLATE = "../obj/haversine_and_probs.csv"
HIST_STEP = 200.0

def cumulate(csvfile, time, start):
    df = pd.read_csv(csvfile, header=0, index_col = 'cell_id')
    for index, item in df.iterrows():
            prob_list = [item[str(j)] for j in range(start, time+1)]
            cumulated_sum = sum(prob_list)
            df.at[index, str(time)] = cumulated_sum
    return df

def create_file(input, seed_file, csv_file, grid_file, time):

    parList=os.path.basename(csv_file).split('_')
    seasonInd=seasonInd2Int(parList[1])
    beta=float(parList[2][1:])
    kappa=int(parList[3][1:])
    seed=int(parList[4][1:])
    start_month=int(parList[5][2:])
    moore=int(parList[6][1:])
    suit_thresh=float(parList[7][2:])
    exp_delay=int(parList[8][2:])
    alphas=parList[9].rstrip('.csv').split('-')
    alpha_sd=float(alphas[1])
    alpha_fm=float(alphas[2])
    alpha_ld=float(alphas[3])

    prob_str = 'probability'
    simulation = cumulate(csv_file, time, start_month)
    output_dict = {}
    input_df = pd.read_csv(input, skiprows=[0], header=None, names=['cell_id','haversine',prob_str], index_col = 'cell_id')
    for index, row in simulation.iterrows():
        # input_df.at[float(index),prob_str] = row[str(time)]
        our_value = math.ceil(input_df.loc[float(index)]['haversine']/HIST_STEP)*HIST_STEP
        try:
            output_dict[our_value] += row[str(time)]
        except:
            output_dict[our_value] = row[str(time)]
    for key, value in output_dict.items():
        print "INSERT INTO dist_inf (season_ind,beta,kappa,seed,start_month,moore,suit_thresh,latency_period,alpha_sd,alpha_fm,alpha_ld,distance,time,cumprob) VALUES (%d,%g,%g,%d,%d,%d,%g,%d,%g,%g,%g,%d,%g,%g);" %(seasonInd,\
            beta,\
            kappa,\
            seed,\
            start_month,\
            moore,\
            suit_thresh,\
            exp_delay,\
            alpha_sd,\
            alpha_fm,\
            alpha_ld,\
            key,\
            time,\
            value)

        #output_df = pd.from_dict(output_dict, 
        #input_df.to_csv(output, ignore_index=True)
        
## except:
##     ##### Not used by making input file a constant
##     ca = load_object(grid_file)
##     # seed_df = pd.read_csv(seed_file, skiprows=[0], header = None, \
##     #    names = ['#cell_id','adc_id','admin','country'],index_col = '#cell_id')
##     cell_id = index
##     min_distance = 100000
##     for seed, value in seed_df.iterrows():
##         coord1 = (ca.cells[cell_id].vertices[0][0],ca.cells[cell_id].vertices[0][1])
##         coord2 = (ca.cells[seed].vertices[0][0],ca.cells[SEED].vertices[0][1])
##         cell_distance = haversine(coord1, coord2)
##     output_df = output_df.append({'cell_id': cell_id, 'haversine':cell_distance, prob_str:0}, ignore_index = True)
##     output_df.to_csv(output, index=False)
##     input_df = pd.read_csv(output, skiprows=[0], header=None, names=['cell_id','haversine',prob_str], index_col = 'cell_id')
##     for index, row in simulation.iterrows():
##         input_df.at[float(index),prob_str] = row[str(time)]
##     input_df.to_csv(output)

if __name__ == "__main__":
    parser=argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("sim_file",help="Simulation file",type=str)
    parser.add_argument("time", help ="Time for which probabilities need to be calculated", type=int)
    #parser.add_argument("-o", "--output", default="distance_and_probs.csv", type=str)
    #parser.add_argument("--input", default="", type=str)
    #parser.add_argument("--seed_file", default="../data/seed_files/seed_BGD_moore1.csv")
    #parser.add_argument("--grid_file", default="../obj/ca_precip1_b2_k500.pkl")

    args = parser.parse_args()

    create_file(TEMPLATE, SEED_FILE, args.sim_file, GRID_FILE, args.time)
