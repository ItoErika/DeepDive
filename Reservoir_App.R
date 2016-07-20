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
UnitsVector<-unique(Vector)
Units<-subset(UnitsVector,UnitsVector!="")

######################## Split Unit Names in Units Vector into Individual Words ############################

#Create a dictionary list of matrices of split unit words
NumUnits<-1:length(Units)
UnitDictionary<-vector("list",length=length(Units))
for(UnitElement in NumUnits){
    UnitDictionary[[UnitElement]]<-unlist(strsplit(noquote(gsub(" ","SPLIT",VECTOR[UnitElement])),"SPLIT"))
    }

###################### Isolate First Words in Each Word String of UnitDictionary #########################

# Pull out the first word of every matrix in the UnitDictionary list
FirstWords<-unique(sapply(UnitDictionary,function(x) x[1]))
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
  	MatchedWords<-SplitWords[which(FoundWords)]
  	WordPosition<-which(FoundWords)
  	FoundPose<-SplitPoses[which(FoundWords)]
    DocumentID<-rep(DocRow["docid"],length(MatchedWords))
    SentenceID<-rep(DocRow["sentid"],length(MatchedWords))
    
    SplitWords<-unlist(strsplit(gsub("\\{|\\}","",DeepDiveData[1,"words"]),","))

    # Return the function output
    return(cbind(MatchedWords,WordPosition,FoundPose,DocumentID,SentenceID))
    }
  	
# Apply function to DeepDiveData documents
DDResults<-pbapply(DeepDiveData,1,findPoses,FirstWords)

##################################### Organize into Data Frame #########################################

# Create matrix of DDResults
DDResultsMatrix2<-do.call(rbind,DDResults)
rownames(DDResultsMatrix)<-1:dim(DDResultsMatrix)[1]
DDResultsFrame<-as.data.frame(DDResultsMatrix)

# Ensure all columns are in correct format
DDResultsFrame[,1]<-as.character(DDResultsFrame[,1])
DDResultsFrame[,2]<-as.numeric(as.character(DDResultsFrame[,2]))
DDResultsFrame[,3]<-as.character(DDResultsFrame[,3])
DDResultsFrame[,4]<-as.character(DDResultsFrame[,4])
DDResultsFrame[,5]<-as.numeric(as.character(DDResultsFrame[,5]))

#################################### Isolate NNPs ############################################# 

# Subset so you only get NNP matches
DDResultsFrame<-subset(DDResultsFrame,DDResultsFrame[,3]=="NNP")

####################### Find NNps adjacent to DDResultsFrame Matches ##########################
# Make function to find NNP words adjacent to the matches in DDResultsFrame

findAdjacentNNPs<-function(DocRow,FirstDictionary=FirstWords) {
  CleanedWords<-gsub("\\{|\\}","",DocRow["words"])
    CleanedPoses<-gsub("\\{|\\}","",DocRow["poses"])
    SplitPoses<-unlist(strsplit(CleanedPoses,","))
    SplitWords<-unlist(strsplit(CleanedWords,","))
  	FoundWords<-SplitWords%in%FirstDictionary
  	
  	# Create columns for final matrix
  	MatchedWords<-SplitWords[which(FoundWords)]
  	WordPosition<-which(FoundWords)
  	FoundPose<-SplitPoses[which(FoundWords)]
    DocumentID<-rep(DocRow["docid"],length(MatchedWords))
    SentenceID<-rep(DocRow["sentid"],length(MatchedWords))
    
    SplitWords<-unlist(strsplit(gsub("\\{|\\}","",DeepDiveData[1,"words"]),","))

  	    
    # Return the function output
    return(cbind(MatchedWords,WordPosition,FoundPose,DocumentID,SentenceID))
    }

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
