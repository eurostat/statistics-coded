'''
    Handels the conversion jsonStat forrmat to dataframe format
        and cleans the data for the plots
'''

import numpy as np
import pandas as pd
import sys

class Data:
    '''Not used for the moment'''
    def __init__(self, lines, columns, values, data):
        self.lines = lines
        self.columns = columns
        self.values = values
        self.data = data

'''
    Gives None (by default) or 0 value to the  missing fields

    params: dict: data: full json dictionary
    params: boolean: toZero: set the missing values to zero - by default set to False
    return: list: fully filled values list
'''
def check_data_by_status(data, toZero=False):
    missing_index = []
    for key in data['status']:
        if data['status'][key] == ':' or data['status'][key] == ':z' or data['status'][key] == 'p':
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

'''
    Converts a subjeson dictionary to a padas dataFrame

    params: list: lines: lines/indexes of the datarame
    params: columns: columns: columns labels of the dataframe
    params: dict: subDict: double key dictionary of values to be converted into dataFrame
    return: pandas.DataFrame: pandas dataframe of the input dictionary
'''
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

'''
    Sets to empty strings the labels to remove

    params: list: lines: lines labels of the data
    params: list: remove_list: list of the labels to remove
    return: list: cleaned labels
'''
def clean_label(lines, remove_list={}):
    labels = [ '' if item in remove_list else item for item in lines]
    return labels

'''
    Creates a first workable data dictionary to then easily tranform in a
        line-columns key form

    params: list: lines: line labels of the data
    params: list: columns: columns labels of the data
    params: list: values: values to order in the dictionary
    params: list: remove_list: list of labels to remove
    params: boolean: invert: swap line-columns from "classic" data extracted
    params: boolean: void_item: set to zero the values corresonding to the ingored labels. If
                                    set to False, these value are removed
    return: dict: workable data dictionary
'''
def create_d(lines,columns, values, remove_list,invert, void_item):
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
    else:
        j = 0
        for i in range(len(lines)):
            for k in range(len(columns)):
                if lines[i] not in remove_list:
                    d[lines[i], columns[k]]= values[j]
                else:
                    if void_item:
                        d[lines[i], columns[k]] = 0.
                j += 1

    return d

'''
    Creates a data dictionary to then easily tranform in a line-columns key form

    params: list: lines: line labels of the data
    params: list: columns: columns labels of the data
    params: list: values: values to order in the dictionary
    params: list: remove_list: list of labels to remove - by default empty
    params: boolean: void_item: set to zero the values corresonding to the ingored labels
                                    - by default set to Fale
    params: dict: clean_dict: dictionary of the labels to change and the new labels wanted
                                    - by default to empty
    params: str: nultple_key: way to iterate throught the jsonstat response
                                - by default empty or the way correponding to
                                    putting the time as columns
    return: dict: line-column key form dictionary
'''
def json_to_data(lines, columns, values, remove_list=[], void_item=False, clean_dict={}, multiple_key=""):

    if void_item and not remove_list:
        print('[-] Invalid arguments, must set re,ove_list is void_item is True')
        sys.exit()
    for i in range(len(lines)):
        if clean_dict:
            for key in clean_dict:
                if key in lines[i]:
                    lines[i] = clean_dict[key]

    if multiple_key != 'time' and multiple_key != '':
        d = create_d(lines=lines, columns=columns, values=values, remove_list=remove_list, invert=True, void_item=void_item)
    else:
        d = create_d(lines=lines, columns=columns, values=values, remove_list=remove_list, invert=False, void_item=void_item)

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
