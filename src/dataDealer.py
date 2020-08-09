'''
    Handels the conversion jsonStat forrmat to dataframe format
        and cleans the data for the plots
'''

import numpy as np
import pandas as pd
import sys

def subjason_to_DataFrame(lines, columns, subDict):
    nline = []
    M = np.zeros((len(lines), len(columns)))
    for i in range(len(lines)):
        if lines[i] == "":
            continue
        else:
            nline.append(lines[i])
        for j in range(len(columns)):
            M[i][j] = subDict[columns[j]][nline[i]]
    return pd.DataFrame(M, index=nline, columns=columns)

def clean_label(lines, remove_list={}):
    labels = [ '' if item in remove_list else item for item in lines]
    return labels

def json_to_data(lines, columns, values, remove_list=[], void_item=False, clean_dict={}):

    if void_item and not remove_list:
        print('[-] Invalid arguments, must set re,ove_list is void_item is True')
        sys.exit()
    d = {}
    j = 0
    for i in range(len(lines)):
        if clean_dict:
            for key in clean_dict:
                if key in lines[i]:
                    lines[i] = clean_dict[key]
        for k in range(len(columns)):
            if lines[i] not in remove_list:
                d[lines[i], columns[k]]= values[j]
            else:
                if void_item:
                    d[lines[i], columns[k]] = 0.
            j += 1
    if remove_list and not void_item:
        for item in remove_list:
            lines.remove(item)
    output = {}
    for i in range(len(columns)):
        output[columns[i]] = {}
        for j in range(len(lines)):
            output[columns[i]][lines[j]] = d[(lines[j], columns[i])]

    return output, lines
