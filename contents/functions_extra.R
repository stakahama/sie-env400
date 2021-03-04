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
