# tags: basemap geopy
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import numpy as np
import pdb
import pandas as pd
import argparse
import logging
from math import ceil, floor
from country_attributes import countryAttribs
from matplotlib import colors
import subprocess

GRID_FILE = pd.read_csv("../obj/ca_mapspam_pop.csv", index_col = 'cell id')
CITIES_FILE=pd.read_csv("../obj/cities/cities_250000.csv")
REPORTS = {\
669234:('Panchagarh dist.',26.19,88.43,0),\
663477:('Gazipur dist.',23.99,90.42,7),\
659158:('Moulvibazar dist.',24.25,91.45,8),\
656282:('Jaintiapur',25.07,92.09,8),\
651957:('Gaibandha dist.',25.15,89.23,9),\
651965:('Bogra dist.',24.48,89.25,8),\
659166:('Barura',23.22,91.06,9),\
663489:('Jessore',23.09,89.10,9)}

# lat, lon, width, height, marker size (coordinates for centroid)
MAP={\
      'BD':(23.68,90.35,500000,655000,7),\
      'PH':(12,122,1050000,1500000,7),\
      'VN':(16.06,106,900000,1620000,7),\
      'TH':(13,101.5,850000,1600000,7),\
      'MSA':(9.71,106,3000000,3700000,3)\
    }
DELTA=0.25
INFINITY=10000
NUM_COLORS=6
#COLORS=['#FFFFCC','#C7E9B4','#7FCDBB','#41B6C4','#2C7FB8','#253494']
COLORS=['#FEE0D2','#FC9272','#DE2D26'] # color brewer 3-class Reds

# determine markersize based on weight constraints and linear function
def markerSizeLinear(weight,maxWeight,maxSize):
   return ceil(weight/(maxWeight+.0)*maxSize)

def initiateMap(coord):
   m = Basemap(resolution='i', \
      projection='lcc', \
      width=coord[2], \
      height=coord[3], \
      area_thresh=1000., \
      lat_0=coord[0], \
      lon_0=coord[1])
   m.drawcoastlines(linewidth=.4,color='#333333')
   # draw a boundary around the map, fill the background.
   # this background will end up being the ocean color, since
   # the continents will be drawn on top.
   m.drawmapboundary(fill_color='white',linewidth=.0)
   # fill continents, set lake color same as ocean color.
   # m.fillcontinents(color='#f2efe0')
   m.drawcountries(linewidth=.4,color='#333333')
   # m.drawstates(linewidth=.1,color='#666666')
   return m

def cellTimeOfInf(df,probs,threshold,shift):   # gives time of infection for a cell based on threshold
   timeInfCell=-1
   sumProb=0
   for i in range(len(probs)):
      sumProb+=probs[i]
      if sumProb>=threshold:
         timeInfCell=i-shift
         if timeInfCell<0:
            timeInfCell=0
         break
   return timeInfCell

def timeOfInf(simFile,country,threshold,shift):   # gives time of infection for cells in the specified region
   df = pd.read_csv(simFile, header=0, index_col = 'cell_id')
   timeInf={}
   for index,row in df.iterrows():
      if country=='MSA':  # consider all cells
         timeInf[index]=cellTimeOfInf(df,row,threshold,shift)
      try:
         if GRID_FILE.loc[index]['admin_id'][0:2] == country:
            timeInf[index]=cellTimeOfInf(df,row,threshold,shift)
      except KeyError:
         continue
   
   return timeInf

if __name__=="__main__":
   # read in arguments
   parser=argparse.ArgumentParser(
     formatter_class=argparse.RawTextHelpFormatter)

   parser.add_argument("simulation_file", type=str)
   parser.add_argument("-p", "--output_prefix", default="out")
   parser.add_argument("-t", "--threshold", default = .25, type = float,help="Those cells with probability>=t will be considered infected.")
   parser.add_argument("-s", "--shift", default = 0, type = int)
   parser.add_argument("-n", "--time_steps", default = -1, type = int)
   parser.add_argument("--include_country_names", action="store_true", help="Include country names in the map")
   parser.add_argument("country")

   args=parser.parse_args()

   # generate blank map
   logging.info("Initiate map ...")
   m=initiateMap(MAP[args.country]);

   # generate infection times based on threshold
   logging.info("Compute infection times ...")
   cellInfTime = timeOfInf(args.simulation_file,args.country,args.threshold,args.shift)

   # prepare grid
   lon=[]
   lat=[]
   for cell in cellInfTime.keys():
      try:
         lon.append(GRID_FILE.loc[cell]['lon'])
         lat.append(GRID_FILE.loc[cell]['lat'])
      except KeyError:
         continue

   minLon=min(lon)-DELTA/2.0
   maxLon=max(lon)+DELTA/2.0
   minLat=min(lat)-DELTA/2.0
   maxLat=max(lat)+DELTA/2.0
   X=np.arange(minLon,maxLon+DELTA,DELTA)
   Y=np.arange(minLat,maxLat+DELTA,DELTA)
   XMesh,YMesh=np.meshgrid(X,Y)

   ax=plt.gca()
   ax.set_facecolor(COLORS[0])

   # legend
   ### city/reports 
   m.plot(.98,.98, color='black', marker='o',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
   plt.text(.96,.97,'Localities',transform=ax.transAxes,horizontalalignment='right')
   ### monitored locations (only for Bangladesh)
   if args.country=='BD':
      m.plot(.98,.94, color='white', marker='^',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
      plt.text(.96,.93,'Monitored locns.',transform=ax.transAxes,horizontalalignment='right')
   ### states
   m.plot(.98,.90, color=COLORS[0], marker='s',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
   plt.text(.96,.89,'Free',transform=ax.transAxes,horizontalalignment='right')
   ###
   m.plot(.98,.86, color=COLORS[1], marker='s',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
   plt.text(.96,.85,'Infested',transform=ax.transAxes,horizontalalignment='right')
   ###
   m.plot(.98,.82, color=COLORS[2], marker='s',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
   plt.text(.96,.81,'Infested at current step',transform=ax.transAxes,horizontalalignment='right')
   

   # plot country names
   if args.include_country_names:
      for name in ['BGD','MMR','THA','LAO','KHM','VNM','MYS','SGP','IDN','BRN','PHL']:
         x,y=m(countryAttribs[name][2],countryAttribs[name][1])
         if x>m.xmax or x<m.xmin or y>m.ymax or y<m.ymin:
            continue
         plt.text(x,y,name)

   # plotting city locations
   for index,loc in CITIES_FILE.iterrows():
      x,y=m(loc['ln'],loc['lt'])
      if x>m.xmax or x<m.xmin or y>m.ymax or y<m.ymin:
         continue
      m.plot(x,y, color='black', marker='o',markersize=MAP[args.country][4],markeredgecolor='white',markeredgewidth=.5,alpha=1)

   # set title
   ax.set_title(args.output_prefix)

   # plotting incidence reports
   ### monitored locations (only for Bangladesh)
   if args.country=='BD':
      for ele in REPORTS.values():
         x,y=m(ele[2],ele[1])
         timeStep=ele[3]
         if x>m.xmax or x<m.xmin or y>m.ymax or y<m.ymin:
            continue
         m.plot(x,y, color='white', marker='^',markersize=8,markeredgecolor='black',markeredgewidth=.8,alpha=1)
         x,y=m(ele[2]+.2,ele[1]-.1)
         plt.text(x,y,ele[0][:5],horizontalalignment='left')

   # Generate snapshots
   Z=np.full((len(Y),len(X)),INFINITY)
   for cell in cellInfTime.keys():
      try:
         if cellInfTime[cell]==-1:
            timeInf=INFINITY
         else:
            timeInf=cellInfTime[cell]
         lonRef=int((GRID_FILE.loc[cell]['lon']-minLon+DELTA/2.0)/DELTA)
         latRef=int((GRID_FILE.loc[cell]['lat']-minLat+DELTA/2.0)/DELTA)
         Z[latRef-1][lonRef]=min(Z[latRef-1][lonRef],timeInf)
         Z[latRef][lonRef-1]=min(Z[latRef][lonRef-1],timeInf)
         Z[latRef-1][lonRef-1]=min(Z[latRef-1][lonRef-1],timeInf)
         Z[latRef][lonRef]=min(Z[latRef][lonRef],timeInf)
      except KeyError:
         continue

   C=np.copy(Z)

   for T in xrange(args.time_steps):
      C[np.where(Z>T)]=0
      C[np.where(Z<T)]=1
      C[np.where(Z==T)]=2
      cMap = colors.ListedColormap(COLORS[:np.unique(C).size])
      mesh=m.pcolormesh(XMesh,YMesh,C,cmap=cMap,latlon=True)

      # plotting title and time
      timeText=plt.text(0,0,'Time=%d' %T,horizontalalignment='left',fontsize=18,transform=ax.transAxes)
      timeText=plt.text(0,.06,'Month=%d' %((T+args.shift-1)%12+1),horizontalalignment='left',fontsize=18,transform=ax.transAxes)

      plt.savefig(args.output_prefix+"_%.2d.png" %T,bbox_inches='tight')

      # flushes time
      timeText.remove()
   
   # convert to movie
   ### below one  works with mplayer, not with default mac OS players
   #subprocess.check_output(['ffmpeg','-y','-framerate','1','-pix_fmt','yuv420p','-i',args.output_prefix+'_%02d.png',args.output_prefix+'.mp4'])
   subprocess.check_output(['convert','-density','500','-delay','100',args.output_prefix+'*.png',args.output_prefix+'.mpeg'])
