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

dfBv = read.csv('/vortexfs1/scratch/msantos/rac/data/biovol_concentration_by_class_time_series_CNN_daily.csv') #daily biovol concentration
dfConc = read.csv('/vortexfs1/scratch/msantos/rac/data/concentration_by_class_time_series_CNN_daily.csv') #daily biovol concentration
dfFunc_long= read.csv("/vortexfs1/scratch/msantos/rac/data/df_daily_long.txt",sep = " ")

dfBv <- dfBv  %>% select(-c("bead","fiber","camera_spot","detritus","detritus_clear","fiber_TAG_external_detritus","unknown2","square_unknown","mix","bubble","pollen","fecal_pellet"))
dfConc <- dfConc  %>% select(-c("bead","fiber","camera_spot","detritus","detritus_clear","fiber_TAG_external_detritus" ,"unknown2","square_unknown","mix","bubble","pollen","fecal_pellet"))
print(names(dfBv))

print("data loaded")
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
dfFunc_long["datetime"] = dmy_hms(as.character(dfFunc_long$datetime))
dfFunc_long["day"] = as.numeric(day(dfFunc_long$datetime))
dfFunc_long$year = as.numeric(year(dfFunc_long$datetime))
dfFunc_long["month"] = as.numeric(month(dfFunc_long$datetime))
dfFunc_long["mdy"] = paste0(dfFunc_long$month,"_",dfFunc_long$day,"_",dfFunc_long$year)

dfFunc_long <- dfFunc_long %>%
                drop_na() %>% 
                filter_all( all_vars(.!= 0)) %>%
                group_by(mdy,group) %>% 
                summarize(bvsum = sum(biovol.mL))


print("success at loading and filtering all variables")

# outputRAC_func <- RAC_change(df = dfFunc_long, 
#            species.var = "group",
#            abundance.var = "bvsum",
#            time.var ="mdy")
# 
# print("success at generating RAC output")
# 
# write.csv(outputRAC_func, file = "/vortexfs1/scratch/msantos/rac/results/outputRAC_func.csv")


#CURVE CHANGE
outcurve <- curve_change(df = dfFunc_long, 
                             species.var = "group",
                             abundance.var = "bvsum",
                             time.var ="mdy")

print("success at generating RAC curve")

write.csv(outcurve, file = "/vortexfs1/scratch/msantos/rac/results/output_curve_change.csv")

#MULTIVARIATE CHANGE
outmultivar <- multivariate_change(df = dfFunc_long, 
                         species.var = "group",
                         abundance.var = "bvsum",
                         time.var ="mdy")

print("success at generating RAC multivar")

write.csv(outmultivar, file = "/vortexfs1/scratch/msantos/rac/results/output_multivar_change.csv")



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
