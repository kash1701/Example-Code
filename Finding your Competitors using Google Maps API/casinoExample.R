#API documentation: https://developers.google.com/places/documentation/search
library(RJSONIO)
mycasinos = read.delim("my_casinos.txt",sep=",")
ncasinos  = nrow(mycasinos)

mycasinos

apikey    = "YOUR KEY HERE"
rooturl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
radius = 50000                            #radius around target casinos (in km)
Aradius=paste0("&radius=",radius)         #"A" stands for "&" in the variable name
Aapikey=paste0("&key=",apikey)
competitors = c("Golden Nugget","Casino") #keywords for our competitors

dat = NULL  #raw data list to store competitor information. NOTE: it will include duplicates
counter = 1 #allows for multiple pages of data for each target casino

#Outer loop over competitors
for(comp in 1:length(competitors)){
  
  name = competitors[comp]
  Aname=paste0("&name=",name)
  
  #Inner loop for each casino
  for(i in 1:ncasinos){
    latlong = paste(mycasinos[i,"lat"],mycasinos[i,"long"],sep=",")
    latlong = paste0("location=",latlong)
    
    url = URLencode(paste0(rooturl,latlong,Aradius,Aname,Aapikey))
    dat[[counter]]=fromJSON(url)
    
    #Continue loop if there is more data
    while (!is.null(dat[[counter]]$next_page_token)){
      url = URLencode(paste0(rooturl,latlong,Aradius,Aname,Aapikey,"&pagetoken=",dat[[counter]]$next_page_token))
      counter = counter+1
      Sys.sleep(2)                  #IF NOT INCLUDED, LOOP GOES TOO FAST AND WE GET INVALID REQUESTS
      dat[[counter]]=fromJSON(url)
    }
    
    counter = counter+1
  }
  print(comp)
}

ndat    = length(dat)
nextPage = NULL
for(i in 1:ndat) nextPage[i] = (is.null(dat[[i]]$next_page_token))*1 #= 0 if there is another page of data
compInd   = ceiling(cumsum(nextPage)/ncasinos)
casinoInd = cumsum(nextPage)%%ncasinos
casinoInd[casinoInd==0]=ncasinos

#Check status
status = NULL
for(i in 1:ndat) status[i] = dat[[i]]$status
table(status)

competitorsData = data.frame(compInd=numeric(),
                             locationId=numeric(),
                             placeID=character(),
                             name=character(),
                             vicinity=character(),
                             latComp=numeric(), 
                             longComp=numeric(),
                             casinoFlag=numeric(),
                             stringsAsFactors=FALSE) 

#Consolidate the lat/long data from the scape
res = 1
for(i in 1:ndat){
  
  if (dat[[i]]$status == "OK"){
    
    dati = dat[[i]]$results
    
    for(j in 1:length(dati)){
      competitorsData[res,1] = compInd[i]
      competitorsData[res,2] = mycasinos[casinoInd[i],1]
      competitorsData[res,3] = dati[[j]]$place_id
      competitorsData[res,4] = dati[[j]]$name
      competitorsData[res,5] = dati[[j]]$vicinity
      competitorsData[res,6] = as.numeric(dati[[j]]$geometry$location[1]["lat"])
      competitorsData[res,7] = as.numeric(dati[[j]]$geometry$location[2]["lng"])
      competitorsData[res,8] = ("casino" %in% dat[[i]]$results[[j]]$types)*1
      res=res+1
    }
  }
  print(i)
}

library(geosphere)

#Calculate distance to each target store
competitorsData = merge(competitorsData,mycasinos[,c("locationId","lat","long")],by="locationId")
competitorsData$distkm = distCosine(competitorsData[,c("longComp","latComp")],competitorsData[,c("long","lat")])/1000

#check distances for errors
summary(competitorsData$distkm)

#Add distance flags
competitorsData$distmile = competitorsData$distkm*0.621371 #km to miles
competitorsData$dist1M   = (competitorsData$distmile <= 1)*1
competitorsData$dist5M   = (competitorsData$distmile <= 5)*1
competitorsData$dist10M  = (competitorsData$distmile <= 10)*1

#List competitors within 50 miles
competitorSum = aggregate(cbind(dist1M,dist5M,dist10M)~locationId,data=subset(competitorsData,casinoFlag==1),FUN=sum)

subset(competitorsData,casinoFlag==1)[,c("locationId","name","distmile","dist1M","dist5M","dist10M")]

compSum = subset(competitorsData,casinoFlag==1 & distmile < 50)[,c("locationId","name","distmile","dist1M","dist5M","dist10M")]
compSum$distmile = round(compSum$distmile,1)
compSum = compSum[order(compSum$locationId,compSum$distmile),]

compSum

save.image("casinoCompetitors.Rdata")