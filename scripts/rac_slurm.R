
library("dplyr")
library("tidyr")
library("ggplot2")
library("lubridate")

install.packages("ggrepel",repos='http://cran.us.r-project.org')
library("ggrepel")

install.packages("data.table",repos='http://cran.us.r-project.org')
library("data.table")

install.packages("zoo",repos='http://cran.us.r-project.org')
library("zoo")

install.packages("scales",repos='http://cran.us.r-project.org')
library("scales")

install.packages("codyn", repos='http://cran.us.r-project.org')
library("codyn") #for RAC functions to work

# importing data

basepath = "/vortexfs1/scratch/msantos/rac/"
dfc = read.csv(paste0(basepath,'data/count_by_class_time_seriesCNN_hourly08Sep2021.csv')) #hourly count of plankton
cl =  read.csv(paste0(basepath,'/data/IFCB_classlist_type.csv'))

# head(dfc)
# head(cl)

names(cl)
mapf <- function(Fgroup){
    which(colnames(dfc) %in% cl[cl[Fgroup] == 1,]$CNN_classlist)} #generates list of species within the specified functional grou

#removing categories within the Other.not.alive and the IFCB.artifact groups from dfc
dfc <- dfc %>% select(-c(mapf("Other.not.alive"),mapf("IFCB.artifact"),mix))

dfc$datetime = as.Date(dfc$datetime, format = "%d-%b-%Y %H:%M:%S")
dfc$totalcount = rowSums(subset(dfc, select=Acanthoica_quattrospina:zooplankton))
dfc$year = year(dfc$date)
dfc$month = sprintf("%02d",month(dfc$date))
dfc$day =  sprintf("%02d",day(dfc$date))
dfc$my = paste0(dfc$year,"_",dfc$month)
dfc$week = week(dfc$date)
dfc$wy = paste0(dfc$year,"_",dfc$week)

#grouping at the week of the year
dfc.wy <- dfc%>% group_by(wy)%>% mutate_at(vars(Acanthoica_quattrospina:totalcount),sum) %>% distinct(wy,.keep_all = TRUE)

# head(dfc.wy)
df_to_rac = dfc.wy[order(dfc.wy$datetime),]

head(df_to_rac)

df.rank = copy(df_to_rac)
df.rel.abund = copy(df_to_rac)

#generate RAC plots at ALL time points   (takes ~15 min to run)
for(ii in seq(1,length(df_to_rac$datetime),1)){
    max_rank = 20
    # for testing out a couple RAC curves
    counts=as.data.frame(t(subset(df_to_rac, select=Acanthoica_quattrospina:zooplankton)[ii,])) #extracts vector of counts of each category at a given row
    colnames(counts) <- "count" #rename 1st column to count
    counts$species <- rownames(counts) #make rownames a column in the dataframe
    rownames(counts) <- NULL #remove rownames

    ii.sort = order(counts$count,decreasing = TRUE)

    #adding column for the relative rank of each species
    counts$rank <- NA
    counts$rank[ii.sort] <- 1:nrow(counts)
    counts <- counts %>% mutate(rel.abund = count/sum(count))
    
    #amend rank and relative abundance matricies with ranks and relative abundances
    df.rank[ii,which(colnames(df.rel.abund)=="Acanthoica_quattrospina"):which(colnames(df.rel.abund) == "zooplankton")] <- as.list(counts$rank)
    df.rel.abund[ii,which(colnames(df.rel.abund)=="Acanthoica_quattrospina"):which(colnames(df.rel.abund) == "zooplankton")] <- as.list(counts$rel.abund)

    # PLOTTING
    # options(repr.plot.width=11, repr.plot.height=8)
    # 
    # ggplot(counts,aes(x = rank,y = rel.abund, label = species)) +
    #   xlim(1,50)+ylim(0,1)+
    #       geom_point()+
    #       geom_line()+
    #       geom_text_repel(data = subset(counts, rank < max_rank, nudge_x = 0.1 ))+
    #       annotate("text", x = 40,y=0.9,size = 10,label = paste("n = ",df_to_rac$totalcount[ii]))+
    #      ggtitle(paste0("Weekly RAC ",df_to_rac$datetime[ii]))+
    # theme(text = element_text(size = 20))+
    # xlab("Rank")+
    # ylab("Relative Abundance")

    # result_path = paste0(basepath,"/results/weekly_rac/")
    # print(paste0(result_path,"racplot_",df_to_rac$datetime[ii],"_",sprintf("%03d", ii),".png"))
    #     print(paste0(ii," of ", length(df_to_rac$datetime)))
}

#render RAC plots to movie
# cmd = "bash plot_to_movie_weekly.sh"
# system(cmd)
# print("video rendered")

#convert from wide to long format gather(data,key,value,)
dfc.long <- pivot_longer(df_to_rac,Acanthoica_quattrospina:zooplankton,names_to = "species",values_to ="count",values_drop_na=TRUE)
dfc.long$conc <- dfc.long$count/dfc.long$milliliters_analyzed

dfrm <- RAC_change(df =dfc.long[complete.cases(dfc.long),],
           species.var = "species",
           abundance.var = "conc",
           time.var ="wy")

print("success at generating RAC output")
write.csv(dfrm, file = "/vortexfs1/scratch/msantos/rac/results/outputRAC_weekly_conc.csv")


