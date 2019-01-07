# by Sichao
# modified by AA
# tags: pandas fao tradeMatrix trade faostat

import argparse
import pandas as pd
import networkx as nx
import sys
import pdb

DESC="""Extract networks from FAO trade matrix."""
nodeList=['Bangladesh', 'Cambodia', 'Thailand', 'Myanmar', 'Viet Nam', 
           "Lao People's  Democratic Republic", 'Indonesia', 
           'Malaysia', 'Philippines', 'Singapore', 'China, mainland']
TRADE_FILE = '../../data/FAOSTAT_solanaceae_trade_matrix.csv'

def create_trade_network(nodeList,years, products,tradeFile):
    G = nx.DiGraph()
    df = pd.read_csv(tradeFile)
    # G.add_nodes_from(nodeList)
    df_year = df[(df['Year'].isin(years)) & (df['Item'].isin(products))]
    df_sea = df_year[(df_year['Reporter Countries'].isin(nodeList)) | (df_year['Partner Countries'].isin(nodeList))]
    outflow = 0 
    inflow = 0
    for index,row in df_sea.iterrows():
        if row['Element']=='Export Quantity':
            src=row['Reporter Countries']
            dst=row['Partner Countries']
            try:
                G[src][dst]['exp']+=row['Value']
            except KeyError:
                G.add_edge(src,dst,exp=row['Value'],imp=0)
        elif row['Element']=='Import Quantity':
            src=row['Partner Countries']
            dst=row['Reporter Countries']
            try:
                G[src][dst]['imp']+=row['Value']
            except KeyError:
                G.add_edge(src,dst,exp=0,imp=row['Value'])

    relabel = {'China, mainland':'China mainland', 
               'China, Hong Kong SAR':'China Hong Kong SAR',
               'China, Macao SAR':'China Macao SAR',
               'China, Taiwan Province of':'China Taiwan Province of'}

    G = nx.relabel_nodes(G,relabel)
    return G


def main():
   # parser
   parser = argparse.ArgumentParser(description=DESC,formatter_class=argparse.RawTextHelpFormatter)
   parser.add_argument("-p","--product", action="store", default="Tomatoes")
   parser.add_argument("-y","--year", action="store", type=int, default=2013)
   parser.add_argument("-v", "--verbose", action="store_true")
   parser.add_argument("-o", "--output", action="store", default="out.csv")
   parser.add_argument("-t", "--trade_file", action="store", default=TRADE_FILE)
   args = parser.parse_args()

   # set logger
   if args.verbose:
      logging.basicConfig(level=logging.INFO)
   
   G=create_trade_network(nodeList,[args.year],[args.product],args.trade_file)
   with open(args.output,'w') as f:
      for s,d in G.edges():
         f.write("%s,%s,%d,%d\n" %(s,d,G[s][d]['exp'],G[s][d]['imp']))

if __name__=='__main__':
    main()
