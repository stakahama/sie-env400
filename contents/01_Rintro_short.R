########################################################################################
##
## ENV400 example script
## 2016 Mar
##
########################################################################################

## ------------------------------------------------------------------------
library(dplyr)
library(reshape2)
library(chron)
library(ggplot2)

## ------------------------------------------------------------------------
source("GRB001.R")

## ------------------------------------------------------------------------
Sys.setlocale("LC_TIME","C")
options(stringsAsFactors=FALSE)
options(chron.year.abb=FALSE)
theme_set(theme_bw()) # just my preference for plots

## ------------------------------------------------------------------------
filename <- "data/2013/LAU.csv"
file.exists(filename)

## ------------------------------------------------------------------------
data <- read.table(filename,sep=";",skip=6,
  col.names=c("datetime","O3","NO2","CO","PM10","TEMP","PREC","RAD"))

## ------------------------------------------------------------------------
head(data)

## ------------------------------------------------------------------------
str(data)

## ---- results='asis'-----------------------------------------------------
ColClasses(data)

## ------------------------------------------------------------------------
data[,"datetime"] <- as.chron(data[,"datetime"], "%d.%m.%Y %H:%M")
data[,"month"] <- months(data[,"datetime"])
data[,"date"] <- dates(data[,"datetime"])

## ------------------------------------------------------------------------
head(data)
str(data)

## ---- results='asis'-----------------------------------------------------
ColClasses(data)

## ---- fig.width=8, fig.height=5------------------------------------------
ggp <- ggplot(data)+
  geom_line(aes(datetime, O3))+
    scale_x_chron()
print(ggp)

dir.create("outputs")

pdf("outputs/fig1.pdf")
print(ggp)
dev.off()
