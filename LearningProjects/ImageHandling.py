#
# Open image and store data into array then enhance signal,
# create threshold and extract features based on it
# initialy planned for cell detection based on FURA fluorescence
#

# import the modules
import numpy as np
import matplotlib.pyplot as plt
from skimage import data

# open image sample
I = data.cell()

# enhance image | Bg subtraction


# get threshold
thr = I > 100
I2 = I
I2[thr] = 1
I2[~thr] = 0
plt.imshow(I)
