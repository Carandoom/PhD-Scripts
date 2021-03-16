# 
# R script
# 
# Test to generate random data to model traces looking
# like store-operated calcium entry signaling
#

# Create a series of values for x timepoints
# and get statistics in a the given range

# Generate data
x = seq(0,250,2) # timepoint values
nbX = length(x) # number of timepoints
nbY = 25 # number of cells (y datasets)

y = matrix(NA,nbX,nbY)
# generate random data and store it into matrix
for (i in 1:nbY) {
  a <- runif((nbX/9)*3, min=0.35, max=0.45)
  b <- runif(nbX/9, min=0.45, max=0.55)
  c <- runif(nbX/9, min=0.55, max=0.75)
  d <- runif(nbX/9, min=0.70, max=1)
  nbXe <- nbX-length(c(a,b,c,d))
  e <- runif(nbXe, min=0.95, max=1.05)
  yVal = c(a,b,c,d,e)
  y[,i] <- yVal
  # plot the data / can be removed
  plot(x,y[,i])
  Sys.sleep(0.5)
}
