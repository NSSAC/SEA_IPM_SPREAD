import argparse
import pandas as pd
import pdb

key = "../../cellular_automata/obj/cities/cities_250000.csv"

def mk_country_trade(ignoreSelfLoops, tradeFile,outFile):
    df = pd.read_csv(tradeFile, header=None, names=['city1','city2','weight','month'])
    df_key = pd.read_csv(key, index_col = 'name')
    total_dict = {}
    for index, row in df.iterrows():
        country1 = df_key.loc[row['city1']]['country']
        country2 = df_key.loc[row['city2']]['country']
	if ignoreSelfLoops and country1==country2:
	    continue
        weight = row['weight']
        try: total_dict[(country1,country2)] += weight
        except: total_dict[(country1,country2)] = weight

    print_dict = {}
    i = 0
    for index, value in total_dict.items():
        print_dict[i] = [index[0],index[1],value]
        i+=1
    df_out = pd.DataFrame.from_dict(print_dict, orient='index')
    df_out.columns=['country1','country2','weight']
    df_out.to_csv(outFile, index=False)
    
if __name__ == "__main__":
    parser=argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("city_flow_file",help="city trade flows")
    parser.add_argument("-o","--out_file",help="country trade flows",default="country_flows.csv")
    parser.add_argument("--ignore_self_loops",  action = 'store_true')
    args = parser.parse_args()

    mk_country_trade(args.ignore_self_loops, args.city_flow_file, args.out_file)

