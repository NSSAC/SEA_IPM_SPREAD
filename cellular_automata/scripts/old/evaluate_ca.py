import csv
import math
import pandas as pd
import argparse
import pdb
import os

DATA_FILE = "../data/pest_dist.csv" 
start_month = 1
start_year = 2016
INFINITY=10000
UNCERTAINTY_PERIOD=3.0

def evaluate(simFile,uncertaintyWindow):
   timesteps = 24
   conf_dist=1
   
   sim_output = pd.read_csv(simFile)
   ground_data = pd.read_csv(DATA_FILE)
   output_df=pd.DataFrame(columns=['adc_id','ground_truth','simulation_output'])

   # Look at min across all cells within district
   for district in ground_data['adc_id']:
      if ground_data.loc[ground_data['adc_id']==district,'year'].item()==-1:
         report_time=-1
      else:
         report_time=12*(ground_data.loc[ground_data['adc_id']==district,'year'].item()-start_year) + (ground_data.loc[ground_data['adc_id']==district,'month'].item()-start_month)
      min = INFINITY
      for row in sim_output.loc[sim_output['adc_id']==str(district),'time']:
         row = float(row)
         if row<min and row != -1:
            min = row
         if min == INFINITY or min > 22:
            min = -1
      output_df.loc[len(output_df)]=[district, report_time,min] 

   # compare
   falsePositives=0
   falseNegatives=0
   distanceWithUncertainty=0
   for index,row in output_df.iterrows():
      if row['ground_truth']==-1 and row['simulation_output']!=-1:
         falsePositives+=1
         continue
      elif row['ground_truth']!=-1 and row['simulation_output']==-1:
         falseNegatives+=1
         continue
      distanceWithUncertainty+=math.floor(abs((row['ground_truth']-row['simulation_output'])/uncertaintyWindow))
      #filename=os.path.basename(simFile).rstrip('.csv')
   print "INSERT INTO faw.results_ca (sim_output,uncertainty,distance,false_positive,false_negative) VALUES ('%s',%g,%g,%g,%g);" %(simFile,uncertaintyWindow,distanceWithUncertainty,falsePositives,falseNegatives)

if __name__ == "__main__":
    # read in arguments
    parser=argparse.ArgumentParser(
    formatter_class=argparse.RawTextHelpFormatter)
    

    parser.add_argument("input_sim_file", help="a simulation output file")
    parser.add_argument("-u","--uncertainty_window", default=UNCERTAINTY_PERIOD,type=float,help="Uncertainty window in months")
    args=parser.parse_args()

    evaluate(args.input_sim_file,args.uncertainty_window)
