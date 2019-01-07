import matplotlib.pyplot as plt
import pdb
import pandas as pd
import sqlite3
import numpy as np
import math
from math import log
import seaborn as sns

study_countries=['Cambodia', 'Thailand', 'Myanmar', 'Viet Nam',
                "Lao People's Democratic Republic", 'Indonesia',
                'Malaysia', 'Philippines', 'Singapore', 'China mainland']

country_short=['Cambodia', 'Thailand', 'Myanmar', 'Vietnam',
                "Laos", 'Indonesia',
                'Malaysia', 'Philippines', 'Singapore', 'China']
DATA_FOLDER = '../../data/'

TIMELINE_DB= '../../../timeline/timeline.sqlite'

def get_infected_country(db=TIMELINE_DB):
    conn = sqlite3.connect(db)
    conn.row_factory = lambda cursor, row: row[0]
    c = conn.cursor()
    query = "SELECT DISTINCT Country FROM timeline WHERE TutaPresent=1"
    c.execute(query)
    infected = c.fetchall()
    return infected

def plot_import_amount(infected, network_file=DATA_FOLDER+
           'trade_network/2013_southeast_aisa_trade_network.csv'):
    """
    Plot the bar chart of overall tomato import volume and 
    import volume from infected countries for the study countries.
    """
    network_df = pd.read_csv(network_file)
    overall = dict()
    from_infected = dict()
    for index,row in network_df.iterrows():
        s = row['source']
        d = row['destination']
        a = float(row['amount'])
        if d in study_countries:
            if d in overall:
                overall[d] += a
                if s in infected:
                    from_infected[d] += a
            else:
                overall[d] = a
                if s in infected:
                    from_infected[d] = a
     
    o = list()
    i = list()
    for country in study_countries:
        o.append(overall[country])
        if country not in from_infected:
            i.append(0.0)
        else:
            i.append(from_infected[country])
     
    bar_width = 0.25
    y_pos = np.arange(len(study_countries))
    plt.bar(y_pos,o,bar_width,align='center', alpha=0.5,
            color='b', label='Overall import volume')
    plt.bar(y_pos+bar_width, i, bar_width, align='center',
            alpha=0.5, color='firebrick', 
            label='Import volume from infected countries')
    plt.xticks(y_pos, country_short,rotation='vertical',size=5)
    plt.yscale('log')
    plt.ylabel('Import volume (tons)')
    plt.legend(loc='upper left')
    plt.savefig('import.pdf', format='pdf', dpi=300)

infected = get_infected_country()
plot_import_amount(infected)
