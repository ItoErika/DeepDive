####################### IN POSTICO: Initial Creation of Data Table (ONLY RUN ONCE) #####################
In Postico
CREATE TABLE reservoir_data
(docid text, sentid integer, wordid integer[], words text[], poses text[], ners text[], lemmas text[], dep_paths text[], dep_parents integer []);
COPY reservoir_data FROM '/Users/erikaito/Documents/Erika_DeepDive/sentences_nlp352' WITH delimiter as '	';

################################ IN R: Load Required Libraries ##########################################
# Load Libraries
library("RPostgreSQL")
library("doParallel")
library(pbapply)
library(RCurl)

################################### Establish Postgresql Connection #####################################

# Connect to postgresql (if on erikaito)
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "erikaito", host = "localhost", port = 5432, user = "erikaito")
DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM reservoir_data")

#OR (if on labuser) 
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")
DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM reservoir_data")

###################################### Create Dictionaries ##############################################

#Select words of interest
ReservoirDictionary<-c("aquifer","reservoir","aquitard","aquiclude","water","oil","gas","coal","aquifuge")
# Make vector of upper case words and add it to the original vector
ReservoirDictionary<-c(ReservoirDictionary,gsub("(^[[:alpha:]])", "\\U\\1", ReservoirDictionary, perl=TRUE))

# Download dictionary of unit names from Macrostrat Database
UnitsURL<-paste("https://dev.macrostrat.org/api/units?project_id=1&format=csv")
GotURL<-getURL(UnitsURL)
UnitsFrame<-read.csv(text=GotURL,header=TRUE)

# Create a vector of all unique unit words
UnitsVector<-c(as.character(UnitsFrame[,"Mbr"]),as.character(UnitsFrame[,"Fm"]),as.character(UnitsFrame[,"Gp"]),as.character(UnitsFrame[,"SGp"]))
UnitsVector<-unique(UnitsVector)
Units<-subset(UnitsVector,UnitsVector!="")

######################## Split Unit Names in Units Vector into Individual Words ############################

#Create a dictionary list of matrices of split unit words
NumUnits<-1:length(Units)
UnitDictionary<-vector("list",length=length(Units))
for(UnitElement in NumUnits){
    UnitDictionary[[UnitElement]]<-unlist(strsplit(noquote(gsub(" ","SPLIT",Units[UnitElement])),"SPLIT"))
    }

###################### Isolate First Words in Each Word String of UnitDictionary #########################

# Pull out the first word of every matrix in the UnitDictionary list
FirstWords<-unique(sapply(UnitDictionary,function(x) x[1]))
# Minimize noise
FirstWords<-subset(FirstWords,FirstWords!="The")

############# Find Matches of FirstWords in Deep Dive Documents and the Pose for Each Match ##############

# Find matches of FirstWords in all of the DeepDiveData documents
# Get data for the word matches (word match, poses, documentID, and sentenceID)

findPoses<-function(DocRow,FirstDictionary=FirstWords) {
    CleanedWords<-gsub("\\{|\\}","",DocRow["words"])
    CleanedPoses<-gsub("\\{|\\}","",DocRow["poses"])
    SplitPoses<-unlist(strsplit(CleanedPoses,","))
    SplitWords<-unlist(strsplit(CleanedWords,","))
  	FoundWords<-SplitWords%in%FirstDictionary
  	
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
DDResults<-pbapply(DeepDiveData,1,findPoses,FirstWords)

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

# Make function to find NNP words adjacent to the matches in DDResultsFrame
findNNPs<-function(Sentence) {
    CleanedSentences<-gsub("\\{|\\}","",Sentence)
    CleanedPoses<-gsub("\\{|\\}","",Sentence["poses"])
    SplitPoses<-unlist(strsplit(CleanedPoses,","))
    SplitSentences<-strsplit(CleanedSentences,",")
    NNPs<-which(SplitPoses=="NNP")
    return(NNPs)
    }
    
# Apply findNNPs function to DDMatches
NNPResults<-pbapply(DDMatches,1,findNNPs)

##################################### Find Consecutive NNPs ######################################

findConsecutive<-function(NNPPositions) {
    Breaks<-c(0,which(diff(NNPPositions)!=1),length(NNPPositions))
    ConsecutiveList<-lapply(seq(length(Breaks)-1),function(x) NNPPositions[(Breaks[x]+1):Breaks[x+1]])
    return(ConsecutiveList)
    }

ConsecutiveResults<-lapply(NNPResults,findConsecutive)
 
 ######################### Find Words Associated with Conescutive NNPs ###########################
 matchWords<-function(Document){
    DDMatches[Document,"words"]
 
DDMatches["54eb194ee138237cc91518dc.1",]
 DDMatches["54e9e7f8e138237cc91513e9.976",]
 
 NNPWordResults<-pbapply(DDMatches,1,matchWords)
 
 ####################################### Find Word Matches #######################
 
 
############################## findParents Function (Not Needed) #################################

# write function to find parents of reservoir words in DeepDive documents
findParents<-function(DocRow,FirstDictionary=ReservoirDictionary) {
    CleanedWords<-gsub("\\{|\\}","",DocRow["words"])
    CleanedWords<-gsub("\",\"","COMMASUB",CleanedWords)
    CleanedParents<-gsub("\\{|\\}","",DocRow["dep_parents"])
    SplitParents<-unlist(strsplit(CleanedParents,","))
    SplitWords<-unlist(strsplit(CleanedWords,","))
    FoundWords<-SplitWords%in%FirstDictionary
    
    # Create columns for final matrix
    MatchedWords<-SplitWords[which(FoundWords)]
    FoundParents<-SplitWords[as.numeric(SplitParents[which(FoundWords)])]
    DocumentID<-rep(DocRow["docid"],length(MatchedWords))
    SentenceID<-rep(DocRow["sentid"],length(MatchedWords))
  	
    # Account for words with missing parents 
    if (length(FoundParents)<1) {
        FoundParents<-rep(NA,length(MatchedWords))
        }
  	    
    # Return the function output
    return(cbind(MatchedWords,FoundParents,DocumentID,SentenceID))
    }
  
# Apply findParents function to DeepDiveData to get matched words data
DDResults<-pbapply(DeepDiveData,1,findParents,ReservoirDictionary)
DDResultsMatrix<-do.call(rbind,DDResults)

##################################### Helpful Examples #############################################

# splitting unit names into separate words
Sub<-gsub(" ","SPLIT",UnitDictionary[8819])
SplitUnitsList<-strsplit(noquote(Sub),"SPLIT")
SplitUnits<-unlist(SplitUnitsList)
SplitUnitsList<-vector("list",length=length(UnitDictionary))
unlist(strsplit(noquote(gsub(" ","SPLIT",UnitDictionary[UnitElement])),"SPLIT"))



# Get word position of words in sentence that match FirstWords
SplitWords<-unlist(strsplit(gsub("\\{|\\}","",DeepDiveData[1,"words"]),","))
which(SplitWords%in%FirstWords)

# Look at one sentence from DeepDiveData
CleanedWords<-gsub("\\{|\\}","",DocRow["words"])
SplitWords<-unlist(strsplit(CleanedWords,","))
FoundWords<-SplitWords%in%FirstDictionary
SplitWords<-unlist(strsplit(gsub("\\{|\\}","",DeepDiveData[1,"words"]),","))
Test<-subset(DeepDiveData,DeepDiveData[,"docid"]=="54eb194ee138237cc91518dc"&DeepDiveData[,"sentid"]==796)


NNP<-"NNP"
findNNPs<-function(Sentence, NNP) {
    CleanedSentences<-gsub("\\{|\\}","",Sentence)
    SplitSentences<-strsplit(CleanedSentences,",")
    CleanedPoses<-gsub("\\{|\\}","",Sentence["poses"])
    SplitPoses<-unlist(strsplit(CleanedPoses,","))
    CleanedWords<-gsub("\\{|\\}","",Sentence["words"])
    SplitWords<-unlist(strsplit(CleanedWords,","))
    FoundWords<-SplitWords%in%FirstWords
    MatchedWord<-SplitWords[which(FoundWords)]
    
    NNPs<-which(SplitPoses%in%NNP)
    DocumentID<-rep(Sentence["docid"],length(MatchedWord))
    
    return(cbind(NNPs,DocumentID))
    }
    
