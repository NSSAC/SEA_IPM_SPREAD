###########################################################################
# Seasonal production allocation for each country
###########################################################################
import sqlite3
import argparse
import pdb
import logging
import csv
import pandas as pd
import math

DESC="""Disaggregate annual production for each grid cell to monthly
production."""
DB="../../data_and_obj.db"
ANNUAL_PRODUCTION="../../cellular_automata/obj/ca_mapspam_pop.csv"
PRECIPITATION="../obj/precipitation_gpcc.csv"
SEASONAL_PRODUCTION="../obj/ca_seasonal_production.csv"
BRN_TOMATO=142
MYS_TOMATO=242946
PHL_TOMATO=210720 #2016
THA_TOMATO=113326
VNM_TOMATO=492960
IDN_TOMATO=883242
BGD_TOMATO=368081
SGP_TOMATO=66
BRN_EGGPLANT=378
PHL_EGGPLANT=235626 #2016
THA_EGGPLANT=14542
IDN_EGGPLANT=509749
BGD_EGGPLANT=504817
PHL_POTATO=116783 #2016
THA_POTATO=140977
MMR_POTATO=554309
IDN_POTATO=1213041
LAO_POTATO=31095
BGD_POTATO=9474098

def BGDProd(annualProd,cellsToIgnore):
   con=sqlite3.connect(DB)
   c=con.cursor()

   # read figures from db and compute scaling factors for each division
   c.execute("SELECT * FROM production_BGD")
   queryResult=c.fetchall()
   con.close()

   productionBGD={}
   for x in queryResult:
      productionBGD[x[0]]={\
            'tomato': x[1],\
            'eggplant': x[3]+x[4],\
            'potato': x[5]}
   sumTom = 0
   sumEgg = 0
   sumPota = 0
   for key, value in productionBGD.items():
      sumTom += value['tomato']
      sumEgg += value['eggplant']
      sumPota += value['potato']
   pdb.set_trace()

   totProd={}
   for div in productionBGD.keys():
      totProd[div]={}
      totProd[div]['vege']=0
      totProd[div]['potato']=0

   for cell in annualProd:
      if annualProd[cell]['admin'] in productionBGD.keys():
         cellsToIgnore.append(cell)
         totProd[annualProd[cell]['admin']]['vege']+=annualProd[cell]['vege']
         totProd[annualProd[cell]['admin']]['potato']+=annualProd[cell]['potato']
   
   # apply scaling factor for annual production
   for cell in annualProd:
      if annualProd[cell]['admin'] in productionBGD.keys():
         div=annualProd[cell]['admin']
         annualProd[cell]['tomato']=productionBGD[div]['tomato']/totProd[div]['vege']\
                  *annualProd[cell]['vege']
         annualProd[cell]['potato']=productionBGD[div]['potato']/totProd[div]['potato']\
                  *annualProd[cell]['potato']
         annualProd[cell]['eggplant']=productionBGD[div]['eggplant']/totProd[div]['vege']\
                  *annualProd[cell]['vege']
   return

def PHLProd(annualProd,cellsToIgnore):
   con=sqlite3.connect(DB)
   c=con.cursor()

   # read figures from db and compute scaling factors for each division
   c.execute("SELECT * FROM PHL_admin")
   queryResult=c.fetchall()
   admin={}
   for x in queryResult:
      admin[x[1]]=x[2]

   regionalProd={}
   c.execute("SELECT * FROM production_PHL")
   queryResult=c.fetchall()
   for x in queryResult:
      regionalProd[x[0]]={\
            'tomato': int(x[1])+int(x[2])+int(x[3])+int(x[4]),\
            'eggplant': int(x[5])+int(x[6])+int(x[7])+int(x[8])}
   con.close()

   totProd={}
   for div in regionalProd.keys():
      totProd[div]={}
      totProd[div]['vege']=0
   totProdPotato=0

   for cell in annualProd:
      if "PH-" in annualProd[cell]['iso']:
         div=admin[annualProd[cell]['admin']]
         cellsToIgnore.append(cell)
         totProd[div]['vege']+=annualProd[cell]['vege']
         totProdPotato+=annualProd[cell]['potato']
   
   # apply scaling factor for annual production
   for cell in annualProd:
      if "PH-" in annualProd[cell]['iso']:
         div=admin[annualProd[cell]['admin']]
         annualProd[cell]['tomato']=regionalProd[div]['tomato']/totProd[div]['vege']\
                  *annualProd[cell]['vege']
         annualProd[cell]['eggplant']=regionalProd[div]['eggplant']/totProd[div]['vege']\
                  *annualProd[cell]['vege']
         annualProd[cell]['potato']=PHL_POTATO/totProdPotato\
                  *annualProd[cell]['potato']
   return

def THAProd(annualProd,cellsToIgnore):
   con=sqlite3.connect(DB)
   c=con.cursor()

   # read figures from db and compute scaling factors for each division
   c.execute("SELECT * FROM THA_admin")
   queryResult=c.fetchall()
   admin={}
   for x in queryResult:
      admin[x[0]]=x[1]

   regionalProd={}
   c.execute("SELECT * FROM harvest_area_THA")
   queryResult=c.fetchall()

   totalTomato=0
   totalEggplant=0
   for x in queryResult:
      regionalProd[x[0]]={\
            'tomato': int(x[1])+int(x[2]),\
            'eggplant': int(x[3])}
      totalTomato+=regionalProd[x[0]]['tomato']
      totalEggplant+=regionalProd[x[0]]['eggplant']
   con.close()

   totProd={}
   for div in regionalProd.keys():
      totProd[div]={}
      totProd[div]['vege']=0
   totProdPotato=0

   for cell in annualProd:
      if "TH-" in annualProd[cell]['iso']:
         div=admin[annualProd[cell]['admin']]
         cellsToIgnore.append(cell)
         totProd[div]['vege']+=annualProd[cell]['vege']
         totProdPotato+=annualProd[cell]['potato']
   
   # apply scaling factor for annual production
   for cell in annualProd:
      if "TH-" in annualProd[cell]['iso']:
         div=admin[annualProd[cell]['admin']]
         annualProd[cell]['tomato']=THA_TOMATO*regionalProd[div]['tomato']/totalTomato/totProd[div]['vege']\
                  *annualProd[cell]['vege']
         annualProd[cell]['eggplant']=THA_EGGPLANT*regionalProd[div]['eggplant']/totalEggplant/totProd[div]['vege']\
                  *annualProd[cell]['vege']
         annualProd[cell]['potato']=THA_POTATO/totProdPotato\
                  *annualProd[cell]['potato']
   return

def IDNProd(annualProd,cellsToIgnore):

   # apply scaling factor for annual production
   totProdPotato=.0
   totProdVege=.0
   for cell in annualProd:
      if "ID-" in annualProd[cell]['iso']:
         cellsToIgnore.append(cell)
         totProdPotato+=annualProd[cell]['potato']
         totProdVege+=annualProd[cell]['vege']

   for cell in annualProd:
      if "ID-" in annualProd[cell]['iso']:
         annualProd[cell]['tomato']=IDN_TOMATO/totProdVege*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=IDN_EGGPLANT/totProdVege*annualProd[cell]['vege']
         annualProd[cell]['potato']=IDN_POTATO/totProdPotato*annualProd[cell]['potato']
   return

def SGPProd(annualProd,cellsToIgnore,eggFrac):

   # apply scaling factor for annual production
   totProdVege=.0
   for cell in annualProd:
      if annualProd[cell]['iso']=="SN":
         cellsToIgnore.append(cell)
         totProdVege+=annualProd[cell]['vege']

   for cell in annualProd:
      if annualProd[cell]['iso']=="SN":
         annualProd[cell]['tomato']=SGP_TOMATO/totProdVege*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=0.0
         annualProd[cell]['potato']=annualProd[cell]['potato']
   return

def MYSProd(annualProd,cellsToIgnore,eggFrac):

   # apply scaling factor for annual production
   totProdVege=.0
   for cell in annualProd:
      if "MY-" in annualProd[cell]['iso']:
         cellsToIgnore.append(cell)
         totProdVege+=annualProd[cell]['vege']

   for cell in annualProd:
      if "MY-" in annualProd[cell]['iso']:
         annualProd[cell]['tomato']=MYS_TOMATO/totProdVege*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=eggFrac*annualProd[cell]['vege']
         annualProd[cell]['potato']=annualProd[cell]['potato']
   return

def MMRProd(annualProd,cellsToIgnore,tomFrac,eggFrac):

   # apply scaling factor for annual production
   totProdPotato=.0
   for cell in annualProd:
      if "MM-" in annualProd[cell]['iso']:
         cellsToIgnore.append(cell)
         totProdPotato+=annualProd[cell]['potato']

   for cell in annualProd:
      if "MM-" in annualProd[cell]['iso']:
         annualProd[cell]['tomato']=tomFrac*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=eggFrac*annualProd[cell]['vege']
         annualProd[cell]['potato']=MMR_POTATO/totProdPotato*annualProd[cell]['potato']
   return

def BRNProd(annualProd,cellsToIgnore):

   # apply scaling factor for annual production
   totProdVege=.0
   for cell in annualProd:
      if "BN-" in annualProd[cell]['iso']:
         cellsToIgnore.append(cell)
         totProdVege+=annualProd[cell]['vege']

   for cell in annualProd:
      if "BN-" in annualProd[cell]['iso']:
         annualProd[cell]['tomato']=BRN_TOMATO/totProdVege*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=BRN_EGGPLANT/totProdVege*annualProd[cell]['vege']
         annualProd[cell]['potato']=annualProd[cell]['potato']
   return

def LAOProd(annualProd,cellsToIgnore,tomFrac,eggFrac):

   # apply scaling factor for annual production
   totProdPotato=0
   for cell in annualProd:
      if "LA-" in annualProd[cell]['iso']:
         cellsToIgnore.append(cell)
         totProdPotato+=annualProd[cell]['potato']

   for cell in annualProd:
      if "LA-" in annualProd[cell]['iso']:
         annualProd[cell]['tomato']=tomFrac*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=eggFrac*annualProd[cell]['vege']
         annualProd[cell]['potato']=LAO_POTATO/totProdPotato*annualProd[cell]['potato']
   return

def KHMProd(annualProd,cellsToIgnore,tomFrac,eggFrac):

   # apply scaling factor for annual production
   totProdPotato=0
   for cell in annualProd:
      if "KH-" in annualProd[cell]['iso']:
         cellsToIgnore.append(cell)
         totProdPotato+=annualProd[cell]['potato']

   for cell in annualProd:
      if "KH-" in annualProd[cell]['iso']:
         annualProd[cell]['tomato']=tomFrac*annualProd[cell]['vege']
         annualProd[cell]['eggplant']=eggFrac*annualProd[cell]['vege']
         annualProd[cell]['potato']=annualProd[cell]['potato']
   return

def VNMProd(annualProd,cellsToIgnore,eggFrac):
   con=sqlite3.connect(DB)
   c=con.cursor()

   # read figures from db and compute scaling factors for each division
   c.execute("SELECT * FROM VNM_admin")
   queryResult=c.fetchall()
   admin={}
   for x in queryResult:
      admin[x[0]]=x[1]

   regionalProd={}
   c.execute("SELECT * FROM production_VNM")
   queryResult=c.fetchall()

   totalTomato=0
   for x in queryResult:
      regionalProd[x[0]]={\
            'tomato': int(x[1])}
      totalTomato+=regionalProd[x[0]]['tomato']
   con.close()

   totProd={}
   for div in regionalProd.keys():
      totProd[div]={}
      totProd[div]['vege']=0
   totProdPotato=0

   for cell in annualProd:
      if "VN-" in annualProd[cell]['iso']:
         div=admin[annualProd[cell]['admin']]
         cellsToIgnore.append(cell)
         totProd[div]['vege']+=annualProd[cell]['vege']
   
   # apply scaling factor for annual production
   for cell in annualProd:
      if "VN-" in annualProd[cell]['iso']:
         div=admin[annualProd[cell]['admin']]
         annualProd[cell]['tomato']=VNM_TOMATO*regionalProd[div]['tomato']/totalTomato/totProd[div]['vege']\
                  *annualProd[cell]['vege']
         annualProd[cell]['eggplant']=eggFrac*annualProd[cell]['vege']
         annualProd[cell]['potato']=annualProd[cell]['potato']
   return

def vegeFraction(annualProd):
   vegeCountry={'BD': .0, 'BN': .0, 'SN': .0, 'VN': .0, 'TH': .0, 'PH': .0, 'MY': .0, 'ID': .0, 'MM': .0}
   for cell in annualProd:
      admin=annualProd[cell]['iso']
      cntry=admin[0:2]
      if cntry in vegeCountry.keys():
         try:
            vegeCountry[cntry]+=annualProd[cell]['vege']
         except:
            vegeCountry[cntry]=annualProd[cell]['vege']
   tomFracCntry={'TH': THA_TOMATO/vegeCountry['TH'],\
      'PH': PHL_TOMATO/vegeCountry['PH'],\
      'MY': MYS_TOMATO/vegeCountry['MY'],\
      'ID': IDN_TOMATO/vegeCountry['ID'],\
      'BN': BRN_TOMATO/vegeCountry['BN'],\
      'SN': SGP_TOMATO/vegeCountry['SN'],\
      'VN': VNM_TOMATO/vegeCountry['VN'],\
      'BD': BGD_TOMATO/vegeCountry['BD']}
   eggFracCntry={'TH': THA_EGGPLANT/vegeCountry['TH'],\
      'PH': PHL_EGGPLANT/vegeCountry['PH'],\
      'ID': IDN_EGGPLANT/vegeCountry['ID'],\
      'BN': BRN_EGGPLANT/vegeCountry['BN'],\
      'BD': BGD_EGGPLANT/vegeCountry['BD']}
   #AA: needs change
   #JM: changed
   #pdb.set_trace()
   return (0.042341842257950256+0.06728065358427185)/2.0,0.047346426176308784

def defaultProd(annualProd,cellsToIgnore):
   remainingCells=set(annualProd.keys()).difference(set(cellsToIgnore))
   print "Cells remaining:", len(remainingCells)
   ## Should be 0
   for cell in remainingCells:
      annualProd[cell]['tomato']=annualProd[cell]['vege']
      annualProd[cell]['eggplant']=annualProd[cell]['vege']
      annualProd[cell]['potato']=annualProd[cell]['potato']

def regressionPrecip(precip):
   return precip

def monthlyProdByPrecip(annualProd):
   monthlyProd={}
   # read precipitation
   precipitation=pd.read_csv(PRECIPITATION,index_col='cell_id')
   for cell in annualProd.keys():
      monthlyProd[cell]={}
      monthlyProd[cell]['tomato']=[0]*12
      monthlyProd[cell]['eggplant']=[0]*12
      monthlyProd[cell]['potato']=[0]*12
      precip=precipitation.loc[cell]

      for i in xrange(12):
         monthlyProd[cell]['tomato'][i]=math.exp(-0.208 -0.008*precip[4+i])
         monthlyProd[cell]['eggplant'][i]=math.exp(-0.208 -0.008*precip[4+i])
         monthlyProd[cell]['potato'][i]=math.exp(-0.208 -0.008*precip[4+i])
      normTomato=sum(monthlyProd[cell]['tomato'])
      normEggplant=sum(monthlyProd[cell]['eggplant'])
      normPotato=sum(monthlyProd[cell]['potato'])

      for i in xrange(12):
         try:
            monthlyProd[cell]['tomato'][i]*=annualProd[cell]['tomato']/normTomato
            monthlyProd[cell]['eggplant'][i]*=annualProd[cell]['eggplant']/normEggplant
            monthlyProd[cell]['potato'][i]*=annualProd[cell]['potato']/normPotato
         except:
            pdb.set_trace()
   return monthlyProd

def old_bangladeshProd(annualProd,seasonalProd):
   con=sqlite3.connect(DB)
   c=con.cursor()

   # read figures from db and compute scaling factors for each division
   c.execute("SELECT * FROM production_BGD")
   queryResult=c.fetchall()
   con.close()

   productionBGD={}
   for x in queryResult:
      productionBGD[x[0]]={\
            'tomato': x[1],\
            'eggplant': (x[3],x[4]),\
            'potato': x[5]}

   totProd={}
   for div in productionBGD.keys():
      totProd[div]={}
      totProd[div]['vege']=0
      totProd[div]['potato']=0

   for cell in annualProd:
      if annualProd[cell]['admin'] in productionBGD.keys():
         totProd[annualProd[cell]['admin']]['vege']+=annualProd[cell]['vege']
         totProd[annualProd[cell]['admin']]['potato']+=annualProd[cell]['potato']
   
   # Seasons distribution
   ### Eggplant is handled differently as figures are available separately
   ### for winter and summer.
   seasonsTemplate={\
         'tomato': [.75/12]*6 + [.25/12]*6,\
         'potato': [.75/12]*6 + [.25/12]*6}

   # assign monthly production
   for cell in annualProd:
      if annualProd[cell]['admin'] in productionBGD.keys():
         div=annualProd[cell]['admin']
         seasonalProd[cell]={'tomato': [0]*12,\
               'eggplant': [0]*12,
               'potato': [0]*12}
         for i in xrange(12):
            seasonalProd[cell]['tomato'][i]=\
                  productionBGD[div]['tomato']/totProd[div]['vege']\
                  *annualProd[cell]['vege']*seasonsTemplate['tomato'][i]
            seasonalProd[cell]['potato'][i]=\
                  productionBGD[div]['potato']/totProd[div]['potato']\
                  *annualProd[cell]['potato']*seasonsTemplate['potato'][i]
            seasonalProd[cell]['eggplant'][i]=\
                  productionBGD[div]['eggplant'][i>5]/totProd[div]['vege']\
                  *annualProd[cell]['vege']/6.0
   return

def old_defaultProd(annualProd,seasonalProd):
   remainingCells=set(annualProd.keys()).difference(set(seasonalProd.keys()))
   for cell in remainingCells:
      seasonalProd[cell]={}
      seasonalProd[cell]['tomato']=[annualProd[cell]['vege']/12]*12
      seasonalProd[cell]['eggplant']=[annualProd[cell]['vege']/12]*12
      seasonalProd[cell]['potato']=[annualProd[cell]['potato']/12]*12

if __name__ == "__main__":
   parser = argparse.ArgumentParser(
      formatter_class=argparse.RawTextHelpFormatter,
      description=DESC)
   
   parser.add_argument("-a","--annual_production",help="the input file for \
         annual production",default=ANNUAL_PRODUCTION)
   parser.add_argument("-o","--monthly_production",help="the output file for \
         seasonal production",default=SEASONAL_PRODUCTION)

   # extract parameters
   args = parser.parse_args()

   # read annual production
   with open(args.annual_production,'r') as f:
      annual={}
      rows=csv.reader(f)
      rows.next() # ignore header
      for row in rows:
         # vege,pota,admin_id
         annual[int(row[0])]={'vege': float(row[4]),\
               'potato': float(row[5]),\
               'admin': row[7],\
               'iso': row[6]}

   # compute seasonal production case by case
   cellsToIgnore=[]
   [tomFrac,eggFrac]=vegeFraction(annual)
   BGDProd(annual,cellsToIgnore)
   print "Cells processed:",len(cellsToIgnore)
   PHLProd(annual,cellsToIgnore)
   print "Cells processed:",len(cellsToIgnore)
   THAProd(annual,cellsToIgnore)
   print "Cells processed:",len(cellsToIgnore)
   VNMProd(annual,cellsToIgnore,eggFrac)
   print "Cells processed:",len(cellsToIgnore)
   LAOProd(annual,cellsToIgnore,tomFrac,eggFrac)
   print "Cells processed:",len(cellsToIgnore)
   KHMProd(annual,cellsToIgnore,tomFrac,eggFrac)
   print "Cells processed:",len(cellsToIgnore)
   BRNProd(annual,cellsToIgnore)
   print "Cells processed:",len(cellsToIgnore)
   MMRProd(annual,cellsToIgnore,tomFrac,eggFrac)
   print "Cells processed:",len(cellsToIgnore)
   IDNProd(annual,cellsToIgnore)
   print "Cells processed:",len(cellsToIgnore)
   MYSProd(annual,cellsToIgnore,eggFrac)
   print "Cells processed:",len(cellsToIgnore)
   SGPProd(annual,cellsToIgnore,eggFrac)
   print "Cells processed:",len(cellsToIgnore)
   defaultProd(annual,cellsToIgnore)
   
   monthlyProduction=monthlyProdByPrecip(annual)

   # write to file
   with open(args.monthly_production,'w') as f:
      f.write("cell_id,admin,\
T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,\
E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12,\
P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12\n")
      for cell in monthlyProduction:
         lineStr='%d,%s' %(cell,annual[cell]['iso'])
         for com in ['tomato','eggplant','potato']:
            for p in monthlyProduction[cell][com]:
               lineStr+=",%.2f" %p
         f.write(lineStr+'\n')




   
