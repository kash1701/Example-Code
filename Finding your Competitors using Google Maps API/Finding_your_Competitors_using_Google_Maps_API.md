# Finding your Competitors using Google Maps API
Wayne Taylor  
May 18, 2016  

## Who is your Competition?

Managers can easily access a list of their own stores, but obtaining a complete and up-to-date list of the competition is not always as straightforward. Below, I show how to use the Google Maps API to quickly find and summarize relevant competitors. In this stylized example, we take the role of Harrah's (a large casino operator) who wants to obtain a list of casinos located near a few of their current properties.

The full code and output is available in `casinoExample.R` and `casinoExample.Rdata` files.

## Step 0: Create an API Key

To use the Google Places API Web Service we will need an API key, which identifies the specific project to check quotas and access. The Google Places API allows for 1,000 requests per day for free. Once you are at the Google developers console, generating an API key is relatively straightforward: Simply create a new project and create the credentials for that project. Google's documentation on the specifics are very good so I will move on assuming that you've generated a key.

For more help, see this: https://support.google.com/cloud/answer/6158862?hl=en&ref_topic=6262490

## Step 1: Read in the Location Data

In this stylized example, I use three (real) casinos as the targets. Our goal is to find other casinos located near these target casinos.


```r
library(RJSONIO)
mycasinos = read.delim("my_casinos.txt",sep=",")
ncasinos  = nrow(mycasinos)

mycasinos
```

```
##   locationId                       casinoName          city state      lat
## 1          1 Harrah's Laughlin Casino & Hotel      Laughlin    NV 35.14412
## 2          2     Harrah's Reno Hotel & Casino          Reno    NV 39.52763
## 3          3    Harrah's Resort Atlantic City Atlantic City    NJ 39.38430
##         long
## 1 -114.57657
## 2 -119.81252
## 3  -74.42826
```

## Step 2: Set the URL Query Parameters

Next, I set some general parameters and create the root URL. Note that this example uses the "Nearby Search" option so that we can add keywords to the search area. I use the keywords "Casino" and "Golden Nugget" to highlight that general or specific names can be used. For example, if we were Walmart, we might be interested in finding "Target" specifically or "Discount Stores" in general.

See https://developers.google.com/places/web-service/search#PlaceSearchRequests for more details on the parameterization.


```r
apikey    = "YOUR KEY HERE"
rooturl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
radius = 50000                            #radius around target casinos (in km)
Aradius=paste0("&radius=",radius)         #"A" stands for "&" in the variable name
Aapikey=paste0("&key=",apikey)
competitors = c("Golden Nugget","Casino") #keywords for our competitors
```

## Step 3: Pull the Data

For each competitor listed (outer loop), figure out how far away each casino is located (inner loop). For example, on the very first outer and inner loop iteration, we are trying to match "Golden Nugget" near the Harrah's Laughlin location.

Note: if the results span more than one page, the API returns a "next page token" flag. This means that additional pages have to be pulled manually.


```r
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
```

## Step 4: Consolidate the Results

To account for the "next page" data, I create an index vector for the competitor and casino referenced to in the raw data list. Basically, if there is another page of data repeat the last casino.

Before consolidation, it is also a good idea to do a status check on the pulls. The status should read "OK".

Notice that I added flag for whether the word "casino" is in the Google description. This allows us to remove items that will show up in the casino search but are not actually casinos (e.g., a restaurant located within a casino).


```r
#Get casino and competitor index
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
```

## Step 5: Summarize the Data

Finally, by merging the consolidated data with the target list we can find the distance to each competitor using the `geosphere` library.


```r
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

competitorSum = aggregate(cbind(dist1M,dist5M,dist10M)~locationId,data=subset(competitorsData,casinoFlag==1),FUN=sum)

subset(competitorsData,casinoFlag==1)[,c("locationId","name","distmile","dist1M","dist5M","dist10M")]

#List competitors within 50 miles
compSum = subset(competitorsData,casinoFlag==1 & distmile < 50)[,c("locationId","name","distmile","dist1M","dist5M","dist10M")]
compSum$distmile = round(compSum$distmile,1)
compSum = compSum[order(compSum$locationId,compSum$distmile),]
```


```
                        targetCasino
1   Harrah's Laughlin Casino & Hotel
69      Harrah's Reno Hotel & Casino
79      Harrah's Reno Hotel & Casino
68      Harrah's Reno Hotel & Casino
75      Harrah's Reno Hotel & Casino
77      Harrah's Reno Hotel & Casino
66      Harrah's Reno Hotel & Casino
78      Harrah's Reno Hotel & Casino
59      Harrah's Reno Hotel & Casino
60      Harrah's Reno Hotel & Casino
128    Harrah's Resort Atlantic City
                                        name distmile
1        Golden Nugget Casino Hotel Laughlin      0.7
69                     Eldorado Resorts, Inc      0.4
79                     Gold Dust West Casino      0.7
68               John Ascuaga's Nugget Hotel      2.9
75                      Carson Plains Casino     22.2
77                         Gold Ranch Casino     23.0
66                 Jim Kelley's Tahoe Nugget     23.1
78                           Cal Neva Casino     23.3
59                        Carson City Nugget     25.1
60                            Fernley Nugget     31.4
128 Golden Nugget Casino Hotel Atlantic City      0.3
```
