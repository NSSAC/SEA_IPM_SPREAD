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
from math import log10
from math import floor
from math import sqrt
from subprocess import check_call

import tikz_network as tikz

DESC=""
VALIDATION_DATA="../../data/trade_flows_validation.csv"

ORANGE="#F59146"
RED="#D04E56"
GREEN="#B2C85C"
BLUE="#78A6BE"
YELLOW="#FDC94F"

if __name__ == "__main__":
   # parser
   parser = argparse.ArgumentParser(description=DESC,formatter_class=argparse.RawTextHelpFormatter)
   parser.add_argument("edge_file", action="store",help="CSV: u,v,<weight>")
   parser.add_argument("vertex_positions", action="store",help="CSV: v,lat,lon")
   parser.add_argument("-t","--threshold", action="store",default=1000,type=int,help="Only edges with weights above threshold will be displayed.")
   parser.add_argument("-n","--node_file", action="store",help="CSV: v,<weight>")
   parser.add_argument("-v", "--verbose", action="store_true")
   parser.add_argument("-o","--output_prefix",action="store",default="out",help="Generates <prefix>.{tex,pdf}.")
   args = parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.INFO)

   # initialize
   G = igraph.Graph(directed=True)
   visualStyle = {}

   # set vertices
   nodeLabels=[]
   xList=[]
   yList=[]
   with open(args.vertex_positions,'r') as f:
      rows=csv.reader(f)
      for row in rows:
         nodeLabels.append(row[1])
         xList.append(float(row[4]))
         yList.append(-float(row[3]))

   numNodes=len(nodeLabels)
   G.add_vertices(numNodes)

   G.vs['x']=xList
   G.vs['y']=yList
   G.vs["name"] = nodeLabels
   G.vs["shape"] = ['circle']*numNodes

   nodeColor=[ORANGE]*numNodes

   # read validation data
   validationData={}
   with open(VALIDATION_DATA,'r') as f:
      rows=csv.reader(f)
      for row in rows:
         validationData[(row[0],row[1])]=row[2]

   # set edges
   edgeWeight=[]
   edgeList=[]
   edgeLabels=[]
   with open(args.edge_file,'r') as f:
      rows=csv.reader(f)
      for row in rows:
         try:
            src=nodeLabels.index(row[0])
            dst=nodeLabels.index(row[1])
            weight=float(row[2])
            if src != dst and weight>args.threshold:
               edgeList.append((src,dst))
               edgeWeight.append(weight)
               try:
                  label=validationData[(row[0],row[1])]
               except KeyError:
                  label=""
               edgeLabels.append(label)
         except ValueError:
            continue
   edgeColor=[GREEN]*len(edgeList)

   G.add_edges(edgeList)
   G.es["name"] = edgeLabels

   # remove isolated nodes
   isolatedNodes=[i for i,x in enumerate(G.degree()) if x==0]
   G.delete_vertices(isolatedNodes)

   # set figure attributes
   visualStyle['vertex_shape']=G.vs["shape"]
   visualStyle['vertex_size']=25
   visualStyle['vertex_label']=G.vs["name"]
   visualStyle["vertex_label_size"] = 25
   visualStyle['vertex_label_position']='left'
   visualStyle["vertex_label_distance"] = 1.5
   visualStyle['vertex_color']=nodeColor

   visualStyle["edge_color"] =edgeColor
   visualStyle['edge_label']=G.es["name"]
   visualStyle["edge_label_size"] = 35
   visualStyle["edge_label_shape"] = 'rectangle'
   visualStyle["edge_label_color"] = 'black'
   #visualStyle['edge_label_position']=['center' for e in G.es]
   visualStyle["edge_label_distance"] = .8
   visualStyle["edge_opacity"] = .9
   visualStyle["edge_curved"] = 0.1
   visualStyle["edge_width"] = [max(0,log10(w/args.threshold)+1)**2 for w in edgeWeight]

   outTex=args.output_prefix+'.tex'
   tikz.plot(G,outTex,**visualStyle)
   logging.info('Converting to pdf ...')
   with open(os.devnull,'w') as fnull:
      check_call(['pdflatex','-interaction','nonstopmode','-halt-on-error',outTex],stdout=fnull)

