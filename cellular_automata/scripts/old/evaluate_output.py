import csv
import pandas as pd
import argparse
import pdb

OUTPUT_FILE = "../work/out/output"
DATA_FILE = "../data/pest_dist.csv" 
EVAL_FILE = "../work/out/evaluation"
start_month = 1
start_year = 2016


def evaluate(moore, ndvi, prod):
	timesteps = 24
	conf_dist=1

	output = pd.read_csv(OUTPUT_FILE+"_"+str(moore) + "_"+str(ndvi) + "_" + str(prod) + ".csv", names=['cell_id','adc_id','time'])
	data = pd.read_csv(DATA_FILE,names=['adc_id','year','month'])
	output_df=pd.DataFrame(columns=['adc_id','time'])
	#print output.loc[output['adc_id']=='140004146']	
	# Look at min across all cells within district

	for district in data['adc_id']:
	    #print district
	    min = 1000
	    for row in output.loc[output['adc_id']==str(district),'time']:
	        row = float(row)	
		if row<min and row != -1:
		    min = row
	    if min == 1000:
		min = -1
	    output_df.loc[len(output_df)]=[district, min]

	# Do evaluation, output 
	sum = 0
	sum2 = 0
	sum3 = 0
	
	#print data
	for t in range(-1,timesteps+1):
		score = 0
		score2 = 0
		score3 = 0
		for dist in data['adc_id']:
		    if 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month) == t:
			p_G = 1
		    else:
			p_G = 0
		    if output_df.loc[output_df['adc_id'] == dist,'time'].item() == t:
			p_S = 1
		    else:
			p_S = 0

		    if 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month) == t:
                        p_G2 = 0.25
                    elif 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month)-1 == t:
                        p_G2 = 0.25
                    elif 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month)-2 == t:
                        p_G2 = 0.25
                    elif 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month)-3 == t:
                        p_G2 = 0.25
                    else:
                        p_G2 = 0

                    if 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month) == t:
                        p_G3 = 0.1
                    elif 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month)-1 == t:
                        p_G3 = 0.2
                    elif 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month)-2 == t:
                        p_G3 = 0.3
                    elif 12*(data.loc[data['adc_id'] == dist,'year'].item()-start_year)+(data.loc[data['adc_id'] == dist,'month'].item()-start_month)-3 == t:
                        p_G3 = 0.4
                    else:
                        p_G3 = 0

		    score += conf_dist*abs(p_S-p_G)
		    score2 += conf_dist*abs(p_S-p_G2)
		    score3 += conf_dist*abs(p_S-p_G3)
		    #print score
		sum += score
		sum2 += score2
		sum3 += score3
	    # sum is the final simulation score	
	print output_df
	#print data    
	file = open(EVAL_FILE+"1.csv",'a')
	file.write(str(moore)+" , "+str(ndvi)+ ", " + str(prod) +" , " + str(sum) +"\n")
	file.close() 

	file = open(EVAL_FILE+"2.csv",'a')
        file.write(str(moore)+" , "+str(ndvi)+" , "  + str(prod) +", " +str(sum2) +"\n")
        file.close()

	file = open(EVAL_FILE+"3.csv",'a')
        file.write(str(moore)+" , "+str(ndvi)+", " + str(prod) +" , " + str(sum3) +"\n")
        file.close()

if __name__ == "__main__":
    # read in arguments
    parser=argparse.ArgumentParser(
      formatter_class=argparse.RawTextHelpFormatter)
    

    parser.add_argument("-M", "--moore", default=2, type=str)
    parser.add_argument("-ndvi", "--ndvi", default=15, type=str)
    
    args=parser.parse_args()

    evaluate(args.moore, args.ndvi)
