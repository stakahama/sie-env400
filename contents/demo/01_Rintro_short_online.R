########################################################################################
##
## ENV400 example script
## 2016 Mar
##
########################################################################################

## ------------------------------------------------------------------------
library(tidyverse)
library(chron)

## ------------------------------------------------------------------------
source("functions_extra.R")

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
ggplot(data)+
  geom_line(aes(datetime, O3))+
  scale_x_chron()

## To export, save graphics from RStudio pulldown menu, or print to pdf/png device

## Create an outputs directory.
dir.create("outputs")

## Save graphics to an object.
ggp <- ggplot(data)+
  geom_line(aes(datetime, O3))+
  scale_x_chron()

## Print to pdf file.
pdf("outputs/fig1.pdf")
print(ggp)
dev.off()
