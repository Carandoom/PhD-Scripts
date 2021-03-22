#
# Generate random data looking like SOCE data in order to 
# work with biologicaly looking data 
#

# import libraries
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

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

# get average from all the cells
avgSOCE = np.mean(SOCE, axis=1)

# create a linear poly fit of order 2 to the averaged data
FitSOCE = np.polynomial.polynomial.Polynomial.fit(range(x), avgSOCE, 3).convert().coef
FitFunction = FitSOCE[3]*np.power(range(x),3) + FitSOCE[2]*np.power(range(x),2) + FitSOCE[1]*range(x) + FitSOCE[0]

# create subplot 2,1
fig, (ax1,ax2) = plt.subplots(2)

# plot the SOCE average data and the fit
ax1.plot(avgSOCE, 'ro')
ax1.plot(FitFunction, 'b')

# alternatively, use scipy to fit the data
def line(x, a, b, c, d):
    return a * np.power(x,3) + b * np.power(x,2) + c * x + d
popt, pcov = curve_fit(line, range(x), avgSOCE)
FitFunctionSciPy = popt[0]*np.power(range(x),3) + popt[1]*np.power(range(x),2) + popt[2]*range(x) + popt[3]

ax2.plot(avgSOCE, 'ro')
ax2.plot(FitFunctionSciPy, 'b')
