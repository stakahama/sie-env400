#!/bin/sh

## requires installation of pandoc or addition of pandoc included with RStudio

R -e "rmarkdown::render('$1')"
