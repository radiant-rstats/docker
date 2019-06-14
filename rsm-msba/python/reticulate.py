## based on https://pandas.pydata.org/pandas-docs/stable/cookbook.html
import pandas as pd

df_org = pd.DataFrame(
  {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}
)
df = df_org
df

df.loc[df.AAA >= 5,'BBB'] = -1
df

df.loc[df.AAA >= 5,['BBB','CCC']] = 555
df

df = df_org

dflow = df[df.AAA <= 5]
dflow

dfhigh = df[df.AAA > 5]
dfhigh

df = df_org

newseries = df.loc[(df['BBB'] < 25) & (df['CCC'] >= -40), 'AAA']
newseries

df.loc[(df['BBB'] > 25) | (df['CCC'] >= 75), 'AAA'] = 0.1
df

df = df_org

aValue = 43.0

df.loc[(df.CCC-aValue).abs().argsort()]

df = df_org

Crit1 = df.AAA <= 5.5
Crit2 = df.BBB == 10.0
Crit3 = df.CCC > -40.0

AllCrit = Crit1 & Crit2 & Crit3
CritList = [Crit1,Crit2,Crit3]

import functools
AllCrit = functools.reduce(lambda x,y: x & y, CritList)

df[AllCrit]

df = df_org

df[(df.AAA <= 6) & (df.index.isin([0,2,4]))]

data = {'AAA' : [4,5,6,7], 'BBB' : [10,20,30,40],'CCC' : [100,50,-30,-50]}
df = pd.DataFrame(data=data,index=['foo','bar','boo','kar']); df

df.loc['bar':'kar'] #Label

df.iloc[0:3]
df.loc['bar':'kar']

df2 = pd.DataFrame(data=data,index=[1,2,3,4]) #Note index starts at 1.
df2

df2.iloc[1:3] #Position-oriented
df2.loc[1:3]  #Label-oriented

df = df_org

df[~((df.AAA <= 6) & (df.index.isin([0,2,4])))]

rng = pd.date_range('1/1/2013',periods=100,freq='D')

import numpy as np
data = np.random.randn(100, 4)

cols = ['A','B','C','D']

df1, df2, df3 = pd.DataFrame(data, rng, cols), pd.DataFrame(data, rng, cols), pd.DataFrame(data, rng, cols)

source_cols = df.columns # or some subset would work too.
new_cols = [str(x) + "_cat" for x in source_cols]
categories = {1 : 'Alpha', 2 : 'Beta', 3 : 'Charlie' }

df[new_cols] = df[source_cols].applymap(categories.get);df

df = pd.DataFrame(
  {'AAA' : [1,1,1,2,2,2,3,3], 'BBB' : [2,1,3,4,5,1,2,3]}
)
df

df.loc[df.groupby("AAA")["BBB"].idxmin()]

df.sort_values(by="BBB").groupby("AAA", as_index=False).first()

df = pd.DataFrame(
  {'row' : [0,1,2],
    'One_X' : [1.1,1.1,1.1],
    'One_Y' : [1.2,1.2,1.2],
    'Two_X' : [1.11,1.11,1.11],
    'Two_Y' : [1.22,1.22,1.22]}
)
df

# As Labelled Index
df = df.set_index('row')
df

df.columns = pd.MultiIndex.from_tuples([tuple(c.split('_')) for c in df.columns])
df

df = df.stack(0).reset_index(1)
df

df.columns = ['Sample','All_X','All_Y'];df

cols = pd.MultiIndex.from_tuples([ (x,y) for x in ['A','B','C'] for y in ['O','I']])

df = pd.DataFrame(np.random.randn(2,6),index=['n','m'],columns=cols); df
df = df.div(df['C'],level=1); df

coords = [('AA','one'),('AA','six'),('BB','one'),('BB','two'),('BB','six')]
index = pd.MultiIndex.from_tuples(coords)

df = pd.DataFrame([11,22,33,44,55],index,['MyData'])
df

## Use exit to close the REPL
exit
