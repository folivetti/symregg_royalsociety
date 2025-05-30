import numpy as np 
import pandas as pd 
import sys 
import glob 

tot = []
for f in glob.glob(f"{sys.argv[1]}/*.csv"):
    try:
        df = pd.read_csv(f)
        tot.append(-df.fitness.max())
        #print(tot[-1])
    except:
        print("ERROR IN: ", f)
print("SUMMARY:")
print(np.mean(tot))
print(np.std(tot))
print(np.min(tot))
