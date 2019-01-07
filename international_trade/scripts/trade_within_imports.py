# AA
# tags: pandas fao tradeMatrix trade faostat

import argparse
import pandas as pd
import networkx as nx
import sys
import pdb

DESC="""Extract networks from FAO trade matrix."""
nodeList=['Cambodia', 'Thailand', 'Myanmar', 'Viet Nam', 
           "Lao People's  Democratic Republic", 'Indonesia', 
           'Malaysia', 'Philippines', 'Singapore']
TRADE_FILE = '../data/FAOSTAT_solanaceae_trade_matrix.csv'

def tradeSummary(nodeList,years=[2013], products=['Tomatoes']):
    df = pd.read_csv(TRADE_FILE)
    dfFiltered = df[(df['Year'].isin(years)) & (df['Item'].isin(products))]
    # trade within
    dfTemp = dfFiltered[(dfFiltered['Reporter Countries'].isin(nodeList)) & \
          (dfFiltered['Partner Countries'].isin(nodeList)) & \
          (dfFiltered['Element']=='Export Quantity')]
    totalTradeExp=dfTemp['Value'].sum()
    dfTemp = dfFiltered[(dfFiltered['Reporter Countries'].isin(nodeList)) & \
          (dfFiltered['Partner Countries'].isin(nodeList)) & \
          (dfFiltered['Element']=='Import Quantity')]
    totalTradeImp=dfTemp['Value'].sum()
    totalTrade=max(totalTradeExp,totalTradeImp)
    # imports
    dfTemp = dfFiltered[(dfFiltered['Reporter Countries'].isin(nodeList)) & \
          (~dfFiltered['Partner Countries'].isin(nodeList)) & \
          (dfFiltered['Element']=='Import Quantity')]
    totalImpImp=dfTemp['Value'].sum()
    dfTemp = dfFiltered[(~dfFiltered['Reporter Countries'].isin(nodeList)) & \
          (dfFiltered['Partner Countries'].isin(nodeList)) & \
          (dfFiltered['Element']=='Export Quantity')]
    totalImpExp=dfTemp['Value'].sum()
    # exports
    dfTemp = dfFiltered[(dfFiltered['Reporter Countries'].isin(nodeList)) & \
          (~dfFiltered['Partner Countries'].isin(nodeList)) & \
          (dfFiltered['Element']=='Export Quantity')]
    totalExpExp=dfTemp['Value'].sum()
    dfTemp = dfFiltered[(~dfFiltered['Reporter Countries'].isin(nodeList)) & \
          (dfFiltered['Partner Countries'].isin(nodeList)) & \
          (dfFiltered['Element']=='Import Quantity')]
    totalExpImp=dfTemp['Value'].sum()
    return totalTradeExp,totalTradeImp,totalImpExp,totalImpImp,totalExpExp,totalExpImp

def main():
   # parser
   parser = argparse.ArgumentParser(description=DESC,formatter_class=argparse.RawTextHelpFormatter)
   parser.add_argument("-p","--product", action="store", default="Tomatoes")
   parser.add_argument("-y","--year", action="store", type=int, default=2013)
   parser.add_argument("-v", "--verbose", action="store_true")
   parser.add_argument("-o", "--output", action="store", default="out.csv")
   args = parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.INFO)
   
   [withinExp,withinImp,impExp,impImp,expExp,expImp]=tradeSummary(nodeList,years=[args.year],products=[args.product])
   print "%d,%d,%d,%d,%d,%d,%d" %(args.year,withinExp,withinImp,impExp,impImp,expExp,expImp)

if __name__=='__main__':
    main()
