# Load Libraries
library("RPostgreSQL")
library("doParallel")
library("pbapply")
library("RCurl")
library("data.table")

#Connet to PostgreSQL
#Driver <- dbDriver("PostgreSQL") # Establish database driver
#Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")

#DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_master")

# Load DeepDiveData 
DeepDiveData<- fread("~/Desktop/R/DeepDiveData.csv")
DeepDiveData<-as.data.frame(DeepDiveData)

# Extract columns of interest from DeepDiveData
GoodCols<-c("docid","sentid","wordidx","words","poses","dep_parents")
DeepDiveData<-DeepDiveData[,(names(DeepDiveData)%in%GoodCols)]

# Remove symbols 
DeepDiveData[,"words"]<-gsub("\\{|\\}","",DeepDiveData[,"words"])
DeepDiveData[,"poses"]<-gsub("\\{|\\}","",DeepDiveData[,"poses"])
# Make a substitute for commas so they are counted correctly as elements for future functions
DeepDiveData[,"words"]<-gsub("\",\"","COMMASUB",DeepDiveData[,"words"])
DeepDiveData[,"poses"]<-gsub("\",\"","COMMASUB",DeepDiveData[,"poses"])

# Download dictionary of unit names from Macrostrat Database
# UnitsURL<-paste("https://dev.macrostrat.org/api/defs/strat_names?all&format=csv")
# GotURL<-getURL(UnitsURL)
# UnitsFrame<-read.csv(text=GotURL,header=TRUE)

#Extract a dictionary of long strat names from UnitsFrame
# UnitDictionary<-UnitsFrame[,"strat_name_long"]
# Add spaces to the front and back
# UnitDictionary<-pbsapply(UnitDictionary,function(x) paste(" ",x," ",collapse=""))

UnitsURL<-paste("https://macrostrat.org/api/units?project_id=1&format=csv")
GotURL<-getURL(UnitsURL)
UnitsFrame<-read.csv(text=GotURL,header=TRUE)

StratNamesURL<-paste("https://macrostrat.org/api/defs/strat_names?all&format=csv")
GotURL<-getURL(StratNamesURL)
StratNamesFrame<-read.csv(text=GotURL,header=TRUE)

Units<-merge(x = StratNamesFrame, y = UnitsFrame, by = "strat_name_id", all.x = TRUE)

# unit_id, col_id, lat, lng, unit_name, strat_name_long

GoodCols<-c("strat_name_id","strat_name_long","strat_name","unit_id","unit_name","col_id")
Units<-Units[,(names(Units)%in%GoodCols)]

UnitDictionary<-as.character(unique(Units[,"strat_name_long"]))
DeepDiveData.dt<-data.table(DeepDiveData)

# Create a function to that will search for unit names in DeepDiveData documents
findGrep<-function(Words,Dictionary) {
    CleanedWords<-gsub(","," ",Words)
    Match<-grep(Dictionary,CleanedWords,ignore.case=TRUE)
    return(Match)    
    }

findUnits<-function(DeepDiveData,Dictionary) {
    FinalList<-vector("list",length=length(Dictionary))
    names(FinalList)<-Dictionary
    progbar<-txtProgressBar(min=0,max=length(Dictionary),style=3)
    for (Unit in 1:length(Dictionary)) {
        FinalList[[Unit]]<-DeepDiveData[,sapply(.SD,findGrep,Dictionary[Unit]),by="docid",.SDcols="words"]
        setTxtProgressBar(progbar,Unit)
        }
    close(progbar)
    return(FinalList)
    }
 
UnitHits<-findUnits(DeepDiveData.dt,UnitDictionary)

# Establish a cluster for doParallel
# Make Core Cluster
#Cluster<-makeCluster(4)
# Pass the functions to the cluster
#clusterExport(cl=Cluster,varlist="findGrep")
    
# Search for unit names in DeepDiveData documents
findUnits<-function(Document,Dictionary) {
    CleanedWords<-gsub(","," ",Document["words"]) 
    #UnitHits<-parSapply(Cluster,Dictionary,findGrep,CleanedWords)
    UnitHits<-sapply(Dictionary,findGrep,CleanedWords)
    return(UnitHits)
    }

# Apply function to DeepDiveData documents
# Start<-print(Sys.time())
# UnitHits<-by(DeepDiveData,DeepDiveData[,"docid"],findUnits,UnitDictionary)
# End<-print(Start-Sys.time())

DeepDiveData.dt<-data.table(DeepDiveData[1:6000,])
UnitHits<-DeepDiveData.dt[,sapply(.SD,findUnits,UnitDictionary),by="docid",.SDcols=c("docid","words")]

# forloop

# Start<-print(Sys.time())
# hitUnits<-function(DeepDiveData,UnitDictionary) {
       #Documents<-unique(DeepDiveData[,"docid"])
       #FinalList<-vector("list",length=length(Documents))
       #progbar<-txtProgressBar(min=0,max=length(Documents),style=3)
       #for (Document in Documents) {
           #Subset<-subset(DeepDiveData,DeepDiveData[,"docid"]==Document)
           #FinalList[[Document]]<-findUnits(Subset,UnitDictionary)
           #setTxtProgressBar(progbar,Document)
           #}
       #close(progbar)
       #return(FinalList)
       #}

# Run batch loop on all DeepDiveDocuments
# UnitHits<-hitUnits(DeepDiveData[1:500,],UnitDictionary)
# End<-print(Start-Sys.time())

# Stop the cluster
# stopCluster(Cluster)
    




















##################################### Organize into Data Frame #########################################

# Create matrix of DDResults
DDResultsMatrix<-do.call(rbind,DDResults)
rownames(DDResultsMatrix)<-1:dim(DDResultsMatrix)[1]
DDResultsFrame<-as.data.frame(DDResultsMatrix)

# Ensure all columns are in correct format
DDResultsFrame[,"MatchedWord"]<-as.character(DDResultsFrame[,"MatchedWord"])
DDResultsFrame[,"WordPosition"]<-as.numeric(as.character(DDResultsFrame[,"WordPosition"]))
DDResultsFrame[,"Pose"]<-as.character(DDResultsFrame[,"Pose"])
DDResultsFrame[,"DocumentID"]<-as.character(DDResultsFrame[,"DocumentID"])
DDResultsFrame[,"SentenceID"]<-as.numeric(as.character(DDResultsFrame[,"SentenceID"]))

#################################### Isolate NNPs ############################################# 

# Subset so you only get NNP matches
DDResultsFrame<-subset(DDResultsFrame,DDResultsFrame[,3]=="NNP")

####################### Find NNps adjacent to DDResultsFrame Matches ##########################

# Pair document ID and sentence ID data for DeepDiveData
doc.sent<-paste(DeepDiveData[,"docid"],DeepDiveData[,"sentid"],sep=".")
# Make paired document and sentence data the row names for DeepDiveData
rownames(DeepDiveData)<-doc.sent
# Pair document ID and sentence ID data for 
docID.sentID<-paste(DDResultsFrame[,"DocumentID"],DDResultsFrame[,"SentenceID"],sep=".")
# Make a new column for paired document and sentence data in DDResultsFrame
DDResultsFrame[,"doc.sent"]=docID.sentID

# Create a subset of DeepDiveData that only contains data for document sentence pairs from DDResultsFrame
DDMatches<-DeepDiveData[unique(DDResultsFrame[,"doc.sent"]),]

# Make function to find NNP words in DDMatches
findNNPs<-function(Sentence) {
    SplitPoses<-unlist(strsplit(Sentence["poses"],","))
    SplitSentences<-unlist(strsplit(Sentence["words"],","))
    NNPs<-which(SplitPoses=="NNP")
    NNPWords<-SplitSentences[NNPs]
    return(cbind(NNPs,NNPWords))
    }
    
# Apply findNNPs function to DDMatches
NNPResults<-pbapply(DDMatches,1,findNNPs)

# Create matrix of NNPResults
NNPResultsMatrix<-do.call(rbind,NNPResults)
rownames(NNPResultsMatrix)<-1:dim(NNPResultsMatrix)[1]

# Add sentence ID data to NNPResultsMatrix
# Find the number of NNP matches for each sentence
MatchCount<-sapply(NNPResults,nrow)
# Create a column for NNPResultsMatrix for sentence IDs
NNPResultsMatrix<-cbind(NNPResultsMatrix,rep(names(NNPResults),times=MatchCount))
# Name the column
colnames(NNPResultsMatrix)[3]<-"SentID"

# Convert matrix into data frame to hold different types of data
NNPResultsFrame<-as.data.frame(NNPResultsMatrix)

# Make sure data in columns are in the correct format
NNPResultsFrame[,"NNPs"]<-as.numeric(as.character(NNPResultsFrame[,"NNPs"]))
NNPResultsFrame[,"NNPWords"]<-as.character(NNPResultsFrame[,"NNPWords"])
NNPResultsFrame[,"SentID"]<-as.character(NNPResultsFrame[,"SentID"])

##################################### Find Consecutive NNPs ######################################

findConsecutive<-function(NNPPositions) {
    Breaks<-c(0,which(diff(NNPPositions)!=1),length(NNPPositions))
    ConsecutiveList<-lapply(seq(length(Breaks)-1),function(x) NNPPositions[(Breaks[x]+1):Breaks[x+1]])
    return(ConsecutiveList)
    }

# Find consecutive NNPs for each SentID
Consecutive<-tapply(NNPResultsFrame[,"NNPs"], NNPResultsFrame[,"SentID"],findConsecutive)
# Collapse the consecutive NNP clusters into single character strings
ConsecutiveNNPs<-pbsapply(Consecutive,function(y) sapply(y,function(x) paste(x,collapse=",")))

######################### Find Words Associated with Conescutive NNPs ###########################

# Create a matrix with a row for each NNP cluster
# Make a column for sentence IDs
ClusterCount<-pbsapply(ConsecutiveNNPs,length)
SentID<-rep(names(ConsecutiveNNPs),times=ClusterCount)
# Make a column for cluster elements 
ClusterPosition<-unlist(ConsecutiveNNPs)
names(ClusterPosition)<-SentID
# Make a column for the words associated with each NNP
# Get numeric elements for each NNP
NNPElements<-lapply(ClusterPosition,function(x) as.numeric(unlist(strsplit(x,","))))
names(NNPElements)<-SentID


NNPWords<-vector("character",length=length(NNPElements))
progbar<-txtProgressBar(min=0,max=length(NNPElements),style=3)
for(Document in 1:length(NNPElements)){
    ExtractElements<-NNPElements[[Document]]
    DocumentName<-names(NNPElements)[Document]
    SplitWords<-unlist(strsplit(DDMatches[DocumentName,"words"],","))
    NNPWords[Document]<-paste(SplitWords[ExtractElements],collapse=" ")
    setTxtProgressBar(progbar,Document)
    }
close(progbar)

# Bind columns into data frame 
NNPClusterMatrix<-cbind(NNPWords,ClusterPosition,SentID)
rownames(NNPClusterMatrix)<-NULL
NNPClusterFrame<-as.data.frame(NNPClusterMatrix)

# Make sure all of the columns are in the correct data format
NNPClusterFrame[,"NNPWords"]<-as.character(NNPClusterFrame[,"NNPWords"])
NNPClusterFrame[,"ClusterPosition"]<-as.character(NNPClusterFrame[,"ClusterPosition"])
NNPClusterFrame[,"SentID"]<-as.character(NNPClusterFrame[,"SentID"])


# Find NNPClusterFrame rows in which unit names appear

# Combine all member, formation, group, and supergroup names into a single vector
AllUnitsDictionary<-c(unlist(Members),unlist(Formations),unlist(Groups),unlist(Supergroups))
# Find matches of AllUnitsDictionary in the NNPClusterFrame "NNPWords" column
MatchRows<-which(NNPClusterFrame[,"NNPWords"]%in%AllUnitsDictionary)

# Subset the NNPClusterFrame so that only CompleteMatchRows are shown
MatchFrame1<-data.frame(matrix(NA,ncol = 3, nrow = length(MatchRows)),stringsAsFactors=False)
progbar<-txtProgressBar(min=0,max=length(MatchRows),style=3)
for (Row in 1:length(MatchRows)){
    MatchFrame1[Row,]<-NNPClusterFrame[as.numeric(MatchRows[Row]),]
    setTxtProgressBar(progbar,Row)
    }
    close(progbar)
# Create column names for MatchFrame1 to match NNPClusterMatrix
colnames(MatchFrame1)<-colnames(NNPClusterFrame)
    
    
    
    # Find poses 
findPoses<-function(Document,Dictionary=SplitUnits) {
    SplitPoses<-unlist(strsplit(DocRow["poses"],","))
    SplitWords<-unlist(strsplit(DocRow[,"words"],","))
  	
    
    for(Unit in length(SplitUnits)){
           FoundWords<-SplitWords%in%SplitUnits
        
    FoundWords<-SplitWords%in%Dictionary
  	
  	# Create columns for final matrix
  	MatchedWord<-SplitWords[which(FoundWords)]
  	WordPosition<-which(FoundWords)
  	Pose<-SplitPoses[which(FoundWords)]
    DocumentID<-rep(DocRow["docid"],length(MatchedWord))
    SentenceID<-rep(DocRow["sentid"],length(MatchedWord))

    # Return the function output
    return(cbind(MatchedWord,WordPosition,Pose,DocumentID,SentenceID))
    }
  	
# Apply function to DeepDiveData documents
DDResults<-pbapply(DeepDiveData[50000:100000,],1,findPoses,UnitDictionary)
    
by(DeepDiveData,DeepDiveData[,"docid"],)
    
      	# Create columns for final matrix
    MatchedUnit<-
    DocumentID<-rep(DocRow["docid"],length(MatchedWord))
    SentenceID<-rep(DocRow["sentid"],length(MatchedWord))

