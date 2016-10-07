
######################################## EFFICIENCY TESTS #################################################





######################################## ACCURACY TESTS ###################################################


# TEST 1 
# Take a random sample of AquiferSentences to check accuracy
AquiferMatchList<-lapply(AquiferSentences,function(x) sample(unlist(x),1,replace=FALSE,prob=NULL))
AqSample<-sample(AquiferMatchlist,100,replace=FALSE,prob=NULL)
# Create a data frame of matched sentences from the sample
SampleUnits<-names(AqSample)
SampleSentences<-UnitSentences[SampleUnits]
names(SampleSentences)<-names(AqSample)

AqSampRows<-vector(length=length(SampleSentences))
for (Unit in 1:length(SampleSentences)){
    AqSampSents[Unit]<-SampleSentences[[Unit]][as.numeric(ASample[Unit])]
    }

AqSampSents<-sapply(AqSampRows,function(x)CleanedWords[x])
SampleFrame<-data.frame(SampleUnits,AqSampRows,AqSampSents)
write.csv(SampleFrame,file="SampleFrame.csv",row.names=FALSE)
    
    
# TEST 2
# Ignore sentences which return a character string that's too long to likely contain a valid intersection of "aquifer" and a unit name
# Average number of characters of accurate aquifer rows is 385, so set limit to 400

    
"S.K.I.P."

    
# TEST 3
# Try chopping rows with unit names in them down to 400 characters or less BEFORE searching for the word "aquifer" within those rows
    
# TEST 4
# Ignore sentences which contain too many "COMMASUB"s to avoid getting tables, legends, and captions in the final output.
    
# TEST 5 
# Eliminate sentences in which more than one unit names appears

colnames(LongUnitLookUp)[2]<-"MatchLocation"
LongUnitLookUp[,"MatchLocation"]<-as.numeric(as.character(LongUnitLookUp[,"MatchLocation"]))
    
AcceptableHits<-names(table(LongUnitLookUp))[which(table(LongUnitLookUp[,"MatchLocation"])==1)]
LongHitTable<-subset(LongUnitLookUp,LongUnitLookUp[,"MatchLocation"]%in%AcceptableHits==TRUE)    
    
Start<-print(Sys.time())   
AquiferHits<-grep("aquifer",CleanedWords[LongHitTable[,"MatchLocation"]], ignore.case=TRUE, perl=TRUE)
End<-print(Sys.time())
