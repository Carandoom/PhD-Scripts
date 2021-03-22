#
# Generate random data looking like SOCE data in order to 
# work with biologicaly looking data 
#

# import libraries
import numpy as np
import matplotlib.pyplot as plt

# set number of time points and number of cells
x = 800
y = 25

# create the different array to store data in
a = np.random.randint(3,15, size=(round(x/10),y))
b = np.random.randint(12,25, size=(round(x/25),y))
c = np.random.randint(20,55, size=(round(x/25),y))
d = np.random.randint(50,70, size=(round(x/20),y))
e = np.random.randint(65,72, size=(round(x/10),y))
SOCE = np.concatenate((a,b,c,d,e), axis=0)
x = SOCE.shape[0]

# plot the SOCE trace corresponding to cell 3
plt.plot(SOCE[:,3], 'ro')
