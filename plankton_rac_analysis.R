install.packages("codyn", repos='http://cran.us.r-project.org')
install.packages("dplyr",  repos='http://cran.us.r-project.org')
install.packages("tidyr",  repos='http://cran.us.r-project.org')
install.packages("lubridate",  repos='http://cran.us.r-project.org')
install.packages("ggplot2",  repos='http://cran.us.r-project.org')


library("dplyr")
library("tidyr")
library("lubridate")
library("codyn")
library("ggplot2")

print("libraries loaded")

dfBv = read.csv('/vortexfs1/scratch/msantos/rac/data/biovol_concentration_by_class_time_series_CNN_daily19Aug2021.csv') #daily biovol concentration
dfConc = read.csv('/vortexfs1/scratch/msantos/rac/data/concentration_by_class_time_series_CNN_daily19Aug2021.csv') #daily biovol concentration
dfFunc_long= read.csv("/vortexfs1/scratch/msantos/rac/data/df_daily_long.txt",sep = " ")

dfBv <- dfBv  %>% select(-c("bead","fiber","camera_spot","detritus","detritus_clear","fiber_TAG_external_detritus","unknown2","square_unknown","mix","bubble","pollen","fecal_pellet"))
dfConc <- dfConc  %>% select(-c("bead","fiber","camera_spot","detritus","detritus_clear","fiber_TAG_external_detritus" ,"unknown2","square_unknown","mix","bubble","pollen","fecal_pellet"))
print(names(dfBv))


#loading in class list file that maps species to their respective functional groups
cl =  read.csv('/vortexfs1/scratch/msantos/rac/data/IFCB_classlist_type.csv') #importing 
head(cl)

dia = cl[cl$Diatom == 1,]$CNN_classlist
pens = cl[cl$pennatediatom == 1,]$CNN_classlist
dinos = cl[cl$Dinoflagellate == 1,]$CNN_classlist
cocco = cl[cl$Coccolithophore == 1,]$CNN_classlist
cils = cl[cl$Ciliate == 1,]$CNN_classlist
fla = cl[cl$flagellate == 1,]$CNN_classlist
nano = cl[cl$Nano == 1,]$CNN_classlist

print(paste("diatoms",length(dia)))
length(dinos)
length(pens)
length(cocco)
length(cils)
length(fla)
length(nano)

dia_col = which(colnames(dfBv) %in% dia)
pen_col = which(colnames(dfBv) %in% pens)
coc_col = which(colnames(dfBv) %in% cocco)
cil_col = which(colnames(dfBv) %in% cils)
fla_col = which(colnames(dfBv) %in% fla)
nan_col = which(colnames(dfBv) %in% nano)

print("data loaded")

##INTRADIATOM LEVEL
# converting to long format

dfbv.dia <- dfBv[,c(1,dia_col)]
dfbv.dia.long <- gather(dfbv.dia,species,conc,as.character(colnames(dfbv.dia)[2]):as.character(colnames(dfbv.dia)[length(dfbv.dia)]),factor_key=TRUE)

dfbv.dia.long$date = dmy_hms(as.character(dfbv.dia.long$datetime))
dfbv.dia.long$year = year(dfbv.dia.long$date)
dfbv.dia.long$month = month(dfbv.dia.long$date)
dfbv.dia.long$day = day(dfbv.dia.long$date)
dfbv.dia.long["mdy"] = paste0(dfbv.dia.long$month,"_",dfbv.dia.long$day,"_",dfbv.dia.long$year)

head(dfbv.dia.long)
print(length(dfbv.dia.long$species))


dfbv.dia.long<- dfbv.dia.long %>% 
  drop_na() %>%
  filter_all( all_vars(. != 0)) %>%
  group_by(mdy,species) %>%
  summarize(conc.sum = sum(conc))

head(dfbv.dia.long)
# 
# converting to long format
# print(head(dfBv))
# dfBv_long <- gather(dfBv,species,conc,Acanthoica_quattrospina:zooplankton,factor_key=TRUE)
# dfConc_long <- gather(dfConc,species,conc,Acanthoica_quattrospina:zooplankton,factor_key=TRUE)
# 
# converting to long format
# dfBv_long <- gather(dfBv,species,conc,Acanthoica_quattrospina:zooplankton,factor_key=TRUE)
# dfConc_long <- gather(dfConc,species,conc,Acanthoica_quattrospina:zooplankton,factor_key=TRUE)


# BIOVOLUME
# 
# dfBv_long$date = dmy_hms(as.character(dfBv_long$datetime))
# dfBv_long$year = year(dfBv_long$date)
# dfBv_long$month = month(dfBv_long$date)
# dfBv_long$day = day(dfBv_long$date)
# dfBv_long["mdy"] = paste0(dfBv_long$month,"_",dfBv_long$day,"_",dfBv_long$year)
# 
# dfBv_long<- dfBv_long %>% 
#   drop_na() %>%
#   filter_all( all_vars(. != 0)) %>%
#   group_by(mdy,species) %>%
#   summarize(conc.sum = sum(conc))
# head(dfBv_long)
# 
# 
# CONCENTRATION
# dfConc_long$date = dmy_hms(as.character(dfConc_long$datetime))
# dfConc_long$year = year(dfConc_long$date)
# dfConc_long$month = month(dfConc_long$date)
# dfConc_long$day = day(dfConc_long$date)
# dfConc_long["mdy"] = paste0(dfConc_long$month,"_",dfConc_long$day,"_",dfConc_long$year)
# 
# dfConc_long<- dfConc_long %>% 
#   drop_na() %>%
#   filter_all( all_vars(.!= 0)) %>%
#   group_by(mdy,species) %>%
#   summarize(conc.sum = sum(conc))

#FUNCTIONAL GROUPING
# dfFunc_long["datetime"] = dmy_hms(as.character(dfFunc_long$datetime))
# dfFunc_long["day"] = as.numeric(day(dfFunc_long$datetime))
# dfFunc_long$year = as.numeric(year(dfFunc_long$datetime))
# dfFunc_long["month"] = as.numeric(month(dfFunc_long$datetime))
# dfFunc_long["mdy"] = paste0(dfFunc_long$month,"_",dfFunc_long$day,"_",dfFunc_long$year)
# 
# dfFunc_long <- dfFunc_long %>%
#   filter(!((group == "IFCB artifact")|(group == "Other live")|(group == "Other not alive")) )%>%
#   drop_na() %>%
#   filter_all( all_vars(. != 0)) %>%
#   group_by(mdy,group) %>% 
#   summarize(bvsum = sum(biovol.mL))

print("success at loading and filtering all variables")



outputRAC_dia <- RAC_change(df = dfbv.dia.long,
            species.var = "species",
           abundance.var = "conc.sum",
            time.var ="mdy")

 print("success at generating RAC output")
  write.csv(outputRAC_dia, file = "/vortexfs1/scratch/msantos/rac/results/outputRAC_diac.csv")


#CURVE CHANGE
outcurve_dia <- curve_change(df = dfbv.dia.long,
                             species.var = "species",
                             abundance.var = "conc.sum",
                             time.var ="mdy")

write.csv(outcurve_dia, file = "/vortexfs1/scratch/msantos/rac/results/outcurve_dia.csv")


print("success at generating RAC curve")

# outputRAC_func <- RAC_change(df = dfFunc_long, 
#             species.var = "group",
#            abundance.var = "bvsum",
#             time.var ="mdy")
#  
#  print("success at generating RAC output")
#   write.csv(outputRAC_func, file = "/vortexfs1/scratch/msantos/rac/results/outputRAC_func.csv")
# 
# 
# #CURVE CHANGE
# outcurve <- curve_change(df = dfFunc_long, 
#                              species.var = "group",
#                              abundance.var = "bvsum",
#                              time.var ="mdy")
# 
# print("success at generating RAC curve")

# write.csv(outcurve, file = "/vortexfs1/scratch/msantos/rac/results/output_curve_change.csv")

# #MULTIVARIATE CHANGE
# outmultivar <- multivariate_change(df = dfFunc_long, 
#                          species.var = "group",
#                          abundance.var = "bvsum",
#                          time.var ="mdy")
# 
# print("success at generating RAC multivar")
# 
# write.csv(outmultivar, file = "/vortexfs1/scratch/msantos/rac/results/output_multivar_change.csv")



# https://pubmed.ncbi.nlm.nih.gov/19886478/
# outputRAC_Bv <- RAC_change(df = dfBv_long, 
#                         species.var = "species",
#                         abundance.var = "conc.sum",
#                         time.var ="mdy")
# 
# write.csv(outputRAC_Bv, file = "/vortexfs1/scratch/msantos/rac/results/outputRAC_Bv.csv")
# 
# print("success at generating RAC output bv")
# 
# outputRAC_Conc <- RAC_change(df = dfConc_long, 
#                         species.var = "species",
#                         abundance.var = "conc.sum",
#                         time.var ="mdy")
# 
# print("success at generating RAC output bv")
# 
# 
# write.csv(outputRAC_Conc, file = "/vortexfs1/scratch/msantos/rac/results/outputRAC_conc.csv")
