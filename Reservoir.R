# Load Libraries
library("RPostgreSQL")

#Connet to PostgreSQL
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")
DeepDiveData1<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_4000")
