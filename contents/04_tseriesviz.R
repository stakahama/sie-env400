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
Month2Season(c(1, 3, 12))


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


## -----------------------------------------------------------------------------
datapath <- file.path("data", "2013")

df <- full_join(cbind(site="LAU", ReadTSeries(file.path(datapath, "LAU.csv"))),
                cbind(site="ZUE", ReadTSeries(file.path(datapath, "ZUE.csv"))))


## -----------------------------------------------------------------------------
head(df)
tail(df)


## -----------------------------------------------------------------------------
saveRDS(df, "data/2013/lau-zue.rds")


## -----------------------------------------------------------------------------
lf <- df %>%
  gather(variable, value,
         -c(site, datetime, season, year, month, day, hour, dayofwk, daytype))


## ---- warning=FALSE, fig.width=8, fig.height=10-------------------------------
  ggplot(lf)+                                        # `lf` is the data frame
  facet_grid(variable~site, scale="free_y")+         # panels created out of these variables
  geom_line(aes(datetime, value, color=site))+       # plot `value` vs. `time` as lines
  scale_x_chron()+                                   # format x-axis labels (time units)
  theme(axis.text.x=element_text(angle=30, hjust=1)) # rotate x-axis labels


## ---- warning=FALSE, fig.width=8, fig.height=10-------------------------------
  ggplot(lf) +
  facet_grid(variable ~ site, scale = "free_y") +
  geom_boxplot(aes(month, value), outlier.size = 0.5, outlier.shape = 3)


## ---- warning=FALSE, fig.width=8, fig.height=8--------------------------------
lf %>%
  filter(site=="LAU" & !is.na(value)) %>%
  ggplot +
  facet_grid(variable ~ season, scale = "free_y") +
  geom_boxplot(aes(daytype, value), outlier.size = 0.5, outlier.shape = 3)


## -----------------------------------------------------------------------------
lf %>%
  filter(site=="LAU" & !is.na(value) & variable=="PREC") %>%
  


## ---- message=FALSE, warning=FALSE, fig.width=8, fig.height=8-----------------
library(gridExtra)

ggp1 <- lf %>%
  filter(site=="LAU" & !is.na(value) & variable!="PREC") %>%
  ggplot +
  facet_grid(variable ~ season, scale = "free_y") +
  geom_boxplot(aes(daytype, value), outlier.size = 0.5, outlier.shape = 3) +
  labs(x="")

ggp2 <- lf %>%
  filter(site=="LAU" & !is.na(value) & variable=="PREC") %>%
  ggplot +
  facet_grid(variable ~ season, scale = "free_y") +
  geom_bar(aes(daytype, value), stat="sum", show.legend = FALSE) +
  scale_y_continuous(expand=expansion(mult=c(0, 0.1)))

grid.arrange(ggp1, ggp2)


## -----------------------------------------------------------------------------
Percentile <- function(perc) function(x) 
  ## `perc` is the percentile which should be computed for the numeric vector `x`
  quantile(x, perc*1e-2, na.rm=TRUE)


## ---- warning=FALSE, fig.width=8, fig.height=10-------------------------------
lf %>%
  filter(site=="LAU" & !is.na(value)) %>%
  ggplot(aes(x=hour, y=value, group=daytype, color=daytype)) +
  facet_grid(variable ~ season, scale = "free_y", drop=TRUE) +
  geom_line(stat="summary", fun="median")+
  geom_errorbar(stat="summary",
                fun.min=Percentile(25),
                fun.max=Percentile(75))+
  ggtitle("LAU")


## ---- warning=FALSE, fig.width=8, fig.height=4--------------------------------
lf %>%
  filter(variable=="O3") %>%
  ggplot(aes(x=hour, y=value, group=daytype, color=daytype)) +
  facet_grid(site ~ season, drop=TRUE) +
  geom_line(stat="summary", fun="median")+
  geom_errorbar(stat="summary",
                fun.min=Percentile(25),
                fun.max=Percentile(75))+
  ggtitle("O3")


## ---- warning=FALSE, fig.width=8, fig.height=5--------------------------------
lf %>%
  filter(variable=="NO2") %>%
  ggplot(aes(x=hour, y=value, group=site, color=site)) +
  facet_grid(season ~ dayofwk, drop=TRUE) +
  geom_line(stat="summary", fun="median")+
  geom_errorbar(stat="summary",
                fun.min=Percentile(25),
                fun.max=Percentile(75))+
  ggtitle("NO2")


## -----------------------------------------------------------------------------
Ox <- lf %>% 
  filter(variable %in% c("O3", "NO2") & season=="JJA") %>%
  spread(variable, value) %>%
  mutate(Ox = O3 + NO2) %>%
  select(-NO2) %>%
  gather(variable, value, c(O3, Ox))


## ---- message=FALSE, warning=FALSE, fig.width=8, fig.height=6-----------------
Ox %>%
  ggplot(aes(x=hour, y=value, group=variable, color=variable)) +
  facet_grid(site ~ daytype, drop=TRUE) +
  geom_line(stat="summary", fun="median")+
  geom_errorbar(stat="summary",
                fun.min=Percentile(25),
                fun.max=Percentile(75))


## ---- message=FALSE, warning=FALSE, fig.width=8, fig.height=6-----------------
Ox %>% 
  spread(variable, value) %>%
  mutate(ratio = 1 - O3/Ox) %>%
  ggplot(aes(x=hour, y=ratio)) +
  facet_grid(site ~ daytype, drop=TRUE) +
  geom_line(stat="summary", fun="median")+
  geom_errorbar(stat="summary",
                fun.min=Percentile(25),
                fun.max=Percentile(75)) +
  scale_y_continuous(expression(NO[2]/O[x]), limits=c(0, 1))


## -----------------------------------------------------------------------------
limits.daily <- data.frame(value=c(100,80,8,50),
                           variable=c("SO2","NO2","CO","PM10"))


## -----------------------------------------------------------------------------
daily <- lf %>%
  filter(variable %in% limits.daily[["variable"]]) %>% # select variables
  mutate(date = dates(datetime)) %>%                   # get the date value
  group_by(site, date, variable) %>%
  summarize(percent.recovery = length(na.omit(value))/length(value)*1e2,
            value = mean(value, na.rm=TRUE)) %>%
  ungroup()                                            # undo grouping for future use


## -----------------------------------------------------------------------------
threshold <- 75


## -----------------------------------------------------------------------------
daily %>%
  filter(percent.recovery < threshold) %>%
  count(site, variable)


## -----------------------------------------------------------------------------
filter(daily, percent.recovery < threshold & variable=="PM10")


## ---- fig.width=7, fig.height=6-----------------------------------------------
daily %>%
  filter(percent.recovery >= threshold) %>%
  ggplot+
  facet_grid(variable~site, scale="free_y")+  
  geom_line(aes(x=date, y=value))+
  geom_hline(data=limits.daily, mapping=aes(yintercept=value), linetype=2)+
  scale_x_chron(format="%d.%m")+
  theme(axis.text.x=element_text(angle=30, hjust=1))


## ---- fig.width=7, fig.height=6-----------------------------------------------
daily %>%
  filter(percent.recovery >= threshold) %>%
  ggplot+
  facet_grid(variable~site, scale="free_y")+  
  geom_line(aes(x=value), stat="ecdf")+
  geom_point(aes(x=value), stat="ecdf")+
  geom_vline(data=limits.daily, mapping=aes(xintercept=value), linetype=2)


## -----------------------------------------------------------------------------
(limits.vec <- with(limits.daily, setNames(value, variable)))


## -----------------------------------------------------------------------------
exceedances <- daily %>%
  filter(percent.recovery >= threshold &
         value > limits.vec[as.character(variable)])


## -----------------------------------------------------------------------------
head(exceedances)
tail(exceedances)


## -----------------------------------------------------------------------------
exceedances %>%
  count(site, variable)


## -----------------------------------------------------------------------------
exceedances %>%
  mutate(month = months(date)) %>%
  count(site, variable, month)


## ---- eval=FALSE--------------------------------------------------------------
## write.csv2(exceedances, file="exceedances.csv", row.names=FALSE)

