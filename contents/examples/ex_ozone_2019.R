## ---- include=FALSE-----------------------------------------------------------
library(knitr)
opts_chunk$set(fig.path=file.path("figures_rmd", "lec04_"), fig.align="center")


## ---- message=FALSE, warning=FALSE--------------------------------------------
library(tidyverse)
library(chron)


## -----------------------------------------------------------------------------
source("functions_extra.R")


## ---- results="hide"----------------------------------------------------------
Sys.setlocale("LC_TIME","C")
options(stringsAsFactors=FALSE)
options(chron.year.abb=FALSE)
theme_set(theme_bw()) # just my preference for plots


## -----------------------------------------------------------------------------
Month2Season <- function(month) {
  ## month is an integer (1-12)
  ## a factor with levels {"DJF", "MAM", "JJA", "SON"} is returned
  seasons <- c("DJF", "MAM", "JJA", "SON")
  index <- findInterval(month %% 12, seq(0, 12, 3))
  factor(seasons[index], seasons)
}


## -----------------------------------------------------------------------------
ReadTSeries <- function(filename, timecolumn="datetime", timeformat="%d.%m.%Y %H:%M") {
  ## read the table, strip units in column names, rename time column
  ##   and change data type of time column from a string of characters to
  ##   a numeric type so that we can perform operations on it
  data <- read.table(filename, skip=5, header=TRUE, sep=";", check.names=FALSE)
  names(data) <- sub("[ ].*$","",names(data)) # strip units for simplification
  names(data) <- sub("Date/time", timecolumn, names(data), fixed=TRUE)
  data[,timecolumn] <- as.chron(data[,timecolumn], timeformat) - 1/24 # end time -> start time
  ## extract additional variables from the time column
  data[,"year"] <- years(data[,timecolumn])
  data[,"month"] <- months(data[,timecolumn])
  data[,"day"] <- days(data[,timecolumn])
  data[,"hour"] <- hours(data[,timecolumn])
  data[,"dayofwk"] <- weekdays(data[,timecolumn])
  data[,"daytype"] <- ifelse(data[,"dayofwk"] %in% c("Sat","Sun"), "Weekend", "Weekday")
  data[,"season"] <- Month2Season(unclass(data[,"month"]))
  ## return value
  data
}

df <- full_join(cbind(site="ZUE", ReadTSeries("ex_ZUE_2019.csv")),
                cbind(site="RIG", ReadTSeries("ex_RIG_2019.csv")))

lf <- df %>%
  mutate(NO = NOX - NO2,
         NO.NOX = NO/NOX,
         NO2.NO = NO2/NO,
         OX = O3 + NO2,
         Pr = NO2.NO * RAD) %>%
  gather(variable, value,
         -c(site, datetime, season, year, month, day, hour, dayofwk, daytype)) 

lf %>%
  filter(variable %in% c("NOX", "NO.NOX", "NO2.NO", "O3", "OX", "RAD", "TEMP")) %>%
  ggplot(aes(x=hour, y=value, group=daytype, color=daytype)) +  
  facet_grid(variable ~ season, scale = "free_y", drop=TRUE) +
  geom_line(stat="summary", fun="median")+
  geom_errorbar(stat="summary",
                fun.min=Percentile(25),
                fun.max=Percentile(75))

## -----------------------------------------------------------------------------

llf <- lf %>%
  filter(variable %in% c("NOX", "NO.NOX", "NO2.NO", "O3", "OX", "RAD", "TEMP")) %>%
  group_by(site, variable, hour, season, daytype) %>%
  summarize(value = median(value, na.rm=TRUE))

llf %>%
  filter(daytype=="Weekday" & season=="JJA") %>%
  mutate(variable = factor(variable, c("RAD", "TEMP", "O3", "NOX", "OX", "NO.NOX", "NO2.NO"),
                           c("RAD", "TEMP", "O3", "NOX", "OX", "NO/NOX", "NO2/NO"))) %>%
  ggplot +  
  facet_grid(variable ~ ., scale = "free_y", drop=TRUE) +
  geom_line(aes(x=hour, y=value, color=site), size=1.2)

## -----------------------------------------------------------------------------

llf <- lf %>%
  filter(variable %in% c("O3", "Pr")) %>%
  group_by(site, variable, hour, season, daytype) %>%
  summarize(value = median(value, na.rm=TRUE))

llf %>%
  filter(daytype=="Weekday" & season=="JJA") %>%
  group_by(variable, site) %>%
  mutate(value = value / value[hour==15]) %>%
  ggplot +  
  facet_grid(. ~ site, scale = "free_y", drop=TRUE) +
  geom_line(aes(x=hour, y=value, color=variable))

