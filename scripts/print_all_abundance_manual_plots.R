library("dplyr")
library("tidyr")
library("ggplot2") #for plotting
library("lubridate") #working with dates
library("ggrepel") #for getting date labels to repel plot line
library("data.table")
library("zoo")
library("scales")
library("codyn")

basepath = "/D/MIT-WHOI/github_repos/plankton-index/data/"

df.class2use <- read.csv(paste0(basepath,"class2use.csv"))
dfm <- read.csv(paste0(basepath,"classcount.csv"),header = FALSE)

names(dfm) <- as.matrix(df.class2use[1,])

df.date <- read.csv(paste0(basepath,"manual_mat_date.csv"),header = FALSE)

dfm$datetime <- as.Date(ISOdatetime(df.date[,1],df.date[,2],df.date[,3],df.date[,4],df.date[,5],df.date[,6],tz = "UTC"))
head(dfm)

options(repr.plot.width=14, repr.plot.height=10) #set plot size


for ii in seq(1,1,ncol()
species = "Chaetoceros"
ggplot(data = dfm, aes_string(x = "datetime", y = species)) +
    geom_point(size = 1) +
    theme(text = element_text(size = 20))+
    scale_x_date(breaks = "1 year", labels=date_format("%Y"))+
    ggtitle(paste0("Manual ",species," Abundance at MVCO"))+
    ylab(paste0(species," Abundance"))+
    xlab("Year")
