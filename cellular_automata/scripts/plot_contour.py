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
COLORS=['#FFFFCC','#C7E9B4','#7FCDBB','#41B6C4','#2C7FB8','#253494']
COLORS.reverse()

# determine markersize based on weight constraints and linear function
def markerSizeLinear(weight,maxWeight,maxSize):
   return ceil(weight/(maxWeight+.0)*maxSize)

# Initiate empty map of North America
# Downloaded state shapfiles from
# https://github.com/matplotlib/basemap/tree/master/examples
def initiateMap(coord):
   # from https://matplotlib.org/basemap/users/geography.html
   # see https://matplotlib.org/basemap/api/basemap_api.html for options
   # setup Lambert Conformal basemap.
   m = Basemap(resolution='i', \
      projection='lcc', \
      width=coord[2], \
      height=coord[3], \
      area_thresh=1000., \
      lat_0=coord[0], \
      lon_0=coord[1])
   # again see https://matplotlib.org/basemap/api/basemap_api.html for
   # readshapefile options
   # m.readshapefile(SHAPEFILE,"usgs",drawbounds=True)
   # draw coastlines.
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

   ## inputFormat="""csv file with header
   ## <,name,lat (optional),lon (optional),weight (optional),color (optional),>
   ## <name> should be location name decipherable by geopy if <lat,lon> are not provided."""
   ## parser.add_argument("locations_file",help=inputFormat)
   parser.add_argument("simulation_file", type=str)
   parser.add_argument("-o", "--output", default="out.pdf",help="plot on map")
   parser.add_argument("-t", "--threshold", default = .25, type = float)
   parser.add_argument("-s", "--shift", default = 0, type = int)
   parser.add_argument("-n", "--time_steps", default = -1, type = int)
   parser.add_argument("country")

   args=parser.parse_args()

   ## # set logger
   ## if args.verbose:
   ##    logging.basicConfig(level=logging.DEBUG)
   ## else:
   ##    logging.basicConfig(level=logging.INFO)

   # generate blank map
   logging.info("Initiate map ...")
   m=initiateMap(MAP[args.country]);
   logging.info("Compute infection times ...")
   cellInfTime = timeOfInf(args.simulation_file,args.country,args.threshold,args.shift)

   lon=[]
   lat=[]
   for cell in cellInfTime.keys():
      try:
         lon.append(GRID_FILE.loc[cell]['lon'])
         lat.append(GRID_FILE.loc[cell]['lat'])
      except KeyError:
         continue

   # prepare grid
   minLon=min(lon)-DELTA/2.0
   maxLon=max(lon)+DELTA/2.0
   minLat=min(lat)-DELTA/2.0
   maxLat=max(lat)+DELTA/2.0
   X=np.arange(minLon,maxLon+DELTA,DELTA)
   Y=np.arange(minLat,maxLat+DELTA,DELTA)
   XMesh,YMesh=np.meshgrid(X,Y)

   # prepare contour matrix
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

   stepSize=int(floor((args.time_steps+1)/NUM_COLORS))
   timeSteps=[i for i in xrange(0,args.time_steps+stepSize,stepSize)]
   CL=m.contourf(XMesh,YMesh,Z,levels=timeSteps,latlon=True,colors=COLORS)

   # plot city names
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
      ## x,y=m(loc['ln']+.1,loc['lt']-.1)
      ## plt.text(x,y,loc['name'])

   # plotting incidence reports
   ### monitored locations (only for Bangladesh)
   if args.country=='BD':
      for ele in REPORTS.values():
         x,y=m(ele[2],ele[1])
         timeStep=ele[3]
         if x>m.xmax or x<m.xmin or y>m.ymax or y<m.ymin:
            continue
         m.plot(x,y, color=COLORS[int(timeStep/stepSize)], marker='s',markersize=8,markeredgecolor='black',markeredgewidth=.8,alpha=1)
         x,y=m(ele[2]+.1,ele[1]-.1)
         plt.text(x,y,ele[0],horizontalalignment='left')

   # legend
   ### city/reports 
   ax=plt.gca()
   ## legX=91.5
   ## legY=26.4
   ## x,y=m(legX,legY)
   m.plot(.98,.98, color='black', marker='o',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
   ## x,y=m(legX+.1,legY-.07)
   plt.text(.96,.97,'Localities',transform=ax.transAxes,horizontalalignment='right')
   ### monitored locations (only for Bangladesh)
   if args.country=='BD':
      ## legX=91.5
      ## legY=26.1
      ## x,y=m(legX,legY)
      m.plot(.98,.94, color='white', marker='s',markersize=7,markeredgecolor='black',markeredgewidth=.5,alpha=1,transform=ax.transAxes)
      #x,y=m(legX+.1,legY-.07)
      plt.text(.96,.93,'Monitored locns.',transform=ax.transAxes,horizontalalignment='right')

   # colorbar options for basemap: https://matplotlib.org/basemap/api/basemap_api.html
   cb=m.colorbar(CL,location='bottom',size="2%",pad="-3%")
   cb.set_label('Month')
   # stuff that did not work
   ## ax=plt.axes((1,1,1,1))
   ## plt.colorbar(CL,shrink=.25,orientation='horizontal',ax=ax)

   plt.savefig(args.output,bbox_inches='tight')
