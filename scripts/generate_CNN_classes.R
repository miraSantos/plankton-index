

basepath = "/D/MIT-WHOI/github_repos/plankton-index/"
dfc = read.csv(paste0(basepath,'data/count_by_class_time_seriesCNN_hourly08Sep2021.csv')) #hourly count of plankton


write.csv(colnames(dfc[,which(colnames(dfc)=="Acanthoica_quattrospina"):which(colnames(dfc) == "zooplankton")]),paste0(basepath,"/results/cnn_categories.csv"),row.names=FALSE)
