# SVN header
#$Date:  $
#$Revision: $
#$Author: $
#$ID: $

setwd("../../")

library(doBy)
library(foreign)
source("macros/R/Forestplot.R")
data<-data.frame(read.dta("tempdata/Stata/coxforest.dta",convert.factors=TRUE))



data<-orderBy(~sort1+sort2+sort3,data=data)

Pmain<-unique(data$Columns)

Plab2 <-c(data$RefFlag[1], data$level[1])

plotdata<- list()
for (i in seq_along(unique(data$Columns))){
  sub<- subset(data, Columns==unique(data$Columns)[i])
  sub<- sub[!is.na(sub$HR),]
  plotdata[[i]] <- sub
}

Xlim <- list()
for(i in seq_along(unique(data$Columns))){
  lores <- floor(min(plotdata[[i]][c("HRl")],na.rm=TRUE)*100)/100
  hires <- ceiling(max(plotdata[[i]][c("HRu")],na.rm=TRUE)*100)/100
  if (lores > 1){
    lores <- .8
  }
  if (hires < 1){
    hires <- 1.2
  }
  Xlim[[i]] <- c(lores,hires)
}

Hadj <- list()
for(i in seq_along(unique(data$Columns))){
  hr <- c(min(plotdata[[i]]$HR, na.rm=TRUE), max(plotdata[[i]]$HR, na.rm=TRUE))
  if (hr[2]< 1){
    hr <- c(hr[1]-1,0)
  }  else{
      if (hr[1] > 1){
          hr <- c(0,hr[2]-1)
      }      else{
          hr <- c(hr[1]-1,hr[2]-1)
      }
  }
  adj <- mean(hr)
  Hadj[[i]] <- adj
}

Ppos <- list()
for(i in seq_along(unique(data$Columns))){
  lores <- 3*abs(1-Xlim[[i]][1])/4
  hires <- 3*abs(Xlim[[1]][2]-1)/4
  if (min(plotdata[[i]]$HR,na.rm=TRUE)>1){
    lores <- .4
  }
  if (max(plotdata[[i]]$HR<1,na.rm=TRUE)){
    hires <- .4
  }
  Ppos[[i]] <- rep(max(c(lores,hires)),2)
}

if(length(grep("seq",names(data)))>1){
  Seq<- as.numeric(data[1,grep("seq", names(data))])
}else{
  Seq = NULL
}

Glab = data$GrpLab[1]
Rlab = data$RowLab[1]

#create pdf, possibly adjust dimensions
pdf(file="out/forestplot.pdf", width =16.7, height=6.5)
print(Forestplot("Group",
                 "Rows",
                 c("HR","HRl","HRu"),
                 plotdata,
                 fvaltab=TRUE,
                 fval="fval",
                 glab=Glab,
                 rlab=Rlab,
                 pmain=Pmain,
                 ppos=Ppos,
                 xlim=Xlim,
                 hadj=Hadj,
                 gcex=1.5,
                 rcex=1.2,
                 seqn=Seq,
                 log=FALSE,
                 plab2=Plab2))
dev.off()

postscript(file="out/forestplot.pdf", width = 16.7, height = 6.5, onefile=FALSE)
print(Forestplot("Group",
                 "Rows",
                 c("HR","HRl","HRu"),
                 plotdata,
                 fvaltab=TRUE,
                 fval="fval",
                 glab=Glab,
                 rlab=Rlab,
                 pmain=Pmain,
                 ppos=Ppos,
                 xlim=Xlim,
                 hadj=Hadj,
                 gcex=1.5,
                 rcex=1.2,
                 seqn=Seq,
                 plab2=Plab2))
dev.off()
