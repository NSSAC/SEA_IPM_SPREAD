# AA
# tags: pandas fao production trade faostat

import argparse
import pandas as pd
import sys
import pdb

DESC="""Extract production data from FAOSTAT."""
nodeList=['Cambodia', 'Thailand', 'Myanmar', 'Viet Nam', 
           "Lao People's  Democratic Republic", 'Indonesia', 
           'Malaysia', 'Philippines', 'Singapore']
PRODUCTION_FILE = '../data/FAOSTAT_solanaceae_production.csv'

def create_production(nodeList,years=[2013], products=['Tomatoes']):
    df = pd.read_csv(PRODUCTION_FILE)
    dfFiltered = df[(df['Year'].isin(years)) & (df['Item'].isin(products)) & \
          (df['Area'].isin(nodeList)) & (df['Element']=="Production")]
    production=[]
    relabel = {'China, mainland':'China mainland', 
               'China, Hong Kong SAR':'China Hong Kong SAR',
               'China, Macao SAR':'China Macao SAR',
               'China, Taiwan Province of':'China Taiwan Province of'}
    for index,row in dfFiltered.iterrows():
       try: 
          con=relabel[row['Area']]
       except KeyError:
          con=row['Area']
       production.append((con,row['Value']))
    return production

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
   
   prod=create_production(nodeList,years=[args.year],products=[args.product])
   with open(args.output,'w') as f:
      for ele in prod:
         f.write("%s,%d\n" %ele)

if __name__=='__main__':
    main()
