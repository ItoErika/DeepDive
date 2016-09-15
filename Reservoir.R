# Load Libraries
library("RPostgreSQL")

#Connet to PostgreSQL
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")
DeepDiveData1<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_4000")
DeepDiveData2<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_5000")
DeepDiveData3<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_6000")
DeepDiveData4<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_7000")
DeepDiveData5<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_8000")
