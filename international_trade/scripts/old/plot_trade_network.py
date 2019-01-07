from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import pdb
import pandas as pd
import argparse
import logging
from math import ceil
from math import log
from math import log10
import numpy as np
import seaborn as sns
import geo_coordinates # for deciphering lat,lon for locations
import matplotlib.cm as cmx
import matplotlib as mpl
import matplotlib.colors as colors
sns.set()

MARKER_COLOR="#ff0000"
PARTNER_MARKER_COLOR="#31a354"
MARKER_BORDER_COLOR="#000000"
MARKER_BORDER_WIDTH=.3
DATA_FOLDER='../../data/'

study_countries=['Cambodia', 'Thailand', 'Myanmar', 'Viet Nam',
                "Lao People's  Democratic Republic", 'Indonesia',
                'Malaysia', 'Philippines', 'Singapore', 'China mainland']

# determine markersize based on weight constraints and linear function
def markerSizeLinear(weight,maxWeight,maxSize):
   return ceil(weight/(maxWeight+.0)*maxSize)

# Initiate empty map of North America
def initiateMap():
   # from https://matplotlib.org/basemap/users/geography.html
   # see https://matplotlib.org/basemap/api/basemap_api.html for options
   # setup Lambert Conformal basemap.
   #m = Basemap(width=40000000,height=20000000,projection='lcc',
   #        resolution='c',lat_0=22,lon_0=104)
   m = Basemap(projection='robin', resolution = 'l', area_thresh = 1000.0,
                 lat_0=0, lon_0=110)
   # again see https://matplotlib.org/basemap/api/basemap_api.html for
   # readshapefile options
   # m.readshapefile(SHAPEFILE,"usgs",drawbounds=True)
   # draw coastlines.
   m.drawcoastlines(linewidth=.4,color='#333333')
   # draw a boundary around the map, fill the background.
   # this background will end up being the ocean color, since
   # the continents will be drawn on top.
   m.drawmapboundary(fill_color='#b5d0d0',linewidth=.4)
   # fill continents, set lake color same as ocean color.
   m.fillcontinents(color='#f2efe0')
   m.drawcountries(linewidth=.2,color='#666666')
   m.drawstates(linewidth=.1,color='#666666')
   return m

def plot_network(threshold=10,obs_country=None, loc_file=DATA_FOLDER+'country_locations.csv',
      network_file=DATA_FOLDER+'trade_network/2013_southeast_aisa_trade_network.csv'):
    fig = plt.figure(figsize=(20,14))
    ax  = fig.add_axes([0.1, 0.1, 0.7, 0.85])
    axc = fig.add_axes([0.85, 0.30, 0.02, 0.5])
    ax.axis('off')

    #m = Basemap(projection='cyl', resolution = 'l',
    #     lat_0=0, lon_0=140,ax=ax)
    m = Basemap(projection='cyl', ax=ax)
    # again see https://matplotlib.org/basemap/api/basemap_api.html for
    # readshapefile options
    # m.readshapefile(SHAPEFILE,"usgs",drawbounds=True)
    # draw coastlines.
    m.drawcoastlines(linewidth=.4,color='#333333')
    # draw a boundary around the map, fill the background.
    # this background will end up being the ocean color, since
    # the continents will be drawn on top.
    m.drawmapboundary(fill_color='#b5d0d0',linewidth=.4)
    # fill continents, set lake color same as ocean color.
    m.fillcontinents(color='#f2efe0')
    m.drawcountries(linewidth=.2,color='#666666')
    m.drawstates(linewidth=.1,color='#666666')
 

    loc_df = pd.read_csv(loc_file)
    network_df = pd.read_csv(network_file)
    loc_dict = dict()
    for index,row in loc_df.iterrows():
        loc_dict[row['country']] = [float(row['lon']),float(row['lat'])]
    
    max_weight = float(max(network_df['amount']))
    cmap = plt.cm.jet
    cNorm  = colors.Normalize(vmin=threshold, vmax=max_weight)
    logNorm = colors.LogNorm(vmin=threshold, vmax=max_weight)
    scalarMap = cmx.ScalarMappable(norm=cNorm,cmap=cmap)

    #plot network
    for index,row in network_df.iterrows():
       ex = row['source']
       im = row['destination']
       weight = float(row['amount'])
       if obs_country != None:
           if ex != obs_country and im !=obs_country:
               continue
       ex_loc = loc_dict[ex]
       im_loc = loc_dict[im]
       if weight>threshold:
           x1,y1 = m(ex_loc[0],ex_loc[1])
           x2,y2 = m(im_loc[0],im_loc[1])
           colorVal = scalarMap.to_rgba(weight)
           ax.arrow(x1,y1,x2-x1,y2-y1,head_width=1,
                     #length_includes_head=True,
                     color=colorVal,
                     head_length=1.5, lw=1)
           ax.text(np.median([x1,x2]), np.median([y1, y2]), str(weight),
                    fontsize=1)
     
    #plot countries
    for country in loc_dict:
        lon = loc_dict[country][0]
        lat = loc_dict[country][1]
        x,y = m(lon,lat)
        if country in study_countries:
            marker_color = MARKER_COLOR
        else :
            marker_color = PARTNER_MARKER_COLOR
        m.plot(x,y,marker='o',markersize=3,color=marker_color,
              markeredgewidth=MARKER_BORDER_WIDTH, alpha=0.5)
        ax.text(x+0.08, y-0.04, country, color = 'k', fontsize=2)
    cb1 = mpl.colorbar.ColorbarBase(axc,
          cmap=cmap,norm=logNorm,orientation='vertical',label='Trade volume (tons)')

   

if __name__=="__main__":
   # read in arguments
   parser=argparse.ArgumentParser(
     formatter_class=argparse.RawTextHelpFormatter)

   parser.add_argument("-o", "--output", default="southeast_asia_trade_network.pdf",help="plot on map")
   parser.add_argument("-t", "--threshold", default='10', help="threshold trade volume")
   parser.add_argument("-c", "--country", default=None)
   parser.add_argument("-v", "--verbose", action="store_true")

   args=parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.DEBUG)
   else:
      logging.basicConfig(level=logging.INFO)

   # generate blank map
   logging.info("Initiate map ...")
   plot_network(float(args.threshold), obs_country=args.country)

   plt.savefig(args.output)

