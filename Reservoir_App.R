# Load Libraries
library("RPostgreSQL")
library("doParallel")
library(pbapply)
library(RCurl)

#Connet to PostgreSQL
Driver <- dbDriver("PostgreSQL") # Establish database driver
Connection <- dbConnect(Driver, dbname = "labuser", host = "localhost", port = 5432, user = "labuser")

DeepDiveData<-dbGetQuery(Connection,"SELECT * FROM aquifersentences_nlp352_master")

# Remove symbols 
DeepDiveData[,"words"]<-gsub("\\{|\\}","",DeepDiveData[,"words"])
DeepDiveData[,"poses"]<-gsub("\\{|\\}","",DeepDiveData[,"poses"])
# Make a substitute for commas so they are counted correctly as elements for future functions
DeepDiveData[,"words"]<-gsub("\",\"","COMMASUB",DeepDiveData[,"words"])
DeepDiveData[,"poses"]<-gsub("\",\"","COMMASUB",DeepDiveData[,"poses"])

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

# Create member, formation, group, and supergroup matrices

# For the member matrix:
# First create a dictionary of abbreviations and member titles
MembersDictionary<-c("mbr","member","Mbr","Member","MEMBER")
# Create a list of unique member names
Members<-unique(DF2[,"unit"])
# Duplicate the Mebers names so each word in MembersDictionary is paired with each name.
DuplicatedMembers<-sapply(Members, function(x) paste(rep(x,length(MembersDictionary)),MembersDictionary))
# Rotate matrix
DuplicatedMembers<-t(DuplicatedMembers)
# Add column of member names without suffix
Members<-cbind(as.character(Members),DuplicatedMembers)


# For the formation matrix:
# First create a dictionary of abbreviations and formation titles
FormationsDictionary<-c("fm","Fm","formation","Formation","FORMATION")
# Create a list of unique formation names
Formations<-unique(DF3[,"unit"])
# Duplicate the Formation names so each word in FormationsDictionary is paired with each name.
DuplicatedFormations<-sapply(Formations, function(x) paste(rep(x,length(FormationsDictionary)),FormationsDictionary))
# Rotate matrix
DuplicatedFormations<-t(DuplicatedFormations)
# Add column of formation names without suffix
Formations<-cbind(as.character(Formations),DuplicatedFormations)


# For the group matrix: 
# First create a dictionary of abbreviations and group titles
GroupsDictionary<-c("gp","Gp","grp","GRP","group","Group","GROUP")
# Create a list of unique group names 
Groups<-unique(DF4[,"unit"])
#Duplicate the group names so each word in GroupsDictionary is paired with each name 
DuplicatedGroups<-sapply(Groups, function(x) paste(rep(x,length(GroupsDictionary)),GroupsDictionary))
# Rotate matrix
DuplicatedGroups<-t(DuplicatedGroups)
# Add column of group names without suffix
Groups<-cbind(as.character(Groups),DuplicatedGroups)

# For the supergroup matrix:
# First create a dictionary of abbreviations and supergroup titles
SupergroupsDictionary<-c("sprGrp","SprGrp","sprgrp","spgrp","SpGrp","spGrp","spgp","sGp","SGp","supergroup","Supergroup","SuperGroup")
# Create a list of unique supergroup names 
Supergroups<-unique(DF5[,"unit"])
#Duplicate the supergroup names so each word in SupergroupsDictionary is paired with each name 
DuplicatedSupergroups<-sapply(Supergroups, function(x) paste(rep(x,length(SupergroupsDictionary)),SupergroupsDictionary))
# Rotate matrix
DuplicatedSupergroups<-t(DuplicatedSupergroups)
# Add column of supergroup names without suffix
Supergroups<-cbind(as.character(Supergroups),DuplicatedSupergroups)

# Search unit names WITH suffixes

# Find poses 
findPoses<-function(DocRow,Dictionary) {
    SplitPoses<-unlist(strsplit(DocRow["poses"],","))
    SplitWords<-unlist(strsplit(DocRow["words"],","))
  	FoundWords<-SplitWords%in%Dictionary
  	
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
DDResults<-pbapply(DeepDiveData,1,findPoses,c(Members[,1],Formations[,1],Groups[,1],Supergroups[,1]))

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

# Make function to find NNP words in DDMatches
findNNPs<-function(Sentence) {
    SplitPoses<-unlist(strsplit(Sentence["poses"],","))
    SplitSentences<-unlist(strsplit(Sentence["words"],","))
    NNPs<-which(SplitPoses=="NNP")
    NNPWords<-SplitSentences[NNPs]
    return(cbind(NNPs,NNPWords))
    }
    
# Apply findNNPs function to DDMatches
NNPResults<-pbapply(DDMatches,1,findNNPs)

# Create matrix of NNPResults
NNPResultsMatrix<-do.call(rbind,NNPResults)
rownames(NNPResultsMatrix)<-1:dim(NNPResultsMatrix)[1]

# Add sentence ID data to NNPResultsMatrix
# Find the number of NNP matches for each sentence
MatchCount<-sapply(NNPResults,nrow)
# Create a column for NNPResultsMatrix for sentence IDs
NNPResultsMatrix<-cbind(NNPResultsMatrix,rep(names(NNPResults),times=MatchCount))
# Name the column
colnames(NNPResultsMatrix)[3]<-"SentID"

# Convert matrix into data frame to hold different types of data
NNPResultsFrame<-as.data.frame(NNPResultsMatrix)

# Make sure data in columns are in the correct format
NNPResultsFrame[,"NNPs"]<-as.numeric(as.character(NNPResultsFrame[,"NNPs"]))
NNPResultsFrame[,"NNPWords"]<-as.character(NNPResultsFrame[,"NNPWords"])
NNPResultsFrame[,"SentID"]<-as.character(NNPResultsFrame[,"SentID"])

##################################### Find Consecutive NNPs ######################################

findConsecutive<-function(NNPPositions) {
    Breaks<-c(0,which(diff(NNPPositions)!=1),length(NNPPositions))
    ConsecutiveList<-lapply(seq(length(Breaks)-1),function(x) NNPPositions[(Breaks[x]+1):Breaks[x+1]])
    return(ConsecutiveList)
    }

# Find consecutive NNPs for each SentID
Consecutive<-tapply(NNPResultsFrame[,"NNPs"], NNPResultsFrame[,"SentID"],findConsecutive)
# Collapse the consecutive NNP clusters into single character strings
ConsecutiveNNPs<-sapply(Consecutive,function(y) sapply(y,function(x) paste(x,collapse=",")))

######################### Find Words Associated with Conescutive NNPs ###########################

# Create a matrix with a row for each NNP cluster
# Make a column for sentence IDs
ClusterCount<-sapply(ConsecutiveNNPs,length)
SentID<-rep(names(ConsecutiveNNPs),times=ClusterCount)
# Make a column for cluster elements 
ClusterPosition<-unlist(ConsecutiveNNPs)
names(ClusterPosition)<-SentID
# Make a column for the words associated with each NNP
# Get numeric elements for each NNP
NNPElements<-lapply(ClusterPosition,function(x) as.numeric(unlist(strsplit(x,","))))
names(NNPElements)<-SentID

NNPWords<-vector("character",length=length(NNPElements))
for(Document in 1:length(NNPElements)){
    ExtractElements<-NNPElements[[Document]]
    DocumentName<-names(NNPElements)[Document]
    SplitWords<-unlist(strsplit(DDMatches[DocumentName,"words"],","))
    NNPWords[Document]<-paste(SplitWords[ExtractElements],collapse=" ")
    }

# Bind columns into data frame 
NNPClusterMatrix<-cbind(NNPWords,ClusterPosition,SentID)
rownames(NNPClusterMatrix)<-NULL
NNPClusterFrame<-as.data.frame(NNPClusterMatrix)

# Make sure all of the columns are in the correct data format
NNPClusterFrame[,"NNPWords"]<-as.character(NNPClusterFrame[,"NNPWords"])
NNPClusterFrame[,"ClusterPosition"]<-as.character(NNPClusterFrame[,"ClusterPosition"])
NNPClusterFrame[,"SentID"]<-as.character(NNPClusterFrame[,"SentID"])


# Find NNPClusterFrame rows in which unit names appear

# Bind all member, formation, group, and supergroup names into a single matrix
AllUnitsDictionary<-cbind(Members,Formations,Groups,Supergroups)
# Find matches of AllUnitsDictionary in the NNPClusterFrame "NNPWords" column
MatchRows<-which(NNPClusterFrame[,"NNPWords"]%in%AllUnitsDictionary)

# Subset the NNPClusterFrame so that only CompleteMatchRows are shown
MatchFrame1<-data.frame(matrix(NA,ncol = 3, nrow = length(MatchRows)),stringsAsFactors=False)
for (Row in 1:length(MatchRows)){
    MatchFrame1[Row,]<-NNPClusterFrame[as.numeric(MatchRows[Row]),]
    }
# Create column names for MatchFrame1 to match NNPClusterMatrix
colnames(MatchFrame1)<-colnames(NNPClusterFrame)
