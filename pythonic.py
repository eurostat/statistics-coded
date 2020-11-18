import numpy as np
import pandas as pd
from eurostatapiclient import EurostatAPIClient
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.legend_handler import HandlerPatch
import matplotlib.patches as mpatches

VERSION = 'v2.1'
FORMAT = 'json'
LANGUAGE = 'en'
client = EurostatAPIClient(VERSION, FORMAT, LANGUAGE)


labels = ['params_df1_pro_water','params_df1_pro_waste', 'params_df1_pro_other','params_df1_manage_watersaving','params_df1_manage_renewable']

params = dict.fromkeys(labels, {})

params.update({'params_df1_pro_water' :
    {
        'ceparema': 'CEPA2',
        'GEO': 'EU27_2020',
        'nace_r2':'TOTAL',
        'na_item': 'B1G',
        'sinceTimePeriod': '2000',
        'ty': 'TOT_EGSS',
        'unit':'MIO_EUR',
        'precision': 1
    },
    'params_df1_pro_waste' :
    {
        'ceparema': 'CEPA3',
        'GEO': 'EU27_2020',
        'nace_r2':'TOTAL',
        'na_item': 'B1G',
        'sinceTimePeriod': '2000',
        'ty': 'TOT_EGSS',
        'unit':'MIO_EUR',
        'precision': 1
    },
    'params_df1_pro_other' :
    {
        'ceparema': ('CEPA1','CEPA4','CEPA5','CEPA6','CEPA7','CEPA7-9','CEPA8','CEPA812','CEPA9'),
        'GEO': 'EU27_2020',
        'nace_r2':'TOTAL',
        'na_item': 'B1G',
        'sinceTimePeriod': '2000',
        'ty': 'TOT_EGSS',
        'unit':'MIO_EUR',
        'precision': 1
    },
    'params_df1_manage_watersaving':
    {
        'ceparema': 'CREMA10',
        'GEO': 'EU27_2020',
        'nace_r2':'TOTAL',
        'na_item': 'B1G',
        'sinceTimePeriod': '2000',
        'ty': 'TOT_EGSS',
        'unit':'MIO_EUR',
        'precision': 1
    },
    'params_df1_manage_renewable':
    {
        'ceparema': ('CREMA13A','CREMA13B'),
        'GEO': 'EU27_2020',
        'nace_r2':'TOTAL',
        'na_item': 'B1G',
        'sinceTimePeriod': '2000',
        'ty': 'TOT_EGSS',
        'unit':'MIO_EUR',
        'precision': 1
    }
})

df = dict.fromkeys(labels)

[df.update({ds: client.get_dataset('env_ac_egss2', params = params[ds]).to_dataframe()}) for ds in df.keys()]


[params[lbl].update({'lastTimePeriod': '2017'}) for lbl in params]


[df.update({lbl: df[lbl][df[lbl].time <= params[lbl]['lastTimePeriod']]}) for lbl in df.keys()]

[df.update({lbl: df[lbl].loc[df[lbl]['geo']=='EU27_2020']}) for lbl in df.keys()]


values = dict.fromkeys(labels)
labels = ['params_df1_pro_water','params_df1_pro_waste', 'params_df1_pro_other','params_df1_manage_watersaving','params_df1_manage_renewable']

for lbl in labels:
    if lbl in ['params_df1_pro_water', 'params_df1_pro_waste','params_df1_manage_watersaving']:
        values.update({lbl: list(df[lbl]['values']/1000)})
    else:
        values.update({lbl: list(df[lbl].groupby(['time'])['values'].sum()/1000)})

######
def swapPositions(list, pos1, pos2):
    list[pos1], list[pos2] = list[pos2], list[pos1]
    return list

fig, ax = plt.subplots()
ax.xaxis.set_tick_params(labelsize='small')

plt.margins(x=0,y=0)


ax.yaxis.grid(zorder=0)


F = plt.gcf()
Size = F.get_size_inches()
F.set_size_inches(Size[0]*2, Size[1])

plt_labels=['Waste management','Wastewater management','Other environmental protection','Renewable energy and energy efficiency','Water saving']
plt.stackplot(df['params_df1_pro_water'].time ,tuple(swapPositions(list(values.values()),-1,-2)),labels=plt_labels,colors=['#5170d7','#d767ad','#13bbaf','#a2cffe','#acc2d9'],zorder=3)
plt.title('Gross value added of environmental economy, by domain, EU-27, 2000-2017\n(EUR billion)',fontweight='bold')
plt.legend(loc='lower center',fancybox=False, shadow=True,bbox_to_anchor=(0.5, -0.5),handlelength=0.7)

plt.show()

