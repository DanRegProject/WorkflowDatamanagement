# SVN header
#$Date:  $
#$Revision: $
#$Author: $
#$ID: $

#In general no need to edit this file

library(foreign)
source("../../macros/R/plotMSD.R")
data<-data.frame(read.dta(indatafile,convert.factors=TRUE))

pdf(file=paste(MSDfile,".pdf",sep=""),width=w,height=h)
print(plotMSD(data))
dev.off()

png(file=paste(MSDfile,".png",sep=""))
print(plotMSD(data))
dev.off()
