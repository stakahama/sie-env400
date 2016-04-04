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

if(!exists("full_join",where="package:dplyr"))
  full_join <- function(...) merge(..., all=TRUE)

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
  classes <- as.data.frame(Map(function(x) paste(class(x), collapse=","), x))
  proceed <- require(knitr)
  if(proceed) table <- kable(classes)
  classes
}


dixon.test <- function (x, type = 0, opposite = FALSE, two.sided = TRUE) {
  ## from the outlier library
  DNAME <- deparse(substitute(x))
  x <- sort(x[complete.cases(x)])
  n <- length(x)
  if ((type == 10 || type == 0) & (n < 3 || n > 30)) 
    stop("Sample size must be in range 3-30")
  if (type == 11 & (n < 4 || n > 30)) 
    stop("Sample size must be in range 4-30")
  if (type == 12 & (n < 5 || n > 30)) 
    stop("Sample size must be in range 5-30")
  if (type == 20 & (n < 4 || n > 30)) 
    stop("Sample size must be in range 4-30")
  if (type == 21 & (n < 5 || n > 30)) 
    stop("Sample size must be in range 5-30")
  if (type == 22 & (n < 6 || n > 30)) 
    stop("Sample size must be in range 6-30")
  if (sum(c(0, 10, 11, 12, 20, 21, 22) == type) == 0) 
    stop("Incorrect type")
  if (type == 0) {
    .type <- c(10, 11, 21, 22)
    type <- .type[1+findInterval(n, c(7, 10, 13), TRUE)]
  }
  if (xor(((x[n] - mean(x)) < (mean(x) - x[1])), opposite)) {
    alt <- paste("lowest value", x[1], "is an outlier")
    Q <- switch(sprintf("%d", type),
                "10"=(x[2] - x[1])/(x[n] - x[1]),
                "11"=(x[2] - x[1])/(x[n - 1] - x[1]),
                "12"=(x[2] - x[1])/(x[n - 2] - x[1]),
                "20"=(x[3] - x[1])/(x[n] - x[1]),
                "21"=(x[3] - x[1])/(x[n - 1] - x[1]),
                (x[3] - x[1])/(x[n - 2] - x[1]))
  }
  else {
    alt <- paste("highest value", x[n], "is an outlier")
    Q <- switch(sprintf("%d", type),
                "10"=(x[n] - x[n - 1])/(x[n] - x[1]),
                "11"=(x[n] - x[n - 1])/(x[n] - x[2]),
                "12"=(x[n] - x[n - 1])/(x[n] - x[3]),
                "20"=(x[n] - x[n - 2])/(x[n] - x[1]),
                "21"=(x[n] - x[n - 2])/(x[n] - x[2]),
                (x[n] - x[n - 2])/(x[n] - x[3]))
  }
  pval <- pdixon(Q, n, type)
  if (two.sided) {
    pval <- 2 * pval
    if (pval > 1) 
      pval <- 2 - pval
  }
  RVAL <- list(statistic = c(Q = Q), alternative = alt, p.value = pval, 
               method = "Dixon test for outliers", data.name = DNAME)
  class(RVAL) <- "htest"
  return(RVAL)
}
