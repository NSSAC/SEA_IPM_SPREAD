import sys
import pdb
import copy
import time
import argparse
import logging
#from grid import grid
import pickle
from cellular_automata import Cell, CA
import read_tiff
import glob
import scipy.spatial
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

def load_object(filename):
    f = file(filename, 'r')
    u = pickle.Unpickler(f)
    o = u.load()
    f.close()
    return o

def dump_object(filename, obj) :
    f = open(filename, 'w')
    u = pickle.Pickler(f)
    u.dump(obj)
    f.close()
  
# Data paths
# AA: hard coding of file names
data_folder = '../data/'
harvest_area_file=data_folder+'crop_harvest_area.csv'

def update_data(ca):
   # read harvest area file
   ha=pd.read_csv(harvest_area_file,delimiter=',')

   for cell in ca.cells:
      cell.production={}
      cell.production['wheat']=-1
      cell.production['rice']=-1
      cell.production['maize']=-1
      cell.production['sugarcane']=-1
      cell.production['sorghum']=-1

   for index,row in ha.iterrows():
      ca.cells[int(index)].production['wheat']=row['wheat']
      ca.cells[int(index)].production['rice']=row['rice']
      ca.cells[int(index)].production['maize']=row['maize']
      ca.cells[int(index)].production['sugarcane']=row['sugarcane']
      ca.cells[int(index)].production['sorghum']=row['sorghum']

def main():
   # read in arguments
   parser=argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter)
   parser.add_argument("input_pkl",help="input pickle file")
   parser.add_argument("-o", "--output_pkl", default='ca_model.pkl',help="output pickle file")
   parser.add_argument("-v", "--verbose", action="store_true")
   args=parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.DEBUG)
   else:
      logging.basicConfig(level=logging.INFO)
   
   ca = load_object(args.input_pkl)
   update_data(ca)
   dump_object(args.output_pkl,ca)

if __name__ == "__main__":
   main()
