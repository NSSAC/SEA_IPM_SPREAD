#
import netCDF4
import pdb
import numpy as np
import pandas as pd
import math

# bounding box
MIN_LAT=-13
MAX_LAT=30
MIN_LON=89
MAX_LON=145

def findNearestLatLon(lat,lon,sortedLatArray,sortedLatLonArray):
   indLat=np.searchsorted(sortedLatArray,lat,side="left")
   if indLat > 0 and (indLat == len(sortedLatArray) or math.fabs(lat - sortedLatArray[indLat-1]) < math.fabs(lat - sortedLatArray[indLat])):
      indLat-=1
   lat=sortedLatArray[indLat]
   indLon=np.searchsorted(sortedLatLonArray[lat],lon,side="left")
   if indLon > 0 and (indLon == len(sortedLatLonArray[lat]) or math.fabs(lon - sortedLatLonArray[lat][indLon-1]) < math.fabs(lon - sortedLatLonArray[lat][indLon])):
      indLon-=1
   return sortedLatArray[indLat],sortedLatLonArray[lat][indLon]

## x=netCDF4.Dataset("../data/precip.mon.ltm.nc",'r')
x=netCDF4.Dataset("../../data/precip.mon.ltm.v7.1981-2010.nc",'r')

# read mapspam obj file for cell to lat,lon mapping
spam=pd.read_csv("../../cellular_automata/obj/ca_mapspam_pop.csv",index_col=['lat','lon'])

# obtain dict of precipitation
precipitation={}
for latInd in xrange(len(x.variables['lat'][:])):
   lat=x.variables['lat'][latInd]
   if lat>MAX_LAT or lat<MIN_LAT:
      continue
   for lonInd in xrange(len(x.variables['lon'][:])):
      lon=x.variables['lon'][lonInd]
      if lon>MAX_LON or lon<MIN_LON:
         continue

      prec=""
      maskInd=False

      for t in xrange(12):
         if np.ma.is_masked(x.variables['precip'][t][latInd][lonInd]):
            maskInd=True
            break
         prec=prec+',%.2f' %(x.variables['precip'][t][latInd][lonInd]) # it is given as mm/day.
      if not maskInd:
         precipitation[(lat,lon)]=prec

# created sorted arrays of lat and lon
latlonSep=zip(*precipitation.keys())
sortedLatArray=np.unique(np.array(latlonSep[0]))
sortedLatLonArray={}
for lat in sortedLatArray:
   lonList=[]
   for ele in precipitation.keys():
      if lat==ele[0]:
         lonList.append(ele[1])
   sortedLatLonArray[lat]=np.unique(np.array(lonList))

with open('precipitation_gpcc.csv','w') as f:
   f.write("cell_id,lat,lon,plat,plon,1,2,3,4,5,6,7,8,9,10,11,12\n")
   for spamLatLon in spam.index.values.tolist():
      [lat,lon]=findNearestLatLon(spamLatLon[0],spamLatLon[1],sortedLatArray,sortedLatLonArray)
      try:
         if abs(lat-spamLatLon[0])>2 or abs(lon-spamLatLon[1])>2:
            print "Warning: %d: lat,lon error exceeds 2." %spam.loc[spamLatLon]['cell id']
         f.write("%d,%g,%g,%g,%g%s\n" %(\
               spam.loc[spamLatLon]['cell id'],\
               spamLatLon[0],\
               spamLatLon[1],\
               lat,\
               lon,\
               precipitation[(lat,lon)]))
      except:

         pdb.set_trace()


      ## if not maskInd:
      ##    for slat in [-.125,.125]:
      ##       for slon in [-.125,.125]:
      ##          try:
      ##             cellNum=spam.loc[lat+slat,lon+slon]['cell id']
      ##             f.write('%d,%g,%g,%s\n' %(cellNum,lat+.125, \
      ##                   lon+.125,prec.rstrip(',')))
      ##          except:
      ##             pdb.set_trace()

## # do x.variables for all variables
##    ## f.write("#https://www.esrl.noaa.gov/psd/data/gridded/data.cmap.html\n")
##    ## f.write("#ftp://ftp.cdc.noaa.gov/Datasets/cmap/enh/precip.mon.ltm.nc\n")
##    ## f.write("#ftp://ftp.cdc.noaa.gov/Datasets/gpcc/full_v7/precip.mon.ltm.v7.1981-2010.nc\n")
##    cellNum=[0]*4  # 4 cells corresponding to one pair of (lat,lon)
