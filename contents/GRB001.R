## GRB001 specific-configurations

if(!exists("scale_x_chron",where="package:chron"))
  scale_x_chron <- function (..., format = "%Y-%m-%d", n = 5) {
    ggplot2::scale_x_continuous(..., trans = chron_trans(format, n))
  }

if(!exists("chron_trans",where="package:chron"))
  chron_trans <- function (format = "%Y-%m-%d", n = 5) {
    breaks. <- function(x) chron((scales::pretty_breaks(n))(x))
    format. <- function(x) format(as.POSIXct(x, tz = "GMT"), 
                                  format = format)
    scales::trans_new("chron", transform = as.numeric, inverse = chron, 
                      breaks = breaks., format = format.)
  }

scale_dimension.custom_expand <- function(scale, expand=ggplot2:::scale_expand(scale)) {
  scales::expand_range(ggplot2:::scale_limits(scale),
                       mul=expand[[1]],add=expand[[2]])
}

scale_y_custom <- function(...) {
  scale <- ggplot2::scale_y_continuous(...)
  class(scale) <- c('custom_expand', class(scale))
  scale
}

scale_y_expand <- function(expand) {
  scale <- ggplot2::scale_y_continuous(expand=list(expand, c(0,0)))
  class(scale) <- c('custom_expand', class(scale))
  scale
}

rotate.text.x <- function(angle=30, hjust=1) {
  theme(axis.text.x=element_text(...))
}

format.times.x <- function(format="%d.%m", expand=c(0,0)) {
  scale_x_chron(...)
}

ColClasses <- function(x) {
  kable(as.data.frame(Map(function(x) paste(class(x), collapse=","), x)))
}
