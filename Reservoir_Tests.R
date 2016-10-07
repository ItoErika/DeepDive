
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

# Create a matrix of unit hits locations with corresponding unit names
LongUnitHitsLength<-pbsapply(LongUnitHits,length)
# Create a column so the match locations can be correlated to the matched unit name
LongUnitNames<-rep(names(LongUnitHits),times=LongUnitHitsLength)
# Bind the long unit name column to the corresponding row location
LongUnitLookUp<-cbind(LongUnitNames,unlist(LongUnitHits))
# convert matrix to data frame
LongUnitLookUp<-as.data.frame(LongUnitLookUp)

# Name column denoting row locations within Cleaned Words
colnames(LongUnitLookUp)[2]<-"MatchLocation"
# Make sure the column data is numerical
LongUnitLookUp[,"MatchLocation"]<-as.numeric(as.character(LongUnitLookUp[,"MatchLocation"]))
    
# Make a table showing the number of long unit names which occur in each row that we know has at least one long unit match
RowHitsTable<-table(LongUnitLookUp[,"MatchLocation"])
# Locate and extract rows which contain only one long unit
# Remember that the names of RowHitsTable correspond to rows within CleanedWords
SingleHits<-as.numeric(names(RowHitsTable)[which((RowHitsTable)==1)])    
    
# Subset LongUnitLookUp to get dataframe of Cleaned Words rows and associated single hit long unit names
LongHitTable<-subset(LongUnitLookUp,LongUnitLookUp[,"MatchLocation"]%in%SingleHits==TRUE)    

# Extract the CleanedWords rows that contain a single long unit name AND the word "aquifer"
Start<-print(Sys.time())   
AquiferHits<-grep("aquifer",CleanedWords[LongHitTable[,"MatchLocation"]], ignore.case=TRUE, perl=TRUE)
End<-print(Sys.time())

# Note that AquiferHits refers to rows within LongHitTable 
# Subset LongHitTable to get a data frame representing CleanedWords rows which contain a single long unit name and the word "aquifer"
AquiferUnitHitTable<-LongHitTable[c(unlist(AquiferHits)),]
# Add column of the CleanedWords sentences to the AqSamp data frame
Sentences<-CleanedWords[AquiferUnitHitTable[,"MatchLocation"]]
AquiferUnitHitTable<-cbind(AquiferUnitHitTable,Sentences)
# Extract aquifer names
Aquifers<-unique(AquiferUnitHitTable[,"LongUnitNames"])

# Take a sample of 100 random rows of AquiferUnitHitTable to test the accuracy of the Reservoir app
AqSamp<-AquiferUnitHitTable[sample(nrow(AquiferUnitHitTable), 100), ]

# Export the AqSamp data frame as a csv
write.csv(AqSamp,file="SampleFrame2.csv",row.names=FALSE)
# Open the CSV and manually check for accuracy in excel or libre office

 



