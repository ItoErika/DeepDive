UnitsURL<-paste("https://macrostrat.org/api/units?project_id=1&format=csv")
GotURL<-getURL(UnitsURL)
UnitsFrame<-read.csv(text=GotURL,header=TRUE)

StratNamesURL<-paste("https://macrostrat.org/api/defs/strat_names?all&format=csv")
GotURL<-getURL(StratNamesURL)
StratNamesFrame<-read.csv(text=GotURL,header=TRUE)

unit_id, col_id, lat, lng, unit_name, strat_name_long

Units<-merge(x = StratNamesFrame, y = UnitsFrame, by = "strat_name_id", all.x = TRUE)

Units<-cbind(Units[,"strat_name_id"],Units[,"strat_name_long"],Units[,"unit_id"],Units[,"unit_name"],Units[,"col_id"])
