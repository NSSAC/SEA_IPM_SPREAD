###########################################################################
# Seasonal production
###########################################################################

import csv
import pdb
import logging

WET_MONTH_THRESHOLD=100
WET_MONTH_WEIGHT=0.25
PRECIPITATION_FILE="../obj/precipitation_gpcc.csv"
MAPSPAM_FILE="../obj/mapspam_data.csv"
PRODUCTION_FILE="../obj/annual_production.csv"
SEASON_FILE="../obj/seasonal_production.csv"

# bounding box
MIN_LAT=-13
MAX_LAT=30
MIN_LON=89
MAX_LON=145

def annualProduction():
   with open(PRODUCTION_FILE,'w') as fprod:
      fprod.write('lat,lon,tom,pot,cntry,adm1,adm2\n')
      with open(MAPSPAM_FILE,'r') as fspam:
         rows=csv.reader(fspam)
         next(rows)
         maxProd=0
         for row in rows:
            lon=float(row[4])
            lat=float(row[5])
            if lon>MAX_LON or lon<MIN_LON or lat>MAX_LAT or lat<MIN_LAT:
               continue
            maxProd=max(float(row[6]),float(row[7]),maxProd)

         fspam.seek(0)
         next(rows)
         for row in rows:
            tom=float(row[7])/25
            egg=float(row[7])/25
            pot=float(row[6])
            lon=float(row[4])
            lat=float(row[5])
            cntry=row[1]
            admin1=row[2]
            admin2=row[3]
            if lon>MAX_LON or lon<MIN_LON or lat>MAX_LAT or lat<MIN_LAT:
               continue
            fprod.write('%s,%s,%g,%g,%g,%s,%s,%s\n' \
                  %(lat,lon,tom/maxProd,egg/maxProd,pot/maxProd,cntry,admin1,admin2))

def precipitation():
   prod=[0]*12
   with open(SEASON_FILE,'w') as fseason:
      fseason.write('lat,lon,1,2,3,4,5,6,7,8,9,10,11,12\n')
      with open(PRECIPITATION_FILE,'r') as fpre:
         rows=csv.reader(fpre)
         for row in rows:  #skipping headers
            if row[0][0]=='#':
               pass
            else:
               break
         for row in rows:
            lat=row[0]
            lon=row[1]
            for m in xrange(12):
               if float(row[m+2])>WET_MONTH_THRESHOLD:
                  prod[m]=WET_MONTH_WEIGHT
               else:
                  prod[m]=1
               sumProd=sum(prod)

            prodStr=','.join(['%.4f' %((i+.0)/sumProd) for i in prod])
            fseason.write('%s,%s,%s\n' %(lat,lon,prodStr))

if __name__=='__main__':
   annualProduction()
   #precipitation()
