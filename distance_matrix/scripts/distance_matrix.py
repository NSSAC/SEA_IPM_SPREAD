#!/usr/bin/env python
# compute distances between locations in a list
# tags: code python distanceMatrix google googlemaps api distanceAPI except
# exception zip unzip

import argparse
import csv
import googlemaps
import pdb
import logging
import sys
import datetime
from math import ceil

KEY='AIzaSyBz5ut6cVwL-xNGGI0CfeopRRyVGpNtlQA'
MAX_DESTINATIONS=25
now=datetime.datetime.now()
MAX_GOOGLE_REQUESTS=2500

TIME_DISTANCE_FILE='time_distance.csv'
ADDRESS_MAP_FILE='address_map.csv'
FAILED_PAIRS_FILE='failed_pairs.csv'
GOOGLE_REQUESTS_FILE='%s_num_google_requests.txt' %now.strftime("%y%m%d")

DESC="""Computes distances between locations specified as a list. It
accounts for restrictions from google as much as possible. The code allows
user to specify the list of pairs for which distance/time has already been
computed previously. This way, the code will skip those pairs while
querying google maps. Depending on the size of the list, over multiple
days, the distances can be computed for all pairs.

Outputs:
   distance/time: (CSV) "locn 1","locn 2",time,distance
   location-google location map: (CSV) locn,google locn
   failed pairs

--------------------------------------------------------------------------
Useful information on google API:
https://developers.google.com/maps/documentation/distance-matrix
Python client:
https://github.com/googlemaps/google-maps-services-python

Restrictions from google:
   2,500 free elements per day, calculated as the sum of client-side and
   server-side queries.
   Maximum of 25 origins or 25 destinations per request.
   100 elements per request.
   100 elements per second, calculated as the sum of client-side and
   server-side queries.
--------------------------------------------------------------------------
"""

def dump_object(filename, obj) :
    f = open(filename, 'w')
    u = pickle.Pickler(f)
    u.dump(obj)
    f.close()

def pairwiseTimeDistance(locations,excludedPairs,excludedLocations):

   # get today's quota
   try:
      with open(GOOGLE_REQUESTS_FILE,'r') as f:
         requestQuota=int(f.read())
   except IOError:
      logging.info("Assuming file not available. Creating %s ..." %GOOGLE_REQUESTS_FILE)
      requestQuota=MAX_GOOGLE_REQUESTS
   except:
      logging.error("Error trying to get quota.")
      sys.exit(1)
   logging.info("Number of requests remaining today: %d" %(requestQuota))


   # Initialize
   odPairs=[]
   timeDistanceMatrix=[]
   addressMap={}
   failedPairs=[]
   failedLocns=set(locations)

   # get o-d pairs
   numLocns=len(locations)
   for i in xrange(numLocns-1):
      for j in xrange(i+1,numLocns):
         odPairs.append((locations[i],locations[j]))

   for pair in odPairs:
      if requestQuota==0:
         logging.warning("Quota for today exceeded.")
         break

      origin=pair[0]
      destination=pair[1]

      if origin==destination:
         continue
      elif pair in excludedPairs:
         logging.info("(\"%s\",\"%s\") excluded." %pair)
         failedLocns.discard(pair[0])
         failedLocns.discard(pair[1])
         continue
      
      try:
         googleOut=gmaps.distance_matrix([origin],[destination])
      except Exception as err:
         logging.exception(err)
         logging.warning("Premature termination. See error above. Mostly timeout. Proceeding to write whatever was computed ...")
         break

      if not googleOut or googleOut['status'] != 'OK' or \
         googleOut['rows'][0]['elements'][0]['status'] != 'OK':
         logging.warning("(\"%s\",\"%s\") failed." %pair)
         failedPairs.append(pair)
         with open(GOOGLE_REQUESTS_FILE,'w') as f:
            requestQuota-=1
            f.write("%d" %requestQuota)
      else:
         logging.info("(\"%s\",\"%s\") success." %pair)
         with open(GOOGLE_REQUESTS_FILE,'w') as f:
            requestQuota-=1
            f.write("%d" %requestQuota)
         failedLocns.discard(pair[0])
         failedLocns.discard(pair[1])

         # extract distance and time
         timeDistanceMatrix.append((origin,destination,\
               googleOut['rows'][0]['elements'][0]['duration']['value']/60, \
               googleOut['rows'][0]['elements'][0]['distance']['value']/1000))

         # address map update
         addressMap[googleOut['origin_addresses'][0]]=origin
         addressMap[googleOut['destination_addresses'][0]]=destination

   for k in excludedLocations.keys():
      try:
         del addressMap[k]
      except KeyError as err:
         logging.warning("addressMap: could not delete {0}; ignored ...".format(err))

   return timeDistanceMatrix, addressMap, failedPairs, failedLocns

if __name__=='__main__':
   # parser
   parser = argparse.ArgumentParser(description=DESC,formatter_class=argparse.RawTextHelpFormatter)
   parser.add_argument("locations", action="store",help="one location per line")
   parser.add_argument("-o","--time_distance_file", action="store",default=TIME_DISTANCE_FILE,help="(CSV) origin,destination,time,distance")
   parser.add_argument("-m","--address_map", action="store",default=ADDRESS_MAP_FILE,help="(CSV) locn,google locn")
   parser.add_argument("-u","--update_mode",action="store_true",help=\
"""In this mode:
- The time_distance_file (-o option or default) will be read. 
- The address_map file (-m option or default) will be read. 
- All pairs of this file will be ignored.
- New pairs will be appended to it.""")
   parser.add_argument("-f","--failed_requests", action="store",default=FAILED_PAIRS_FILE,help="(CSV) locn,google locn")
   parser.add_argument("-v", "--verbose", action="store_true")
   args = parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.INFO)

   # set key
   gmaps = googlemaps.Client(KEY)

   # read location list
   locations=[]
   with open(args.locations,'r') as f:
      locationsFile=[]
      for line in f:
         locations.append(line.rstrip())

   # read pairs already done/to be ignored
   excludedPairs=[]
   if args.update_mode:
      try:
         with open(args.time_distance_file,'r') as f:
            rows=csv.reader(f)
            for row in rows:
               excludedPairs.append((row[0],row[1]))
      except IOError as err:
         logging.info("{0}; ignoring ...".format(err))
         
   # read locations which have already been mapped
   excludedLocations={}
   if args.update_mode:
      try:
         with open(args.address_map,'r') as f:
            rows=csv.reader(f)
            for row in rows:
               excludedLocations[row[1]]=row[0]
      except IOError as err:
         logging.info("{0}; ignoring ...".format(err))

   # origin and destination list
   [timeDistanceMatrix,addressMap,failedPairs,failedLocns]=pairwiseTimeDistance(locations,excludedPairs,excludedLocations)

   # write timeDistanceMatrix
   logging.info("Writing time-distance pairs ...")
   if args.update_mode:
      f=open(args.time_distance_file,'a')
   else:
      f=open(args.time_distance_file,'w')
   for ele in timeDistanceMatrix:
      f.write("\"%s\",\"%s\",%d,%d\n" %ele)
   f.close()
   
   # write addressMap
   logging.info("Writing address map ...")
   if args.update_mode:
      f=open(args.address_map,'a')
   else:
      f=open(args.address_map,'w')
   for loc in addressMap:
      f.write("\"%s\",\"%s\"\n" %(addressMap[loc],loc.encode('ascii','ignore')))
   f.close()

   # failed stuff
   if failedPairs:
      logging.warning("Found failed pairs and locations; \
stored in %s." %FAILED_PAIRS_FILE)
      with open(FAILED_PAIRS_FILE,'w') as f:
         for ele in failedPairs:
            f.write("\"%s\",\"%s\"\n" %ele)
         ## src,dst=zip(*failedPairs)
         ## failedLocns=set(src).union(set([locations[-1]])) & set(dst)
         f.write("###########Locations that failed\n")
         for ele in failedLocns:
            f.write("\"%s\"\n" %ele)
   else:
      logging.info("All pairs succesful.")

