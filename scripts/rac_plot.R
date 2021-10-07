library("dplyr")
library("tidyr")
library("ggplot2")
library("lubridate")
library("ggrepel")

dfc = read.csv('/D/MIT-WHOI/data/2021/concentration_by_class_time_series_CNN_daily08Sep2021.csv') #daily biovol concentration
cl =  read.csv('/D/MIT-WHOI/data/2021/IFCB_classlist_type.csv') #importing 

mapf <- function(Fgroup){ #generates list of species within the specified functional group
    which(colnames(dfc) %in% cl[cl[Fgroup] == 1,]$CNN_classlist)} 

#removing categories within the Other.not.alive and the IFCB.artifact groups from dfc
dfc <- dfc %>% select(-c(mapf("Other.not.alive"),mapf("IFCB.artifact")))


#LONG FOR LOOP
result_path = "/D/MIT-WHOI/github_repos/plankton-index/results/"


for (ii in seq(1,1,1)) {
    counts=as.data.frame(t(dfc[ii,3:ncol(dfc)]*dfc[1,2])) #extracts vector of counts of each category at a given row
    colnames(counts) <- "count" #rename 1st column to count
    counts$species <- rownames(counts) #make rownames a column in the dataframe
    rownames(counts) <- NULL #remove rownames
    counts = counts %>% arrange(desc(count)) %>% 
            mutate("rank"=seq(1,length(counts$count),1),"rel.abund" = count/sum(count)) #adding rank and relative abundance

    #adding another row with just top 10 species to display on graph
    counts$rank_show <- counts$species
    counts$rank_show[10:length(counts$rank_show)] <- " "
    
    options(repr.plot.width=11, repr.plot.height=8)
    ggplot(counts,aes(x = rank,y = rel.abund, label = rank_show)) +
        xlim(1,60)+ylim(0,1)+
          geom_point()+geom_line()+geom_text_repel()+
         ggtitle(paste0("Daily RAC ",dfc[ii,1]))+
    theme(text = element_text(size = 20))
    ggsave(paste0(result_path,"plot-",ii,".png"))
    print(paste0(ii," of ", length(dfc$datetime)))
    }


# runs bash script that runs ffmpeg to compile figures together into movie
cmd = "bash plot_to_movie.sh"
system(cmd)
