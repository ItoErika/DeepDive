# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions
# []-notation is used wherever possible, and $-notation is avoided.


################################# Load Required Libraries and Download Data #################################

# Load Required Libraries
library("RPostgreSQL")
library("doParallel")
#Designate PBDB as source
source("https://raw.githubusercontent.com/aazaff/paleobiologyDatabase.R/master/communityMatrix.R")
#Download list of taxonomic names from PBDB
DataPBDB<-downloadPBDB(Taxa=c("Bivalvia","Brachiopoda"),StartInterval="Cambrian",StopInterval="Holocene")

# Make Core Cluster
Cluster<-makeCluster(7)

##################################### Establish postgresql connection #######################################

# Remember to start postgres (pgadmin) if it is not already running
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "erikaito", host = "localhost", port = 5432, user = "erikaito")

# Load Data Table Into R 
DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM pyrite_example_data")

############################## Search for words in an individual document ##################################

IndividualDocumentsList<-split(DeepDiveData,DeepDiveData[,"docid"])
#Choose Document
FirstDocument<-IndividualDocumentsList[[1]]
#Choose Word(s)
Words<-c("pyrite","glauconite","chert","apatite")

#Function time
wordSearch<-function(Sentence,Words) {
  CleanedSentences<-gsub("\\{|\\}|\\.|\\(|\\)|\\—","",Sentence)
  SplitSentences<-strsplit(CleanedSentences,",")
  FoundWords<-Words%in%unlist(SplitSentences)
  return(FoundWords)
  }
  
# Apply the wordSearch function to all sentences in FirstDocument 
WordSearchResuls<-sapply(FirstDocument[,"words"],wordSearch,Words)
#Get sentences where words appear
which(WordSearchResuls,arr.ind=TRUE) #row number corresponds to Words and column number corresponds to sentences. 

############################### Search for genus names in all Documents ###################################
# Split the postgres table into individual documents
IndividualDocumentsList<-split(DeepDiveData,DeepDiveData[,"docid"])

#Isolate data to get data with genus names
GenusPBDB<-cleanRank(DataPBDB,Rank="genus")

#Create vector of genus names
GenusNames<-unique(GenusPBDB[,"genus"])

#Set GenusNames to Words which will be searched for
Words<-GenusNames

#Create function to return the words found in a sentence
wordSearch<-function(Sentence,Words) {
    CleanedSentences<-gsub("\\{|\\}|\\.|\\(|\\)|\\—","",Sentence)
    SplitSentences<-strsplit(CleanedSentences,",")
    FoundWords<-Words%in%unlist(SplitSentences)
    return(FoundWords)
    }

# Make second function to apply the function to all documents
validSentences1<-function(Document,Words) {
    WordSearchResults<-sapply(Document[,"words"],wordSearch,Words)
    PresentWords<-which(WordSearchResults,arr.ind=TRUE)
    return(PresentWords)
    }

# Pass the functions to the cluster
clusterExport(cl=Cluster,varlist=c("wordSearch","validSentences1"))

#Find sentences that contain the words of interest for all documents
DocumentSentenceNamesMatches<-parLapply(Cluster,IndividualDocumentsList,validSentences1,Words)

########## Use function to search for words related to fossiliation (specifically replacement) ##############
#Select words of interest
Words<-c("pyrite",,"Pyrite","pyritized","Pyritized","pyritization","Pyritization","pyrititic","Pyrititic","glauconite","Glauconite","chert","Chert","apatite","Apatite","silicification","Silicification","silica","Silica","petrifaction","Petrification","petrification","Petrifaction","replacement","Replacement","phosphatization","Phosphatization","phosphatic","Phosphatic","phosphate","Phosphate","hematite","Hematite","diagenesis","Diagenesis","diagenetic","Diagenetic")
#Run functions to search for instances of words of interest in all documents.
wordSearch<-function(Sentence,Words) {
    CleanedSentences<-gsub("\\{|\\}|\\.|\\(|\\)|\\—","",Sentence)
    SplitSentences<-strsplit(CleanedSentences,",")
    FoundFossilizationWords<-Words%in%unlist(SplitSentences)
    return(FoundFossilizationWords)
    }
validSentences2<-function(Document,Words) {
    FossilizationWordSearchResults<-sapply(Document[,"words"],wordSearch,Words)
    PresentWords<-which(FossilizationWordSearchResults,arr.ind=TRUE)
    return(PresentFossilizationWords)
    }
# Pass the functions to the cluster
clusterExport(cl=Cluster,varlist=c("wordSearch","validSentences2"))

#Find sentences that contain the words of interest for all documents
DocumentSentenceFossilizationMatches2<-parLapply(Cluster,IndividualDocumentsList,validSentences2,Words)

######################################### Bad Genus Names ###################################################
Here

######################################### Absent Genus Names ################################################
Cucellea

######################################### Useful Code Examples ##############################################

#Find number of documents
length(unique(DeepDiveData[,"docid"]))
#Split table into documents
IndividualDocumentsList<-split(DeepDiveData,DeepDiveData[,"docid"])
#Check that length of list matches number of documents
length(IndividualDocumentsList)
#Select document (ex. 1)
FirstDocument<-IndividualDocumentsList[[1]]
#Select first 20 sentences
FirstDocument[1:20,"words"]
#Select a sentence (ex. 15th sentence)
Test<-FirstDocument[15,"words"]
#get rid of unwanted text or symbols ( ex. }, {, .)
gsub("\\{|\\}|\\.","",Test)
#split sentence at commas
Test<-strsplit(Test,",")
Test
#Determine if the word of interest are in the sentence. (ex. pyrite)
#Remember that Test is a list
"pyrite"%in%Test[[1]]
#OR
"pyrite"%in%unlist(Test)
#OR if you have multiple words of interest. (ex. pyrite, glauconite, chert, apatite)
Search<-c("pyrite","glauconite","chert","apatite")
Search%in%Test[[1]]


# Apply the wordSearch function to all sentences in FirstDocument 
WordSearchResuls<-sapply(FirstDocument[,"words"],wordSearch,Words)
which(WordSearchResuls,arr.ind=TRUE)
#Show words that appear in document
Words[which(WordSearchResuls,arr.ind=TRUE)[,1]]
