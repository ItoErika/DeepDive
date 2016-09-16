# Load Libraries
library("RPostgreSQL")
library("doParallel")
library(pbapply)
library(RCurl)

#Connet to PostgreSQL
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")
DeepDiveData1<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_4000")
DeepDiveData2<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_5000")
DeepDiveData3<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_6000")
DeepDiveData4<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_7000")
DeepDiveData5<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_8000")

# Remove symbols 
DeepDiveData1[,"words"]<-gsub("\\{|\\}","",DeepDiveData1[,"words"])
DeepDiveData1[,"poses"]<-gsub("\\{|\\}","",DeepDiveData1[,"poses"])
# Make a substitute for commas so they are counted correctly as elements for future functions
DeepDiveData1[,"words"]<-gsub("\",\"","COMMASUB",DeepDiveData1[,"words"])
DeepDiveData1[,"poses"]<-gsub("\",\"","COMMASUB",DeepDiveData1[,"poses"])

# Download dictionary of unit names from Macrostrat Database
UnitsURL<-paste("https://dev.macrostrat.org/api/units?project_id=1&format=csv")
GotURL<-getURL(UnitsURL)
UnitsFrame<-read.csv(text=GotURL,header=TRUE)

# Get rid of unnamed units
UnitsFrame<-UnitsFrame[!(UnitsFrame$unit_name=="Unnamed"),]
UnitsFrame<-UnitsFrame[!(UnitsFrame$unit_name=="unnamed"),]

# Extract columns from UnitsFrame to make a dataframe of macrostrat unit names and untitIDs
GoodCols<-c("unit_id","unit_name","Mbr","Fm","Gp","SGp")
V1<-UnitsFrame[,(names(UnitsFrame)%in%GoodCols)]

# Create a 2 column dataframes of unit names and unit id #s, member names and unit id #s, formation names and unit id #s, group names and unit id #s, and supergroup names and unit id #s
# For unit names and unit id #s:
GoodCols<-c("unit_id","unit_name")
DF1<-V1[,(names(V1)%in%GoodCols)]
# For member names and unit id #s:
GoodCols<-c("unit_id","Mbr")
DF2<-V1[,(names(V1)%in%GoodCols)]
# For formation names and unit id #s:
GoodCols<-c("unit_id","Fm")
DF3<-V1[,(names(V1)%in%GoodCols)]
# For group names and unit id #s
GoodCols<-c("unit_id","Gp")
DF4<-V1[,(names(V1)%in%GoodCols)]
# For supergroup names and unit id #s
GoodCols<-c("unit_id","SGp")
DF5<-V1[,(names(V1)%in%GoodCols)]

# Stitch DF1, DF2, DF3, DF4, and DF5 into single dataframe


# Remove unnecessary columns from UnitsFrame
BadCols<-c("project_id","col_area","pbdb_occurrences","pbdb_collections")
UnitsFrame<-UnitsFrame[,!(names(UnitsFrame)%in%BadCols)]



















# Create a vector of all unique unit words
UnitsVector<-c(as.character(UnitsFrame[,"unit_name"],UnitsFrame[,"Mbr"]),as.character(UnitsFrame[,"Fm"]),as.character(UnitsFrame[,"Gp"]),as.character(UnitsFrame[,"SGp"]))
UnitsVector<-unique(UnitsVector)
Units<-subset(UnitsVector,UnitsVector!="")

# Create a dictionary of common unit words
ComUnitWords<-c("Member","Mbr","Formation","Fm","Group","Grp","Supergroup","Strata","Stratum","SprGrp","Spgrp","Unit","Complex","Cmplx","Cplx","Ste","Basement","Pluton","Shale","Alluvium","Amphibolite","Andesite","Anhydrite","Argillite","Arkose","Basalt","Batholith","Bauxite","Breccia","Chert","Clay","Coal","Colluvium","Complex","Conglomerate","Dolerite","Dolomite","Gabbro","Gneiss","Granite","Granodiorite","Graywacke","Gravel","Greenstone","Gypsum","Latite","Marble","Marl","Metadiabase","Migmatite","Monzonite","Mountains","Mudstone", "Limestone","Lm","Ls","Oolite","Ophiolite","Peat","Phosphorite","Phyllite","Pluton","Plutonic","Quartzite","Range","Rhyolite","Salt","Sand","Sands","Sandstone","SS","Sandstones","Schist","Serpentinite","Shale","Silt","Siltstone","Slate","Suite","Sui","Terrane","Till","Tonalite","Tuff","Unit","Volcanic","Volcanics")
