#
# Generate random data looking like SOCE data in order to 
# work with biologicaly looking data 
#

# import libraries
import numpy as np
import matplotlib.pyplot as plt

# set number of time points and number of cells
x = 100
y = 25

# create the different array to store data in
a = np.random.randint(0.3,0.5, size=(round(x/5),y))
b = np.random.randint(0.5,0.7, size=(round(x/5),y))
c = np.random.randint(0.65,0.9, size=(round(x/5),y))
d = np.random.randint(0.9,1.5, size=(round(x/5),y))
e = np.random.randint(1.45,1.55, size=(round(x/5),y))
SOCE = np.concatenate(a,b,c,d,e, axis=0)
x = SOCE.shape[0]

# plot the SOCE trace corresponding to cell 3
plt.plot(x, SOCE)
