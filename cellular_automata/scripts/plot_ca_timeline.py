import pandas as pd
import pdb
#import matplotlib
#matplotlib.use('Agg')
import time
import numpy as np
import math
import shapefile as shp
import argparse
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

GRID_FILE = pd.read_csv("../data/south_east_asia_adc_id_p25xp25.csv", index_col = 'cell_id')
COUNTRY_LIST = ['BG','CB','ID','LA','MY','BM','NP','RP','SG','TH','VM']
DATA_CELLS = {\
669234:'a',\
663477:'b',\
659158:'c',\
656282:'d',\
651957:'e',\
651965:'f',\
659166:'g',\
663489:'h'}


def timeOfInf(csvfile,country,threshold,shift):   # gives time of infection based on threshold
   df = pd.read_csv(csvfile, header=0, index_col = 'cell_id')
   timeInf={}
   for index,row in df.iterrows():
      if GRID_FILE.loc[index]['country_iso'] in country:
         timeInf[index]=-1
         sumProb=0
         for i in range(len(row)):
            sumProb+=row[i]
            if sumProb>=threshold:
               timeInf[index]=i-shift
               if timeInf[index]<0:
                  timeInf[index]=0
               break
   
   return timeInf

def plot_ca_timeline(csvfile, countries, cell_size_str, cell_size, timeStepsToConsider, threshold, output,shift):
   SHAPEFILE = '../data/world_grid/world_grid_' + cell_size_str + '_degree_clipped_by_countries_adcw72.shp'
   sf = shp.Reader(SHAPEFILE)
   fig1=plt.figure(figsize=(15,15))
   plt.axis('off')
   plt.tight_layout()
   ax1=fig1.add_subplot(111)
   records = sf.records()
   indexCellIDMap={}

   cellInfTime = timeOfInf(csvfile,countries,threshold,shift)
   timeMax=max(cellInfTime.values())
   timeMin=min(cellInfTime.values())
   totalTimeSteps = timeMax - timeMin
   shift = timeMin
   if timeStepsToConsider==-1:
      timeStepsToConsider=totalTimeSteps
   timeStepsToConsider-=shift
   
   colors = ['#D7301F','#EF6548','#FC8D59','#FDBB84','#FDD49E','#FEE8C8']#,'#FFF7EC'] 
   borderColor='#777777'

   ## 1.0 -> step
   binSize = timeStepsToConsider/float(len(colors))
   print timeStepsToConsider
   max_x = -100
   max_y = -100
   min_x = 1000
   min_y = 1000

   label_index = 0
   for index, shape in enumerate(sf.shapeRecords()):
      try:
         infTime=cellInfTime[records[index][1]]
      except KeyError:
         continue

      x = [i[0] for i in shape.shape.points[:]]
      y = [i[1] for i in shape.shape.points[:]]

      if x[0] > max_x:
         max_x = x[0]
      elif x[1] < min_x:
         min_x = x[1]
      if y[0] > max_y:
         max_y = y[0]
      elif y[1] < min_y:
         min_y = y[1]
      
      plt.plot(x,y,color=borderColor,linewidth=.2)

      if infTime!=-1 and infTime<timeStepsToConsider:
         plt.fill(x,y,alpha=1,color=colors[int(infTime/binSize)])

      if int(records[index][1]) in DATA_CELLS.keys():
         ax1.add_patch(Rectangle((x[1]+0.005,y[1]+0.005),cell_size-.01,cell_size-.01,linewidth=2,ec='black',fill=False,zorder=10))
         ax1.text(x[1]+0.02, y[1]+0.02,DATA_CELLS[int(records[index][1])],fontsize=35)
         label_index += 1
   ##
   height=4*(max_y - min_y)/45.0
   width=4*(max_x - min_x)/52.0
   #xoffset=80
   #yoffset=-12
   xoffset = max_x - 13.4*width 
   yoffset = max_y - 11.5*height
   for i in xrange(len(colors)):
      if countries == ['BG']:
         ax1.add_patch(Rectangle((xoffset+0.3*width+0.1,yoffset+height*i-0.4),0.8*width,height,fc=colors[i]))
         ax1.text(xoffset+1.3*width+0.1,yoffset-.1*height+height*i-0.4,"%.0f" %(i*binSize),fontsize=40)
	 ax1.text(xoffset+1.3*width+0.1,yoffset-.1*height+height*len(colors)-0.4, "%g" %(len(colors)*binSize),fontsize=40)
      else:
         ax1.add_patch(Rectangle((xoffset,yoffset+height*i),width,height,fc=colors[i]))
         ax1.text(xoffset+1.1*width,yoffset-.1*height+height*i,"%.0f" %(i*binSize),fontsize=40)
         ax1.text(xoffset+1.1*width,yoffset-.1*height+height*len(colors), "%g" %(len(colors)*binSize),fontsize=40)
   ax1.axis('off')
   print output
   plt.savefig(output)

if __name__ == "__main__" :
    parser=argparse.ArgumentParser(
     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("simulation_file", type=str)
    parser.add_argument("-c", "--cell_size", default = .25, type = float)
    parser.add_argument("-n", "--time_steps", default = -1, type = int)
    parser.add_argument("-t", "--threshold", default = .25, type = float)
    parser.add_argument("-s", "--shift", default = 0, type = int)
    parser.add_argument("-o", "--output", default = 'timeline.png', type = str)
    parser.add_argument("--countries", nargs='+', default=COUNTRY_LIST, type=str)

    args = parser.parse_args()
 
    adj_size = args.cell_size
    if adj_size == .5:
	adj_size = 'pt5'
    elif adj_size == .25:
	adj_size = 'pt25'
    else:
	adj_size = str(int(adj_size))

    start_time=time.time()	

    plot_ca_timeline(args.simulation_file, args.countries, adj_size, args.cell_size, args.time_steps, args.threshold,args.output,args.shift)
    fill_data_time = time.time()
    print "plot complete. Time used: %.2f" %((fill_data_time-start_time)/60)
