import pandas as pd
import csv
import math
import shapefile as shp
import argparse
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from create_ca import load_object, dump_object
from fill_data_ca import get_cities

def plot_cities(ca, float_cell_size, city_file,vor_file, cell_size, step=None, output=None):
   SHAPEFILE = '../data/world_grid/world_grid_' + cell_size + '_degree_clipped_by_countries_adcw72.shp'
   sf = shp.Reader(SHAPEFILE)
   fig1=plt.figure(figsize=(15,15))
   plt.axis('off')
   plt.tight_layout()
   ax1=fig1.add_subplot(111)
   records = sf.records()
   df = pd.read_csv(vor_file)
   print df
   cities = get_cities(ca, float_cell_size, city_file)
   df2 = pd.DataFrame([i[0] for i in cities.values()], columns = ['cell'])
   df2 = df2.sort_values('cell')
   df = df.sort_values('cell')
   df.to_csv('test_vor.csv')
   df2.to_csv('test_cities.csv')
   max = -10
   min = 999999
   indexCellIDMap={}
   values = {}
   print 'loading values'
      ################# insert what we are plotting
   print [i[0] for i in cities.values()]
   j = 1
   for index, row in df.iterrows():
      print row['cell']
      if row['cell'] in [i[0] for i in cities.values()]:
         value = 1
	 j += 1
      else:
         value = row['city']
         if value == 'NaN':
	    value = 0
         else:
	    value = 2 
      indexCellIDMap[row['cell']]=row['cell']
      values[row['cell']] = value

   max = 10
   min = 0
   step = max - min
   print 'loaded'
   colors = ['#D7301F','#EF6548','#FC8D59','#FDBB84','#FDD49E','#FEE8C8','#FFF7EC','#CCCCCC']
   newColors = ['','','','','','','','#CCCCCC']
   for i in range(0,7):
      newColors[i] = colors[6-i]
   colors = newColors
   colors = ['#FFFFFF','#000000','#CCCCCC']
   numColors=len(colors)
   borderColor='#777777'
   t_step = step/float(numColors-1)
   timeSteps=[i*t_step+min for i in xrange(numColors)]
   #timeSteps[-1]="Not invaded"
   timeSteps[0]=min
   print 'creating plot'
   for index, shape in enumerate(sf.shapeRecords()):
      try:
         cellIndex=indexCellIDMap[records[index][1]]
      except:
	 continue
      ########################## insert what we are plotting
      #value = ca.cells[cellIndex].production['vege']
      value = values[cellIndex]
      x = [i[0] for i in shape.shape.points[:]]
      y = [i[1] for i in shape.shape.points[:]]

      plt.plot(x,y,color=borderColor,linewidth=.2)
      plt.fill(x,y,alpha=1,color=colors[value])

   # legend
   height=1
   width=1
   xoffset=119
   yoffset=22
   for i in xrange(numColors):
      ax1.add_patch(Rectangle((xoffset,yoffset+height*i),width,height,fc=colors[i]))
      ax1.text(xoffset+width+.5,yoffset+height*.2-.5+height*i,timeSteps[i],fontsize=20)

   print 'created'
   plt.savefig(output)

def plot_ca_heatmap(ca, cell_size, step=None, output=None):
   SHAPEFILE = '../data/world_grid/world_grid_' + cell_size + '_degree_clipped_by_countries_adcw72.shp'
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

   
   max = -10
   min = 999999
   indexCellIDMap={}
   values = {}
   print 'loading values'
   ## df = pd.DataFrame(columns = ['cell id', 'lon', 'lat', 'vege', 'admin_id', 'admin_name'])
   ## df2 = pd.read_csv('../data/south_east_asia_adc_id_p25xp25.csv') #, index_col = '#cell_id')
   ## 
   ## for index,cell in ca.cells.iteritems():
   ##    if len(df2.loc[df2['#cell_id']==index,'region'].tolist()) > 1:
   ##       df = df.append({'cell id': int(index), 'lon': cell.vertices[-1][0], 'lat': cell.vertices[-1][1], 'vege': cell.production['vege'], 'admin_name': df2.loc[df2['#cell_id']==index,'region'].tolist(), 'admin_id':df2.loc[df2['#cell_id']==index,'admin_name'].tolist()}, ignore_index = True)
   ##    else:
   ##       df = df.append({'cell id': int(index), 'lon': cell.vertices[-1][0], 'lat': cell.vertices[-1][1], 'vege': cell.production['vege'], 'admin_name': list(df2.loc[df2['#cell_id']==index,'region'].tolist()), 'admin_id': list(df2.loc[df2['#cell_id']==index,'admin_name'].tolist())}, ignore_index = True)
      ################# insert what we are plotting
   for index, cell in ca.cells.iteritems():   
      value = cell.population
      if value > 200000:
	 value = 200000
      if value == 0:
	 value = -1
      elif value > max:
	 max = value
      elif value < min:
	 min = value
      indexCellIDMap[index]=index
      values[index] = value
   ## df.to_csv('mapspam_data.csv', index=False) #, quoting=csv.QUOTE_NONE)
   min = 0
   step = max - min
   print 'loaded'
   colors = ['#D7301F','#EF6548','#FC8D59','#FDBB84','#FDD49E','#FEE8C8','#FFF7EC','#CCCCCC'] 
   newColors = ['','','','','','','','#CCCCCC']
   for i in range(0,7):
      newColors[i] = colors[6-i]
   colors = newColors
   numColors=len(colors)
   borderColor='#777777'
   t_step = step/float(numColors-1)
   timeSteps=[i*t_step+min for i in xrange(numColors)]
   #timeSteps[-1]="Not invaded"
   timeSteps[0]=min
   print 'creating plot'
   for index, shape in enumerate(sf.shapeRecords()):
      try:
         cellIndex=indexCellIDMap[records[index][1]]
      except:
         continue
      ########################## insert what we are plotting	
      #value = ca.cells[cellIndex].production['vege']
      value = values[cellIndex]
      x = [i[0] for i in shape.shape.points[:]]
      y = [i[1] for i in shape.shape.points[:]]
   
      plt.plot(x,y,color=borderColor,linewidth=.2)
      if value  == -1:
	 plt.fill(x,y,alpha=1,color=colors[-1])
      else:
         colorBin=int((value-min)/float(t_step))
         if colorBin >= numColors-1:
	    colorBin = len(colors)  - 2
	    print 'big'
          
         plt.fill(x,y,alpha=1,color=colors[int(colorBin)]) 
            
   # legend
   height=1
   width=1
   xoffset=119
   yoffset=22
   for i in xrange(numColors):
      ax1.add_patch(Rectangle((xoffset,yoffset+height*i),width,height,fc=colors[i]))
      ax1.text(xoffset+width+.5,yoffset+height*.2-.5+height*i,timeSteps[i],fontsize=20)
   
   print 'created'
   plt.savefig(output)


if __name__ == "__main__" :
    parser=argparse.ArgumentParser(
     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-c", "--csvfile", default = '../work/out/output_2_15_10_1.csv',type = str)
    parser.add_argument("--grid_file",help="Pickle file created by 'create_ca.py'.", default="ca_model_moore_6_filled.pkl")
    parser.add_argument("-s", "--cell_size", default = .25, type = float)
    parser.add_argument("-T", "--temp", default = 28, type = int)
    parser.add_argument("-H", "--hum", default = 60, type = int)
    parser.add_argument("-n", "--total", default = 24, type = int)
    parser.add_argument("-M", "--moore", default = 1, type = int)
    parser.add_argument("-i", "--ndvi", default = 12, type = int)
    parser.add_argument("-p", "--prod", default = 100.0, type = float)
    parser.add_argument("-o", "--output", default = 'data_heatmap.png', type = str)
    parser.add_argument("--cities", action='store_true' )
    parser.add_argument("--city_file", default = '../../data/cities.csv', type = str )
    parser.add_argument("--vor_file", default = 'voronoi_output.csv' )
    args = parser.parse_args()


    adj_size = args.cell_size
    if adj_size == .5:
        adj_size = 'pt5'
    elif adj_size == .25:
        adj_size = 'pt25'
    else:
        adj_size = str(int(adj_size))

    print 'loading ca'
    ca = load_object(args.grid_file)
    print 'loaded'

    if args.cities:
	plot_cities(ca, args.cell_size, args.city_file, args.vor_file, adj_size, args.total, args.output) 
    else:
        output = args.output
        plot_ca_heatmap(ca, adj_size, args.total, output)
        print output
