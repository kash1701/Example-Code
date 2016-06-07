library(data.table);
library(maps);
library(maptools);
library(spatstat);
library(zipcode);
library(GISTools)

#load the zipcode dataset
data(zipcode);

#long/lat boundaries for the "state" map
longitudeLimits = c(-130, -53)
latitudeLimits  = c(20, 60)

#SIMULATE CUSTOMER DATA----------------------------------------
N = 10000 #number of customers
customerData = data.frame(id = 1:N)

#Randomly append zip codes to the gamblers
set.seed(1);zipind = sample(nrow(zipcode),N,replace=TRUE)
customerData$zip       = zipcode$zip[zipind]
customerData$latitude  = zipcode$latitude[zipind]
customerData$longitude = zipcode$longitude[zipind]
customerData$sales     = rnorm(N,500,100)

#POINTS PLOT OF CUSTOMER DISTRIBUTION-----------------------------
#add random jitter to each data point so they are not stacked on top of each other in high density areas
longitudeJitterSize = diff(range(longitudeLimits))/5000
latitudeJitterSize  = diff(range(latitudeLimits))/5000
longitudeJitters    = runif(nrow(customerData), -longitudeJitterSize, longitudeJitterSize)
latitudeJitters     = runif(nrow(customerData), -latitudeJitterSize, latitudeJitterSize)

#Create the map
png(filename="pointsmap customer distribution.png", bg="white", width=8.*960, height=5.*960, pointsize=1)          #saves a png file to the working directory
map("state", col="white", fill=TRUE, bg="#FFFFFF", lwd=4.0, xlim=longitudeLimits, ylim=latitudeLimits)             #loads the US state map
map("state", col="black", lwd=1.0, xlim=longitudeLimits, ylim=latitudeLimits, add=TRUE)                            #adds state borders to the map
points(customerData$longitude+longitudeJitters, customerData$latitude+latitudeJitters, col="blue", pch=19, cex=20) #draws the points on the map
dev.off()
#Note: you may need to adjust "cex" parameter depending on the amount of data being mapped

#HEATMAP DATA PREP AND PARAMETERS ---------------------
customerDataDT = data.table(customerData)
customerDataDT[, zipCount:=.N, by=list(zip)]            #count all customers in a zip
customerDataDT[, salesSum:= sum(sales), by=list(zip)]   #sum of sales by zip
#keep only one row for each zip code
customerSum = unique(customerDataDT[,list(zip,latitude,longitude,zipCount,salesSum)])
customerSum = subset(customerSum,!is.na(latitude))   #remove zip codes with no lat/long information

spatstat.options(npixel=c(1000,1000)); #sets the granularity of the map detail
my.palette = colorRampPalette(c("black", "gray", "orange", "white"), bias=5, space="rgb")                      #parameters for the heat map colors
points = ppp(customerSum[, longitude], customerSum[, latitude], longitudeLimits, latitudeLimits, check=FALSE)  #creates the points on a two dimensional plane (the map)

#HEATMAP OF CUSTOMER DISTRIBUTION--------------------------------
png(filename="heatmap customer distribution.png", bg="white", width=8.*960, height=5.*960, pointsize=1)
densitymap = density(points, sigma=0.15, weights=customerSum[,zipCount])                                 #Zip count could be changed to any other metric
map("state", col="#000000", fill=TRUE, bg="#FFFFFF", lwd=1.0, xlim=longitudeLimits, ylim=latitudeLimits) #loads the US state map
image(densitymap, col=my.palette(40), add=TRUE)                                                          #adds the heatmap image
map("state", col="white", lwd=4.0, xlim=longitudeLimits, ylim=latitudeLimits, add=TRUE)                  #adds state borders
dev.off()
#Note: the "weights" parameter in the 'density' function determines how much 
#mass should be attributed to each point and represents the metric we want to plot.

#HEATMAP OF SALES--------------------------------
png(filename="heatmap sales distribution.png", bg="white", width=8.*960, height=5.*960, pointsize=1)
densitymap = density(points, sigma=0.15, weights=customerSum[,salesSum])
map("state", col="#000000", fill=TRUE, bg="#FFFFFF", lwd=1.0, xlim=longitudeLimits, ylim=latitudeLimits)
image(densitymap, col=my.palette(40), add=TRUE)
map("state", col="white", lwd=4.0, xlim=longitudeLimits, ylim=latitudeLimits, add=TRUE)
dev.off()