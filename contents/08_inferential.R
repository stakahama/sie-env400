## ---- include=FALSE------------------------------------------------------
library(knitr)
opts_chunk$set(fig.path='figures_rmd/lec08_', fig.align='center', warning=FALSE, message=FALSE)

## ------------------------------------------------------------------------
library(dplyr)
library(reshape2)
library(chron)
library(ggplot2)

## ------------------------------------------------------------------------
source("GRB001.R")

## ---- results="hide"-----------------------------------------------------
Sys.setlocale("LC_TIME","C")
options(stringsAsFactors=FALSE)
options(chron.year.abb=FALSE)
theme_set(theme_bw()) # just my preference for plots

## ------------------------------------------------------------------------
df <- readRDS("data/2013/lau-zue.rds")

## ------------------------------------------------------------------------
id.vars <- c("site", "datetime", "year", "month", "day", "hour", "season", "dayofwk", "daytype")
lf <- melt(df %>% filter(site=="LAU"), id.vars=id.vars)

## ------------------------------------------------------------------------
ComputeStats <- function(x) {
  x <- na.omit(x)
  m <- mean(x)
  s <- sd(x)
  n <- length(x)
  t <- qt(.975, n - 1)
  data.frame(mean=m,
             conf.lower=m-t*s/sqrt(n),
             conf.upper=m+t*s/sqrt(n),
             sd.lower=m-s,
             sd.upper=m+s)
}

## ------------------------------------------------------------------------
table <- lf %>% filter(variable=="O3" &
                       month %in% c("Jan","Jul"))

mystats <- table %>%
  group_by(month, daytype) %>%
  do(ComputeStats(.[["value"]]))

head(mystats)

## ------------------------------------------------------------------------
ggp <- ggplot(table)+
  geom_boxplot(aes(daytype, value))+
  facet_wrap(~month)
print(ggp)

## ------------------------------------------------------------------------
ggp <- ggplot(mystats)+
  geom_bar(aes(x=daytype, y=mean), stat="identity", fill="gray")+
  geom_errorbar(aes(x=daytype,
                    ymin=sd.lower,
                    ymax=sd.upper),
                width=0.1)+
  facet_wrap(~month)
print(ggp)

## ------------------------------------------------------------------------
ggp <- ggplot(mystats)+
  geom_bar(aes(x=daytype, y=mean),
           stat="identity", fill="gray")+
  geom_errorbar(aes(x=daytype,
                    ymin=conf.lower,
                    ymax=conf.upper),
                width=0.1)+
  facet_wrap(~month)
print(ggp)

## ------------------------------------------------------------------------
(out <- t.test(filter(table, month=="Jul" & daytype=="Weekend")[["value"]],
               filter(table, month=="Jul" & daytype=="Weekday")[["value"]],
               alternative="greater"))


## ------------------------------------------------------------------------
out[["p.value"]]

## ------------------------------------------------------------------------
TTest <- function(value, daytype) {
  ## if all values are missing,
  ##   the t-test will raise an error
  wkend <- value[daytype=="Weekend"]
  wkday <- value[daytype=="Weekday"]
  if(length(na.omit(wkend)) > 0 & length(na.omit(wkday)) > 0) {
    out <- t.test(wkend, wkday, alternative="two.sided")
    data.frame(out["p.value"])
  } else {
    data.frame()
  }
}

pvals <- lf %>%
  filter(!variable %in% c("TEMP", "PREC", "RAD")) %>%
  group_by(site, season, variable) %>%
  do(TTest(.[["value"]], .[["daytype"]]))

ggplot(pvals) +
  facet_grid(site ~ season) +
  geom_point(aes(variable, p.value))+
  scale_y_log10()+
  geom_hline(yintercept = .05, linetype = 2)+
  theme(axis.text.x = element_text(angle=45, hjust=1))+
  labs(x="")

## ------------------------------------------------------------------------
library(fitdistrplus)

## ------------------------------------------------------------------------
hourly <- lf %>% filter(month=="Jul" & variable=="NO2")
concvec <- c(na.omit(hourly[["value"]]))
fit <- fitdist(concvec, "lnorm")

## ------------------------------------------------------------------------
print(fit)

## ------------------------------------------------------------------------
print(gofstat(fit))

## ------------------------------------------------------------------------
(pval.h <- gofstat(fit)[["chisqpvalue"]])

## ---- fig.width=7, fig.height=7------------------------------------------
plot(fit)

## ------------------------------------------------------------------------
ReplaceNonpositive <- function(x) {
  x <- na.omit(x)
  min.positive.value <- min(x[x>0])
  replace(x, x < min.positive.value, min.positive.value)
}

## ---- eval=FALSE---------------------------------------------------------
## fit <- fitdist(ReplaceNonpositive(concvec), "lnorm")

