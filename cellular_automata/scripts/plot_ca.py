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
DATA_CELLS = [669234,656282,659166,663489,663477,659158,651965,651957]



def cumulate(csvfile):
   df = pd.read_csv(csvfile, header=0, index_col = 'cell_id')
   for item in df.values:
      for i in range(len(item)):
         prob_list = [1-item[j] for j in range(i+1)]
	 prob = 1-np.prod(prob_list)
	 item[i] = prob
   return df 

def plot_cities(csvfile, cell_size, step=None, output=None):
   SHAPEFILE = '../data/world_grid/world_grid_' + cell_size + '_degree_clipped_by_countries_adcw72.shp'
   sf = shp.Reader(SHAPEFILE)
   fig1=plt.figure(figsize=(15,15))
   plt.axis('off')
   plt.tight_layout()
   ax1=fig1.add_subplot(111)
   records = sf.records()
   values = {}
   indexCellIDMap={}
   df = pd.read_csv(csvfile, header = 0)

   for ind,cell in df.iterrows():
      if cell['is_city']==1:
         value = 2
      else:
         value = cell['city']
         if pd.isnull(value):
            value = 0
         else:
            value = 1

      indexCellIDMap[cell['cell']]=ind
      values[cell['cell']] = value 
   colors = ['#FEE8C8','#FDBB84','#E34A33']
   numColors=len(colors)
   borderColor='#AAAAAA'

   label_index = 0
   for index, shape in enumerate(sf.shapeRecords()):
      try:
         cellIndex=indexCellIDMap[records[index][1]]
      except:
         continue

      x = [i[0] for i in shape.shape.points[:]]
      y = [i[1] for i in shape.shape.points[:]]

      plt.plot(x,y,color=borderColor,linewidth=.1)

      plt.fill(x,y,alpha=1,color=colors[values[records[index][1]]])
   ## # legend
   ## height=1
   ## width=1
   ## xoffset=136
   ## yoffset=22
   ## for i in xrange(numColors):
   ##    ax1.add_patch(Rectangle((xoffset,yoffset+height*i),width,height,fc=colors[i]))
   ##    ax1.text(xoffset+width+.5,yoffset+height*.2-.5+height*i,timeSteps[i],fontsize=20)

   plt.savefig(output)
   print output


def plot_ca_heatmap(csvfile, cell_size_str, cell_size, month, country, output):
   SHAPEFILE = '../data/world_grid/world_grid_' + cell_size_str + '_degree_clipped_by_countries_adcw72.shp'
   sf = shp.Reader(SHAPEFILE)
   fig1=plt.figure(figsize=(15,15))
   plt.axis('off')
   plt.tight_layout()
   ax1=fig1.add_subplot(111)
   records = sf.records()
   ## cell_in={}
   ## cell_in[0] = list()
   ## for i in range(1,10):
   ##    cell_in[i] = list()

   

   indexCellIDMap={}
   #df = pd.read_csv(csvfile, header = 0)
   df = cumulate(csvfile)
   #print df
   
   max = 0.0
   min = 1.0
   for ind,cell in df.iterrows():
      if GRID_FILE.loc[ind]['country_iso'] in country: 
         indexCellIDMap[ind]=ind
	 if cell[str(month)] > max:
	    max = cell[str(month)]
	 elif cell[str(month)] < min:
	    min = cell[str(month)]
	 
   step = max - min 
      
   colors = ['#D7301F','#EF6548','#FC8D59','#FDBB84','#FDD49E','#FEE8C8','#FFF7EC','#CCCCCC'] 
   newColors = ['','','','','','','']
   for i in range(7):
      newColors[i] = colors[6-i]
   #colors = newColors
   numColors=len(newColors)
   borderColor='#777777'
   ## 1.0 -> step
   t_step = float(step)/float(numColors)
   timeSteps=["%.2f" %(float(i)*t_step + min) for i in xrange(numColors+1)]
   ## timeSteps[0]="1 (Jan 2016)"   
   max_x = -100
   max_y = -100
   min_x = 1000
   min_y = 1000

   label_index = 0
   for index, shape in enumerate(sf.shapeRecords()):
      try:
         cellIndex=indexCellIDMap[records[index][1]]
      except:
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

      if df.get_value(cellIndex,str(month))==0.0:
         cell_color = colors[-1]
      elif df.get_value(cellIndex,str(month))==1.0:
         cell_color = newColors[-1]
      else:
         colorBin=int(df.get_value(cellIndex,str(month))/t_step)
         cell_color = newColors[colorBin]

      plt.fill(x,y,alpha=1,color=cell_color)

      ## Special cells below

      label_list = ['a','b','c','d','e','f','g','h']
      ## Thicken border if the cell is one of our data
      if int(cellIndex) in DATA_CELLS:
         ax1.add_patch(Rectangle((x[1]+0.005,y[1]+0.005),cell_size-.01,cell_size-.01,linewidth=2,ec='black',fill=False))
         ax1.add_patch(Rectangle((x[1]+0.005,y[1]+0.005),cell_size-.01,cell_size-.01,linewidth=2,ec='black',fill=False,zorder=10))
         ax1.text(x[1]+0.02, y[1]+0.02,label_list[label_index],fontsize=35)
         label_index += 1

      # if colorBin >= numColors:
      #    colorBin = len(colors)  - 1
      #    plt.fill(x,y,alpha=1,color=colors[colorBin]) 
      if cellIndex==641889:
         plt.fill(x,y,alpha=1,color='black') 
      if cellIndex==643329: #643329,485448.0,92.125,21.625,5116.1,342.4,BD-B,Chittagong
         plt.fill(x,y,alpha=1,color='green') 
      if cellIndex==643330:
         plt.fill(x,y,alpha=1,color='blue') 

            
   ##
   width=(max_x - min_x)/53.0
   height=(max_y - min_y)/39.0
   #xoffset=100
   #yoffset=16
   xoffset = max_x-width*3
   yoffset = max_y-height*7
   for i in xrange(numColors):
      ax1.add_patch(Rectangle((xoffset,yoffset+height*i),width,height,fc=colors[i]))
      ax1.text(xoffset+1.5*width,yoffset+height*.2-0.5*height + height*i,timeSteps[i],fontsize=20)
   ax1.text(xoffset+1.5*width,yoffset+height*.2-.5*height+height*numColors,timeSteps[numColors],fontsize=20)
   print output
   plt.savefig(output)


if __name__ == "__main__" :
    parser=argparse.ArgumentParser(
     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-c", "--csv_output_file", type=str)
    parser.add_argument("-s", "--cell_size", default = .25, type = float)
    parser.add_argument("-n", "--total", default = 16, type = int)
    parser.add_argument("-p", "--prod", default = 100.0, type = float)
    parser.add_argument("-o", "--output", default = 'heatmap.png', type = str)
    parser.add_argument("--countries", nargs='+', default=COUNTRY_LIST, type=str)
    parser.add_argument("--month", default = 3, type = int)
    parser.add_argument("--cities", action='store_true' )

    args = parser.parse_args()
 
    adj_size = args.cell_size
    if adj_size == .5:
	adj_size = 'pt5'
    elif adj_size == .25:
	adj_size = 'pt25'
    else:
	adj_size = str(int(adj_size))

    start_time=time.time()	

    simulationFile = args.csv_output_file
    output = args.output

    if args.cities:
        plot_cities(simulationFile, adj_size, args.total, output)
    else:
        plot_ca_heatmap(simulationFile, adj_size, args.cell_size, args.total, args.countries, output)
    fill_data_time = time.time()
    print "plot complete. Time used: %.2f" %((fill_data_time-start_time)/60)
