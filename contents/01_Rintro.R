## ---- include=FALSE------------------------------------------------------
library(knitr)
opts_chunk$set(fig.path='figures_rmd/lec01_', fig.align='center', warning=FALSE, message=FALSE)

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

## ------------------------------------------------------------------------
unique.months <- levels(data[,"month"])

O3.monthly <- NULL
for(.month in unique.months) {
  table <- data %>% filter(month == .month)
  tmp <- data.frame(month=.month, O3=mean(table[,"O3"], na.rm=TRUE))
  O3.monthly <- rbind(O3.monthly, tmp)
}

print(O3.monthly)

## ------------------------------------------------------------------------
class(O3.monthly[,"month"])
O3.monthly[,"month"] <- factor(O3.monthly[,"month"], unique.months)
class(O3.monthly[,"month"])

## ---- fig.width=8, fig.height=5------------------------------------------
ggp <- ggplot(O3.monthly) +
  geom_bar(aes(month, O3), stat="identity")
print(ggp)

## ------------------------------------------------------------------------
unique.dates <- unique(data[,"date"])
O3.dailymax <- NULL
for(.date in unique.dates) {
  table <- data %>% filter(date == .date)
  tmp <- data.frame(date=.date, O3=max(table[,"O3"], na.rm=TRUE))
  O3.dailymax <- rbind(O3.dailymax, tmp)
}

head(O3.dailymax)

## ------------------------------------------------------------------------
class(O3.dailymax[,"date"])
O3.dailymax[,"date"] <- as.chron(O3.dailymax[,"date"])
class(O3.dailymax[,"date"])

## ------------------------------------------------------------------------
head(O3.dailymax)
tail(O3.dailymax)

## ---- fig.width=8, fig.height=5------------------------------------------
ggp <- ggplot(O3.dailymax) +
  geom_line(aes(O3),stat="ecdf") +
    labs(y = "ECDF")
print(ggp)

## ------------------------------------------------------------------------
data %>% group_by(month) %>%
  summarize(O3 = mean(O3, na.rm=TRUE))

## ------------------------------------------------------------------------
data %>% group_by(month) %>%
  summarize(O3 = mean(O3, na.rm=TRUE),
            NO2 = mean(NO2, na.rm=TRUE))

## ------------------------------------------------------------------------
lf <- melt(data, id.vars=c("datetime", "month", "date"))

## ------------------------------------------------------------------------
head(lf)
tail(lf)

## ---- results='asis'-----------------------------------------------------
ColClasses(lf)

## ---- fig.width=8, fig.height=12-----------------------------------------
ggp <- ggplot(lf) +
  geom_line(aes(datetime, value))+
    facet_grid(variable~., scale="free_y") +
      scale_x_chron()
print(ggp)

## ------------------------------------------------------------------------
result <- lf %>% group_by(month, variable) %>%
  summarize(value = mean(value, na.rm=TRUE))

## ------------------------------------------------------------------------
dcast(result, month~variable)

## ------------------------------------------------------------------------
dcast(lf, month~variable, fun.aggregate=mean, na.rm=TRUE)

## ---- fig.width=8, fig.height=12-----------------------------------------
ggp <- ggplot(lf) +
  geom_bar(aes(month, value), stat="summary", fun.y="mean")+
    facet_grid(variable~., scale="free_y")
print(ggp)

## ---- fig.width=8, fig.height=12-----------------------------------------
ggp <- ggplot(lf, aes(month, value)) +
  geom_bar(stat="summary", fun.y="mean")+
    geom_errorbar(stat="summary",
                  fun.ymin=min, #function(x) quantile(x, .25),
                  fun.ymax=max, #function(x) quantile(x, .75))+
                  width=0.1) +
    facet_grid(variable~., scale="free_y")
print(ggp)

