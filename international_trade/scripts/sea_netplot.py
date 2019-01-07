#!/usr/bin/env python
# plot network using tikz
# tags: code python tikz asterix kwargs devNull devnull subprocess redirect
# igraph iGraph

import argparse
import csv
import pdb
import logging
import sys
import igraph
import os
from math import log
from math import sqrt
from subprocess import check_call

import tikz_network as tikz
import country_attributes

DESC=""

FOCUS_COUNTRIES=['BGD', 'MMR', 'BRN', 'IDN', 'KHM', 'LAO', 'MYS', 'PHL', 'THA', 'VNM', 'SGP']

TUTA_COUNTRIES_ASIA=["AFG","BHR","IND","IRN","IRQ","ISR","JOR","KWT","KGZ","LBN","NPL","OMN","QAT","SAU","SYR","TJK","TUR","TKM","ARE","UZB","YEM","KAZ"]
TUTA_COUNTRIES_AFRICA=["DZA","BDI","COD","EGY","ETH","GHA","GIN","KEN","LBY","MWI","MLI","MAR","MOZ","NER","NGA","RWA","SEN","ZAF","SDN","TZA","TUN","UGA","ZMB","ZWE"]
TUTA_COUNTRIES_EUROPE=["ALB","BIH","BRA","BGR","HRV","CYP","CZE","FRA","GMB","GEO","DEU","GRC","GGY","HUN","ITA","LTU","MNE","NLD","PRT","MLT","ROU","RUS","SRB","SVN","ESP","CHE","UKR","BEL","POL","MKD"]
TUTA_COUNTRIES_AMERICAS=["ARG","AUT","AZE","BOL","CHL","COL","CRI","ECU","GUF","GUY","PAN","PRY","PER","SUR","URY","VEN"]

## NOT_TUTA_COUNTRIES=['GBR', 'CAN', 'NZL', 'LKA', 'TWN', 'USA', 'JPN', 'AUS',\
##       'CHN', 'DNK', 'PAK', 'HKG', 'KOR', 'GTM', 'LCA', 'DOM', 'TON', 'NIC',\
##       'MEX', 'IRL', 'SLV', 'CUB']

TUTA_COUNTRIES=TUTA_COUNTRIES_AFRICA+TUTA_COUNTRIES_AMERICAS+\
      TUTA_COUNTRIES_ASIA+TUTA_COUNTRIES_EUROPE

ORANGE="#F59146"
RED="#D04E56"
GREEN="#B2C85C"
BLUE="#78A6BE"
YELLOW="#FDC94F"

NUM_NODES_OUTSIDE_REGIONS=5
NUM_EDGES_LEGEND=4
numFocusCountries=len(FOCUS_COUNTRIES)

def assignTutaLabel(region,name,x,y,nodeLabels):
   xList.append(x)
   yList.append(y)
   tutaLabel="{\parbox{1.2cm}{\\textbf{%s}\\\\" %name
   for name in sorted(region):
      tutaLabel=tutaLabel+name+'\\\\'
   tutaLabel=tutaLabel.rstrip('\\\\')+'}}'
   nodeLabels.append(tutaLabel)
   return

def legendVal(x,y,edge,label,weight):
   xOffset=5
   xList.append(x)
   yList.append(y)
   nodeLabels.append(label)
   xList.append(x+xOffset)
   yList.append(y)
   nodeLabels.append("")
   g.add_edges([edge])
   edgeWeight.append(weight)
   edgeColor.append(RED)

def legend():
   startNode=numFocusCountries+NUM_NODES_OUTSIDE_REGIONS

   x=121
   y=-5
   yOffset=-1.5

   legendVal(x,y,(startNode,startNode+1),"10",10)
   y-=yOffset
   startNode+=2
   legendVal(x,y,(startNode,startNode+1),"100",100)
   y-=yOffset
   startNode+=2
   legendVal(x,y,(startNode,startNode+1),"1K",1000)
   y-=yOffset
   startNode+=2
   legendVal(x,y,(startNode,startNode+1),"10K",10000)
   return

if __name__ == "__main__":
   # parser
   parser = argparse.ArgumentParser(description=DESC,formatter_class=argparse.RawTextHelpFormatter)
   parser.add_argument("edge_file", action="store",help="CSV: u,v,<weight>")
   parser.add_argument("-n","--node_file", action="store",help="CSV: v,<weight>")
   parser.add_argument("-v", "--verbose", action="store_true")
   parser.add_argument("-o","--output_prefix",action="store",default="out",help="Generates <prefix>.{tex,pdf}.")
   args = parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.INFO)

   # initialize
   g = igraph.Graph(directed=True)
   visualStyle = {}
   numFocusCountries=len(FOCUS_COUNTRIES)
   numNodes=numFocusCountries+NUM_NODES_OUTSIDE_REGIONS+NUM_EDGES_LEGEND*2

   # set focus country vertices and their positions
   focusCountries={i: con for i,con in zip(xrange(len(FOCUS_COUNTRIES)),FOCUS_COUNTRIES)}
   invFocusCountries={v: k for k,v in focusCountries.iteritems()}
   g.add_vertices(numNodes)
   xList=[country_attributes.countryAttribs[con][2] for con in FOCUS_COUNTRIES]
   yList=[-country_attributes.countryAttribs[con][1] for con in FOCUS_COUNTRIES]
   nodeLabels=FOCUS_COUNTRIES
   otherNodeID={'africa':numFocusCountries, 'americas': numFocusCountries+1, \
         'asia': numFocusCountries+2, 'europe': numFocusCountries+3, \
         'free': numFocusCountries+4}

   # read edges
   edgeDict={}
   edgeList=[]
   edgeWeight=[]
   edgeColor=[]
   tutaCountriesAfrica=set()
   tutaCountriesAmericas=set()
   tutaCountriesAsia=set()
   tutaCountriesEurope=set()
   nonTutaCountries=set()
   with open(args.edge_file,'r') as f:
      for line in f:
         l=line.rstrip('\n').split(',')
         if not float(l[2]) or l[0] == l[1]:
            continue
         elif l[0] not in FOCUS_COUNTRIES and l[1] not in FOCUS_COUNTRIES:
            continue
         elif l[0] in FOCUS_COUNTRIES and l[1] in FOCUS_COUNTRIES:
            edgeDict[(invFocusCountries[l[0]],invFocusCountries[l[1]])]=[float(l[2]),GREEN]
            print "%s,%s,%s" %(l[0],l[1],l[2])
         elif l[0] not in TUTA_COUNTRIES and l[1] in FOCUS_COUNTRIES:
            continue
         elif l[0] in TUTA_COUNTRIES_AFRICA and l[1] in FOCUS_COUNTRIES:
            nodeID=otherNodeID['africa']
            try:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[\
                     edgeDict[(nodeID,invFocusCountries[l[1]])][0]+float(l[2]),RED]
            except:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[float(l[2]),RED]
            tutaCountriesAfrica.add(l[0])
         elif l[0] in TUTA_COUNTRIES_AMERICAS and l[1] in FOCUS_COUNTRIES:
            nodeID=otherNodeID['americas']
            try:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[\
                     edgeDict[(nodeID,invFocusCountries[l[1]])][0]+float(l[2]),RED]
            except:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[float(l[2]),RED]
            tutaCountriesAmericas.add(l[0])
         elif l[0] in TUTA_COUNTRIES_ASIA and l[1] in FOCUS_COUNTRIES:
            nodeID=otherNodeID['asia']
            try:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[\
                     edgeDict[(nodeID,invFocusCountries[l[1]])][0]+float(l[2]),RED]
            except:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[float(l[2]),RED]
            tutaCountriesAsia.add(l[0])
         elif l[0] in TUTA_COUNTRIES_EUROPE and l[1] in FOCUS_COUNTRIES:
            nodeID=otherNodeID['europe']
            try:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[\
                     edgeDict[(nodeID,invFocusCountries[l[1]])][0]+float(l[2]),RED]
            except:
               edgeDict[(nodeID,invFocusCountries[l[1]])]=[float(l[2]),RED]
            tutaCountriesEurope.add(l[0])
         elif l[0] in FOCUS_COUNTRIES and (l[1] not in TUTA_COUNTRIES and l[1] not in FOCUS_COUNTRIES):
            nodeID=otherNodeID['free']
            try:
               edgeDict[(invFocusCountries[l[0]],nodeID)]=[\
                     edgeDict[(invFocusCountries[l[0]],nodeID)][0]+float(l[2]),BLUE]
            except:
               edgeDict[(invFocusCountries[l[0]]),nodeID]=[float(l[2]),BLUE]
            nonTutaCountries.add(l[1])
         else:
            logging.warning("(%s,%s) unresolved" %(l[0],l[1]))

   for edge in edgeDict:
      edgeList.append(edge)
      edgeWeight.append(edgeDict[edge][0])
      edgeColor.append(edgeDict[edge][1])
   g.add_edges(edgeList)

   # create node for tuta infected countries
   assignTutaLabel(tutaCountriesAfrica,'Africa',87,-21,nodeLabels)
   assignTutaLabel(tutaCountriesAmericas,'Americas',87,-15,nodeLabels)
   assignTutaLabel(tutaCountriesAsia,'Asia',87,-9,nodeLabels)
   assignTutaLabel(tutaCountriesEurope,'Europe',87,-3,nodeLabels)
   assignTutaLabel(nonTutaCountries,'',115,-20,nodeLabels)

   # create legend
   legend()

   g.vs['x']=xList
   g.vs['y']=yList
   g.vs["name"] = nodeLabels
   g.vs["shape"] = ['circle']*numFocusCountries + ['rectangle']*NUM_NODES_OUTSIDE_REGIONS + ['circle']*NUM_EDGES_LEGEND*2

   visualStyle['vertex_label']=g.vs["name"]
   visualStyle['vertex_shape']=g.vs["shape"]
   visualStyle['vertex_size']=[25]*(numFocusCountries+NUM_NODES_OUTSIDE_REGIONS) \
         +[0]*(NUM_EDGES_LEGEND*2)
   visualStyle["vertex_label_size"] = 25
   visualStyle['vertex_label_position']=['left' for v in g.vs]
   visualStyle['vertex_label_position'][otherNodeID['free']]='right'
   visualStyle["vertex_label_distance"] = [1.5 for v in g.vs]
   ## visualStyle['vertex_color']=['black']*(numFocusCountries \
   ##       + NUM_NODES_OUTSIDE_REGIONS) \
   ##       + ['white']*(NUM_EDGES_LEGEND*2)
   visualStyle['vertex_color']=[ORANGE]*numFocusCountries \
         + [RED]*(NUM_NODES_OUTSIDE_REGIONS-1) \
         + [BLUE] \
         + ['white']*(NUM_EDGES_LEGEND*2)

   visualStyle["edge_color"] =edgeColor
   visualStyle["edge_opacity"] = [.9 for e in g.es]
   visualStyle["edge_curved"] = [0.1]*(g.ecount()-NUM_EDGES_LEGEND)+[0]*NUM_EDGES_LEGEND
   visualStyle["edge_width"] = [w**.3 for w in edgeWeight]

   outTex=args.output_prefix+'.tex'
   tikz.plot(g,outTex,**visualStyle)
   logging.info('Converting to pdf ...')
   with open(os.devnull,'w') as fnull:
      check_call(['pdflatex','-interaction','nonstopmode','-halt-on-error',outTex],stdout=fnull)

