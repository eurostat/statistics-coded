'''
    Handels the conversion jsonStat forrmat to dataframe format
'''

import numpy as np
import pandas as pd
import sys

def subjason_to_DataFrame(lines, column, subDict):
    M = np.zeros((len(lines), len(column)))
    for i in range(len(lines)):
        for j in range(len(column)):
            M[i][j] = subDict[column[j]][lines[i]]
    return pd.DataFrame(M, index=lines, columns=column)

def json_to_data(lines, columns, values, remove_lines=False, remove_list=[]):
    if not remove_lines and remove_list:
        print('[-] Invalid arguments, Cannot set remove_list when remove_lines is set to False')
        sys.exit()
    d = {}
    j = 0
    for i in range(len(lines)):
        for k in range(len(columns)):
            if lines[i] not in remove_list:
                d[lines[i], columns[k]]= values[j]
            j += 1
    if remove_lines == True:
        for item in remove_list:
            lines.remove(item)
    output = {}
    for i in range(len(columns)):
        output[columns[i]] = {}
        for j in range(len(lines)):
            output[columns[i]][lines[j]] = d[(lines[j], columns[i])]
    return output, lines
