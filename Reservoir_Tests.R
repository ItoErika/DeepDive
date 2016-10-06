# Take a random sample of AquiferSentences to check accuracy
AquiferMatchList<-lapply(AquiferSentences,function(x) sample(unlist(x),1,replace=FALSE,prob=NULL))
# AqSample<-sample(AquiferMatchlist,100,replace=FALSE,prob=NULL)
# Create a data frame of matched sentences from the sample
# SampleUnits<-names(AqSample)
# SampleSentences<-UnitSentences[SampleUnits]
# names(SampleSentences)<-names(AqSample)

# AqSampRows<-vector(length=length(SampleSentences))
# for (Unit in 1:length(SampleSentences)){
    # AqSampSents[Unit]<-SampleSentences[[Unit]][as.numeric(ASample[Unit])]
    # }

# AqSampSents<-sapply(AqSampRows,function(x)CleanedWords[x])
# SampleFrame<-data.frame(SampleUnits,AqSampRows,AqSampSents)
# write.csv(SampleFrame,file="SampleFrame.csv",row.names=FALSE)
