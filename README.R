# Custom functions are camelCase. Arrays, parameters, and arguments are PascalCase
# Dependency functions are not embedded in master functions
# []-notation is used wherever possible, and $-notation is avoided.

######################################### Load Required Libraries ###########################################
# Load Required Libraries
library("RPostgreSQL")

# Establish postgresql connection.
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "erikaito", host = "localhost", port = 5432, user = "erikaito")

######################################### Load Data Table Into R ############################################
DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM pyrite_example_data")
