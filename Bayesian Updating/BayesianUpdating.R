bayesianUpdating1 = function(mu_0,sigma_0,x,sigma2){
  #Posterior Mean and Variance as a function of the prior mean, prior variance, signals, and true signal variance  
  
  n       = length(x)
  postMu  = (mu_0/sigma2_0+sum(x)/sigma2)/(1/sigma2_0+n/sigma2)
  postVar = 1/(1/sigma2_0+n/sigma2)
  
  t(c(postMu,postVar))
  
}

set.seed(1)
n = 200      # observations
mu_0 = 1     # prior mean
sigma2_0 = 2 # prior variance
mu = -3      # true mean
sigma2 = 3   # signal variance
x = rnorm(n,mu,sqrt(sigma2))

#store the output
out1 = data.frame(postMu=NA,postVar=NA)
for(i in 1:n){
  
  out1[i,1] = (mu_0/sigma2_0+sum(x[1:i])/sigma2)/(1/sigma2_0+i/sigma2) #Posterior Mean
  out1[i,2] = 1/(1/sigma2_0+i/sigma2)                                  #Posterior Variance
  
}

library(ggplot2)
qplot(x=1:n,y=out1[,1],geom="line")+theme_bw(15)+xlab("Observation") + ylab("Posterior Mean") + geom_hline(yintercept = mu,linetype="dashed")
qplot(x=1:n,y=out1[,2],geom="line")+theme_bw(15)+xlab("Observation") + ylab("Posterior Variance")

library(reshape2)
xseq  = seq(-5,5,length.out=500)
denx = apply(out1,1, function(x) dnorm(xseq, mean = x[1], sd = sqrt(x[2])))
denx = t(t(denx)/rowSums(t(denx))) #Proper way to normalize (/colSums won't work as expected)
denx.m = melt(denx)                #Put into long format
denx.m$Var1 = rep(xseq,n)

nsub=5
ggplot(subset(denx.m,Var2 <= nsub),aes(x = Var1, y = value, group = Var2,color=Var2)) + geom_line() + 
  scale_colour_gradient(limits=c(1,nsub))+theme_bw(15)+theme(legend.position="none")+
  geom_vline(xintercept = mu_0,linetype = "longdash") + geom_vline(xintercept = mu,color="sea green") + xlab("x") + ylab("") + ylim(c(0,.025))+ggtitle("5 Observations")

nsub=20
ggplot(subset(denx.m,Var2 <= nsub),aes(x = Var1, y = value, group = Var2,color=Var2)) + geom_line() + 
  scale_colour_gradient(limits=c(1,nsub))+theme_bw(15)+theme(legend.position="none")+
  geom_vline(xintercept = mu_0,linetype = "longdash") + geom_vline(xintercept = mu,color="sea green") + xlab("x") + ylab("") + ylim(c(0,.025))+ggtitle("20 Observations")

nsub=200
ggplot(subset(denx.m,Var2 <= nsub),aes(x = Var1, y = value, group = Var2,color=Var2)) + geom_line() + 
  scale_colour_gradient(limits=c(1,nsub))+theme_bw(15)+theme(legend.position="none")+
  geom_vline(xintercept = mu_0,linetype = "longdash") + geom_vline(xintercept = mu,color="sea green") + xlab("x") + ylab("") + ylim(c(0,.075))+ggtitle("200 Observations")

nx   = length(x)
sumx = sum(x)
ssx  = sum(x^2)

#new signal
sig1  = 2
xpsig = c(x,sig1)

nx   = nx + 1
sumx = sumx + sig1
ssx  = ssx + sig1^2

mean(xpsig);sumx/nx

var(xpsig);(ssx - (sumx*sumx)/nx)/(nx-1)

out2 = data.frame(postMu=NA,postVar=NA)
sumx = 0
ssx  = 0
for(i in 1:n){
  
  sig1 = x[i] #signal
  
  sumx = sumx + sig1
  ssx  = ssx + sig1^2
  xbar = sumx/i
  xvar = (ssx - (sumx*sumx)/i)/(i-1)
  
  if(i==1){
    postMu  = (mu_0 + sig1)/2
    postVar = sigma2_0 
  } else {
    postMu  = (mu_0/sigma2_0+sumx/xvar)/(1/sigma2_0+i/xvar)
    postVar = 1/(1/sigma2_0+i/xvar)
  }
  
  out2[i,1] = postMu
  out2[i,2] = postVar
}

out1$obs = 1:n
out1$cat = "Known"

out2$obs = 1:n
out2$cat = "Unknown"

outSum   = rbind(out1,out2)

ggplot(outSum,aes(x=obs,y=postMu,group=cat,color=cat)) + geom_line() + theme_bw(15) +
  ylab("Posterior Mean") + xlab("Observation") + scale_color_discrete(name="Signal Variance")

ggplot(outSum,aes(x=obs,y=postVar,group=cat,color=cat)) + geom_line() + theme_bw(15) +
  ylab("Posterior Variance") + xlab("Observation") + scale_color_discrete(name="Signal Variance")