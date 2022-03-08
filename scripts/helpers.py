import openpyxl
import pandas as pd
import numpy as np
from datetime import date
from dateutil.relativedelta import relativedelta

def dataframe(path):
    """
    Returns a dataframe given a xlsx file where each column is a sheet
    Parameters:
        path: os route of the file
    """
    sheets = openpyxl.load_workbook(path).sheetnames
    if len(sheets) == 1:
        df = pd.read_excel(path, index_col = "Date", usecols= sheets)
        return df
    else:
        df = pd.read_excel(path, index_col = "Date")
        df.rename(columns={"Mid Yield To Convention": sheets[0]}, inplace = True)
        for i in range(1,(len(sheets))):
            tempdf= pd.read_excel(path, index_col = "Date", sheet_name = i)
            tempdf.rename(columns={"Mid Yield To Convention":sheets[i]}, inplace = True)
            df = df.merge(tempdf, on= "Date")
        return df
    
def rateconverter(rate, T, today):
    """
    Returns a converted interest rate, for a desired maturity.
    Parameters:
        rate: yearly interest rate
        T: maturity in months
        today: current date, expressed as a DateTimeIndex
    """
    days = (today[0].date()+relativedelta(months=T) - today[0].date()).days
    newrate = rate*(days/360)
    rounded = np.around(newrate, 15)
    return rounded

def discountfactor(curve, T):
    """
    Returns the discount factor for a given maturity and forward curve
    Parameters:
        curve: forward curve
        T: maturity in months
        
    """
    intervals_r=[3,12,36,60,120]
    intervals_l=[0,3,12,36,60]
    mask = [(t<=T) for t in intervals_l]
    minimum = np.minimum(T, intervals_r)
    areas = np.around((minimum-intervals_l)*np.around(curve,9)*mask/12, 8)
    totalarea = np.sum(areas)    
    discountfactor = np.exp(-totalarea)
    rounded = np.around(discountfactor, 15)
    return discountfactor