# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions
# []-notation is used wherever possible, and $-notation is avoided.


######################################## Load Required Libraries ###########################################

# Load Required Libraries
library("RPostgreSQL")
library("doParallel")
library("pbapply")
#Designate PBDB as source
source("https://raw.githubusercontent.com/aazaff/paleobiologyDatabase.R/master/communityMatrix.R")

##################################### Establish postgresql connection #######################################

# Remember to start postgres (pgadmin) if it is not already running
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "erikaito", host = "localhost", port = 5432, user = "erikaito")

# Load Data Table Into R 
DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM pyrite_example_data")

###################################### Establish DeepDive Dictionaries ######################################

#Select words of interest
ReservoirDictionary<-c("aquifer","reservoir","aquitard","aquiclude","water","oil","gas","coal","aquifuge")
# Make vector of upper case words and add it to the original vector
ReservoirDictionary<-c(ReservoirDictionary,gsub("(^[[:alpha:]])", "\\U\\1", ReservoirDictionary, perl=TRUE))

# Additional possibilities 
# c("permeable","porous","ground water","permeability","porosity","unsaturated zone","vadose zone","water table")

# Download dictionary of unit names from Macrostrat Database
UnitsURL<-paste("https://dev.macrostrat.org/api/units?project_id=1&format=csv")
GotURL<-getURL(UnitsURL)
UnitsFrame<-read.csv(text=GotURL,header=TRUE)
# Extract actual unit names
UnitsDictionary<-unique(UnitsFrame[,"unit_name"])

######################################## Establish DeepDive Functions #######################################
# Function for identifying the parent of matches
findParents<-function(DocRow,FirstDictionary=ReservoirDictionary) {
    CleanedWords<-gsub("\\{|\\}","",DocRow["words"])
    CleanedParents<-gsub("\\{|\\}","",DocRow["dep_parents"])
    SplitParents<-unlist(strsplit(CleanedParents,","))
  	SplitWords<-unlist(strsplit(CleanedWords,","))
  	FoundWords<-SplitWords%in%FirstDictionary
  	return(SplitWords[as.numeric(SplitParents[which(FoundWords)])])
  	}


################################################# DeepDive Analyses ##########################################
# Find all sentences with matches in initial dictionary (i.e., Reservoir Dictionary)
ReservoirSentences<-pbapply(DeepDiveData,1,findParents)

# Extract only matching sentences
ReservoirMatches<-sapply(ReservoirSentences,length)
ReservoirSentences<-ReservoirSentneces[which(ReservoirMatches!=0)]


