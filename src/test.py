import requests
import json
import sys
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import requestLib
import dataDealer

def clean_country(country):
    for i in range(len(country)):
        if 'Germany' in country[i]:
            country[i] = 'Germany'
        elif 'Euro area - 19' in country[i]:
            country[i] = 'Euro Area (EA-19)'
        elif 'European Union' in country[i]:
            n = country[i].split(" ")[3]
            country[i] = 'EU-%s' % (n)
    return country

noCountry = ['European Union - 27 countries (2007-2013)' ,
             'European Union - 25 countries (2004-2006)',
             'Euro area - 18 countries (2014)',
             'Euro area - 17 countries (2011-2013)'
            ]
host_url = "http://ec.europa.eu/eurostat/wdds/rest/data/v2.1/json/en/"
clean_country = {'Germany': 'Germany', 'Euro area - 19' : 'Euro Area (EA-19)', 'European Union - 27 countries (from ': 'EU-27', 'European Union - 28' : 'EU-28'}

args = requestLib.args_to_dict('table= gov_10dd_edpt1', 'na_item=B9', 'precision=1', 'unit=PC_GDP', 'time=2018,2019','sector=S13')
client = requestLib.RequestHandeler(host_url)

data , strdata, response = client.get_request(args)
times = list(list(data['dimension']['time']['category'].values())[1].values())
country = list(list(data['dimension']['geo']['category'].values())[1].values())
values = list(data['value'].values())

years, country = dataDealer.json_to_data(lines=country, columns=times, values=values, remove_list=noCountry, void_item=True, clean_dict=clean_country)
plot_x_labels = dataDealer.clean_label(lines=country, remove_list=noCountry)
debt = dataDealer.subjason_to_DataFrame(lines=country, columns=times, subDict=years)
print(debt)
sys.exit()
pos = np.arange(len(plot_x_labels))

fig, ax = plt.subplots()
ax.set_xticks(pos)
ax.set_xticklabels(labels, rotation = 90)
width = 0.35

ax.bar(pos -  width/2., list(years['2018'].values()),  width, label='2018')
ax.bar(pos +  width/2., list(years['2019'].values()),  width, label='2019')
plt.legend(loc='upper right')

plt.show()
