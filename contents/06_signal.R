## ---- include=FALSE-----------------------------------------------------------
library(knitr)
opts_chunk$set(fig.path='figures_rmd/lec06_', fig.align='center', warning=FALSE, message=FALSE)


## -----------------------------------------------------------------------------
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
df <- readRDS("data/2013/lau-zue.rds")


## -----------------------------------------------------------------------------
id.vars <- c("site", "datetime", "year", "month", "day", "hour", "season", "dayofwk", "daytype")
lf <- df %>%
  filter(site=="ZUE") %>%
  gather(variable, value, -all_of(id.vars))


## -----------------------------------------------------------------------------
SelfLag <- function(x, k) {
  data.frame(lag=k, x0=head(x,-k), xk=tail(x,-k))
}

lagged <- lf %>%
  group_by(site, season, variable) %>%
  do(rbind(SelfLag(.[["value"]], 1),
           SelfLag(.[["value"]], 3),
           SelfLag(.[["value"]], 5),
           SelfLag(.[["value"]], 7)))


## ---- fig.width=7, fig.height=7-----------------------------------------------
ggplot(filter(lagged, variable=="RAD"))+
  geom_abline(intercept=0, slope=1)+  
  geom_point(aes(x0, xk), shape=3, color="gray")+
  facet_grid(lag~season)+
  labs(x=expression(x(t[0])), y=expression(x(t[k])))


## ---- fig.width=7, fig.height=7-----------------------------------------------
filter(lagged, variable=="TEMP") %>%
  ggplot+
  geom_abline(intercept=0, slope=1)+  
  geom_point(aes(x0, xk), shape=3, color="gray")+
  facet_grid(lag~season)+
  labs(x=expression(x(t[0])), y=expression(x(t[k])))


## -----------------------------------------------------------------------------
Autocorrelation <- function(x, ...) {
  with(acf(x, ..., na.action=na.pass, plot=FALSE),
       data.frame(lag, acf))
}

autocorr <- lf %>% group_by(site, season, variable) %>%
  do(Autocorrelation(.[["value"]], lag.max=6))


## ---- fig.width=7, fig.height=9-----------------------------------------------
ggplot(autocorr)+
  geom_hline(yintercept=0)+        
  geom_point(aes(lag, acf))+
  geom_segment(aes(lag, 0, xend=lag, yend=acf))+
  facet_grid(variable~season)+
  labs(x="lag", y="acf")


## ---- error=TRUE--------------------------------------------------------------
ix <- "ZUE"==df[["site"]] & "JJA"==df[["season"]]
spec <- spectrum(df[ix,"CO"])


## -----------------------------------------------------------------------------
PercentRecovery <- function(x) {
  length(na.omit(x))/length(x)*1e2
}

PercentRecovery(df[ix,"CO"])


## -----------------------------------------------------------------------------
out <- approx(df[ix,"datetime"], df[ix,"CO"], df[ix,"datetime"])
str(out)


## ---- spec.plot---------------------------------------------------------------
spec <- spectrum(out[["y"]])


## ---- echo=-1-----------------------------------------------------------------
spec <- spectrum(out[["y"]])
hrs <- c("4-hr"=4, "6-hr"=6, "8-hr"=8, "12-hr"=12, "daily"=24, "weekly"=24*7, "monthly"=24*30)
abline(v=1/hrs, col=seq(hrs)+1, lty=2)
legend("topright", names(hrs), col=seq(hrs)+1, lty=2, bg="white")


## -----------------------------------------------------------------------------
data.frame(lf %>% group_by(site, season, variable) %>%
  summarize(recovery=sprintf("%.0f%%",PercentRecovery(value))))


## -----------------------------------------------------------------------------
Spectr <- function(x, y) {
  out <- approx(x, y, xout=x)
  spec <- spectrum(out[["y"]], plot=FALSE)
  data.frame(spec[c("freq", "spec")])
}

spec <- lf %>% group_by(site, season, variable) %>%
  do(Spectr(.[["datetime"]],.[["value"]]))


## ---- fig.width=8, fig.height=8-----------------------------------------------
period <- data.frame(label=factor(names(hrs), names(hrs)), freq=1/hrs)

ggplot(spec)+
  geom_vline(aes(xintercept=freq, color=label), data=period, linetype=2)+  
  geom_line(aes(freq, spec))+
  facet_grid(variable~season, scale="free_y")+
  scale_y_log10()+
  scale_x_log10()


## -----------------------------------------------------------------------------
daily <- lf %>%
  mutate(date=dates(datetime)) %>%
  group_by(site, variable, season, date) %>%
  summarize(value=mean(value, na.rm=TRUE))

spec.daily <- daily %>% group_by(site, season, variable) %>%
  do(Spectr(.[["date"]],.[["value"]]))

period.daily <- data.frame(label=c("weekly", "monthly"),
                           freq =1/c(7, 30))


## ---- fig.width=7, fig.height=7-----------------------------------------------
ggplot(spec.daily)+
  geom_vline(aes(xintercept=freq, color=label), data=period.daily, linetype=2)+  
  geom_line(aes(freq, spec))+
  facet_grid(variable~season, scale="free_y")

