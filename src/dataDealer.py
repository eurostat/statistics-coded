'''
    Handels the conversion jsonStat forrmat to dataframe format
        and cleans the data for the plots
'''

import numpy as np
import pandas as pd
import sys

def check_data_by_status(data, toZero=False):
    missing_index = []
    for key in data['status']:
        if data['status'][key] == ':':
            missing_index.append(key)
    for item in missing_index:
        r = None
        if toZero:
            r = 0
        data['value'][item] = r
    indexes = [int(item) for item in list(data['value'].keys())]
    indexes.sort()
    values = []
    for item in indexes:
        values.append(data['value'][str(item)])
    return values

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

def create_d(lines,columns, values, remove_list,invert=False, void_item=False):
    d = {}
    if invert:
        j = 0
        for i in range(len(columns)):
            for k in range(len(lines)):
                if lines[k] not in remove_list:
                    d[lines[k], columns[i]] = values[j]
                else:
                    if void_item:
                        d[lines[k], columns[i]] = 0.
                j += 1
    return d


def json_to_data(lines, columns, values, remove_list=[], void_item=False, clean_dict={}, multiple_key=""):

    if void_item and not remove_list:
        print('[-] Invalid arguments, must set re,ove_list is void_item is True')
        sys.exit()
    for i in range(len(lines)):
        if clean_dict:
            for key in clean_dict:
                if key in lines[i]:
                    lines[i] = clean_dict[key]
    d = {}
    j = 0
    remove = remove_list
    if multiple_key != 'time' and multiple_key != '':
        d = create_d(lines=lines, columns=columns, values=values, remove_list=remove, invert=True, void_item=True)
    else:
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
            try:
                lines.remove(item)
            except:
                continue
    output = {}
    for i in range(len(columns)):
        output[columns[i]] = {}
        for j in range(len(lines)):
            output[columns[i]][lines[j]] = d[(lines[j], columns[i])]

    return output, lines
