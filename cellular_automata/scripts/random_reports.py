# Generate random incidence reports for BGD
import csv
import pdb
import numpy as np

GRID="../data/south_east_asia_adc_id_p25xp25.csv"

# read grid file and filter BGD
with open(GRID,'r') as f:
   cellsBGD=[]
   rows=csv.reader(f)
   for row in rows:
      if row[-1]=='BG':
         cellsBGD.append(int(row[0]))
   cellsBGD=list(set(cellsBGD))   

# choose seed as 669234 and time 5
randRep=[(669234,5)]

# choose 7 random locations
# assign times between 6 and 15
randLoc=np.random.randint(0,len(cellsBGD)-1,7)
randTime=np.random.randint(6,15,7)

for i in xrange(7):
   randRep.append((cellsBGD[randLoc[i]],randTime[i]))

# write file
with open('random_report.csv','w') as f:
   f.write("cell_id,moore,range,month\n")
   for r in randRep:
      f.write("%d,%d,0,%d\n" %(r[0],r[0],r[1]))
