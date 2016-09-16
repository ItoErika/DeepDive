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
# Get rid of rows with empty member name columns
GoodRows<-which(DF2[,"Mbr"]!="")
DF2<-DF2[GoodRows,]

# For formation names and unit id #s:
GoodCols<-c("unit_id","Fm")
DF3<-V1[,(names(V1)%in%GoodCols)]
# Get rid of rows with empty member name columns
GoodRows<-which(DF3[,"Fm"]!="")
DF3<-DF3[GoodRows,]

# For group names and unit id #s
GoodCols<-c("unit_id","Gp")
DF4<-V1[,(names(V1)%in%GoodCols)]
# Get rid of rows with empty group name columns
GoodRows<-which(DF4[,"Gp"]!="")
DF4<-DF4[GoodRows,]

# For supergroup names and unit id #s
GoodCols<-c("unit_id","SGp")
DF5<-V1[,(names(V1)%in%GoodCols)]
# Get rid of rows with empty supergroup name columns
GoodRows<-which(DF5[,"SGp"]!="")
DF5<-DF5[GoodRows,]

# Change column names of dataframes to match each other
colnames(DF1)[2]<-"unit"
colnames(DF2)[2]<-"unit"
colnames(DF3)[2]<-"unit"
colnames(DF4)[2]<-"unit"
colnames(DF5)[2]<-"unit"

# Stitch DF1, DF2, DF3, DF4, and DF5 into single dataframe
Units1<-rbind(DF1,DF2,DF3,DF4,DF5)

# Create a dictionary of common unit words
ComUnitWords<-c("allochthon","bed","beds","bentonite","member","mbr","formation","fm","group","grp","soil","supergroup","strata","stratum","sprGrp","spgrp","sGp","unit","complex","cmplx","cplx","ste","basement","pluton","shale","alluvium","amphibolite","andesite","anhydrite","argillite","arkose","basalt","batholith","bauxite","breccia","chalk","chert","clay","coal","colluvium","conglomerate","diorite","dolerite","dolomite","gabbro","gneiss","gp","granite","granite,","granodiorite","graywacke","gravel","greenstone","gypsum","intrustion","latite","loess","marble","marl","metadacite","metadiabase","metagabbro","metagranite","metasediments","microdiorite","migmatite","monzonite","mountain","mountains","mudstone", "limestone","lm","ls","oolite","ophiolite","paleosol","peat","phosphorite","phyllite","pluton","plutonic","quartzite","range","rhyolite","rhyolites","salt","sand","sands","sandstone","sS","ss","sandstones","schist","SCHIST","serpentinite","sequence","shale","silt","siltstone","slate","suite","sui","terrane","till","tills","tillite","tonalite","tuff","unit","volcanic","volcanics")
# Make vector of upper case words and add it to the original vector
ComUnitWords<-c(ComUnitWords,gsub("(^[[:alpha:]])", "\\U\\1", ComUnitWords, perl=TRUE))

# Remove all common unit words from "unit" column in Units1
# Split each character string in "unit" column into separated words 
NumRows<-1:dim(Units1)[1]
SplitUnits<-vector("list",length=length(Units1[,"unit"]))
for(Row in NumRows){
    SplitUnits[[Row]]<-strsplit((as.character(Units1[,"unit"][Row]))," ")
    }
  
# Find matches of common unit words in SplitUnits list
MatchWords<-vector("list",length=length(SplitUnits))
 for(Element in 1:length(SplitUnits)){
    MatchWords[[Element]]<-unlist(SplitUnits[[Element]])%in%ComUnitWords}

# Remove common unit words from each element in list
FilteredUnits<-vector("list",length=length(SplitUnits))
for(Element in 1:length(SplitUnits)){
    FilteredUnits[[Element]]<-unlist(SplitUnits[[Element]])[which(MatchWords[[Element]]=="FALSE")]
    }

# Past filtered units back into single text strings
UnitStrings<-sapply(FilteredUnits, function(x) paste (x,collapse=" "))

# Add UnitStrings as column back into Units1 dataframe
Units1[,"filtered_units"]<-UnitStrings

# Create member, formation, group, and supergroup dataframes

# For the member dataframe:
# First create a dictionary of abbreviations and member titles
MembersDictionary<-c("mbr","member","Mbr","Member","MEMBER")
# Create a list of unique member names
Members<-unique(DF2[,"unit"])
# Duplicate the Mebers names so each word in MembersDictionary is paired with each name.
DuplicatedMembers<-sapply(Members, function(x) paste(rep(Members[x],length(MembersDictionary)),MembersDictionary))

# For the formation data frame:
# First create a dictionary of abbreviations and formation titles
FormationsDictionary<-c("fm","Fm","formation","Formation","FORMATION")
# Create a list of unique formation names
Formations<-unique(DF3[,"unit"])
# Duplicate the Formation names so each word in FormationsDictionary is paired with each name.
DuplicatedFormations<-sapply(Formations, function(x) paste(rep(Formations[x],length(FormationsDictionary)),FormationsDictionary))

# For the group data frame: 
# First create a dictionary of abbreviations and group titles
GroupsDictionary<-c("gp","Gp","grp","GRP","group","Group","GROUP")
# Create a list of unique group names 
Groups<-unique(DF4[,"unit"])
#Duplicate the group names so each word in GroupsDictionary is paired with each name 
DuplicatedGroups<-sapply(Groups, function(x) paste(rep(Groups[x],length(GroupsDictionary)),GroupsDictionary))

# For the supergroup data frame:
# First create a dictionary of abbreviations and supergroup titles
SupergroupsDictionary<-c("sprGrp","SprGrp","sprgrp","spgrp","SpGrp","spGrp","spgp","sGp","SGp","supergroup","Supergroup","SuperGroup")
# Create a list of unique supergroup names 
Supergroups<-unique(DF5[,"unit"])
#Duplicate the supergroup names so each word in SupergroupsDictionary is paired with each name 
DuplicatedSupergroups<-sapply(Supergroups, function(x) paste(rep(Supergroups[x],length(SupergroupsDictionary)),SupergroupsDictionary))
















# Create another dataframe of all combinations of unit names 


<-c("allochthon","bentonite","member","mbr","formation","fm","group","grp","soil","supergroup","strata","stratum","sprGrp","spgrp","sGp","unit","complex","cmplx","cplx","ste","basement","pluton","shale","alluvium","amphibolite","andesite","anhydrite","argillite","arkose","basalt","batholith","bauxite","breccia","chalk","chert","clay","coal","colluvium","conglomerate","diorite","dolerite","dolomite","gabbro","gneiss","gp","granite","granite,","granodiorite","graywacke","gravel","greenstone","gypsum","intrustion","latite","loess","marble","marl","metadacite","metadiabase","metagabbro","metagranite","metasediments","microdiorite","migmatite","monzonite","mountain","mountains","mudstone", "limestone","lm","ls","oolite","ophiolite","paleosol","peat","phosphorite","phyllite","pluton","plutonic","quartzite","range","rhyolite","rhyolites","salt","sand","sands","sandstone","sS","ss","sandstones","schist","SCHIST","serpentinite","sequence","shale","silt","siltstone","slate","suite","sui","terrane","till","tills","tillite","tonalite","tuff","unit","volcanic","volcanics")







# Create a vector of all unique unit words
UnitsVector<-c(as.character(UnitsFrame[,"unit_name"],UnitsFrame[,"Mbr"]),as.character(UnitsFrame[,"Fm"]),as.character(UnitsFrame[,"Gp"]),as.character(UnitsFrame[,"SGp"]))
UnitsVector<-unique(UnitsVector)
Units<-subset(UnitsVector,UnitsVector!="")

