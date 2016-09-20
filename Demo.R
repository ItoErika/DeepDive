# Load Libraries
library("RPostgreSQL")

# Connect to PostgreSQL
# Load Data Table Into R 
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")
SentencesData<-dbGetQuery(Connection,"SELECT * FROM pyrite_example_data")

# Create a dictionary of words of interest 
#Select words of interest
Dictionary<-c("pyrite","glauconite","chert","apatite")

# Write a function to search for words of interest in SentencesData

searchWords<-function(Sentence,Dictionary) {
    # Split sentences into individual words by separating sentences at each comma, and unlisting them
    SplitWords<-unlist(strsplit(Sentence["words"],","))
    # Find Dictionary words which appear in split words of nlp processed sentences
  	FoundWords<-SplitWords%in%Dictionary
  	# Have function return Dictionary matches
  	return(FoundWords)
    }

# Apply function to SentencesData 
DDResults<-pbapply(SentencesData,1,searchWords,Dictionary)

