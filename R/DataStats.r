#
# R script
# 
# Script to open my data from txt file, the first column
# contains my x values and the others are my y values.
# The script will get the average, sd and sem of the y values.
# 
# Christopher HENRY - V1 - 2021-02-23
# 


# Read text file containing my data
file <- "C:\\Users\\henryc\\Desktop\\GitHub\\Matlab find slope\\DataTest.txt"
T <- read.delim(file, header = FALSE, sep = "\t", dec = ".",)
x <- T[,1]
T <- T[,-1]
MeanY = apply(T, 1, mean, na.rm=TRUE)
MeanY.sd = apply(T, 1, sd, na.rm=TRUE)
MeanY.sem = MeanY.sd/sqrt(ncol(T))

plot(x=NULL, y=NULL,
     xlim=c(min(x),max(x)),
     ylim=c(min(T,na.rm=TRUE),max(T,na.rm=TRUE)))
for (i in 1:ncol(T)) {
  lines(x,T[,i], col="black")
}
lines(x,MeanY, col="red", type = "l", lwd=4,)
arrows(x0=x,y0=MeanY-MeanY.sd,x1=x,y1=MeanY+MeanY.sd,code=3,angle=90,length=0.1)
