## Edited from
## https://github.com/AndyClifton/SurfaceStationSummary/blob/master/functions/WindRose.R

## WindRose.R
library(ggplot2)
library(RColorBrewer)

plotWindrose <- function(data,
                         spd        = "speed",
                         dir        = "direction",
                         spdres     = 2,
                         dirres     = 30,
                         spdmin     = floor(min(data[[spd]], na.rm=TRUE)),
                         spdmax     = ceiling(max(data[[spd]], na.rm=TRUE)),
                         palette    = "YlGnBu",
                         countmax   = NA,
                         decreasing = FALSE,
                         debug      = 0) {

  ## check inputs ----
  if (debug>0){
    cat("Speed = ", spd, "\n")
    cat("Direction = ", dir, "\n")
  }

  ## Tidy up input data ----
  dnu <- (is.na(data[[spd]]) | is.na(data[[dir]]))
  data<- data[!dnu,]

  ## figure out the wind speed bins ----
  n.colors.in.range <- length(seq(spdmin,spdmax,spdres))-1
  speedcuts.colors = colorRampPalette(brewer.pal(min(max(3,
                                                         n.colors.in.range),
                                                     min(9,
                                                         n.colors.in.range)),
                                                 palette))(n.colors.in.range)
  
  speedcuts.breaks <- c(seq(spdmin,spdmax,by = spdres))
  speedcuts.labels <- paste(c(seq(spdmin,spdmax-spdres,by = spdres)),
                            '-',
                            c(seq(spdmin+spdres,spdmax,by = spdres)))
  
  if(max(speedcuts.breaks) < spdmax){ ## edit 05.04.2019
    spdmax. <- spdmax + spdres
    speedcuts.breaks <- c(seq(spdmin,spdmax.,by = spdres))
    speedcuts.labels <- paste(c(seq(spdmin,spdmax.-spdres,by = spdres)),
                              '-',
                              c(seq(spdmin+spdres,spdmax.,by = spdres)))
    speedcuts.colors <- c(speedcuts.colors, "grey50")
  }

  if (debug > 0){
    cat(speedcuts.colors, "\n")
  }

  ## Bin wind speed data ----
  data$spd.binned <- cut(data[[spd]],
                         breaks = speedcuts.breaks,
                         labels = speedcuts.labels,
                         include.lowest = TRUE, # edit 05.04.2019
                         ordered_result = TRUE)
  if(!decreasing) { ## ST
    ## reverse order
    data$spd.binned <- with(data, factor(spd.binned, rev(levels(spd.binned))))
    speedcuts.colors <- rev(speedcuts.colors)
  }

  ## figure out the wind direction bins
  dir.breaks <- c(-dirres/2,
                  seq(dirres/2, 360-dirres/2, by = dirres),
                  360+dirres/2)
  dir.labels <- c(paste(360-dirres/2,"-",dirres/2),
                  paste(seq(dirres/2, 360-3*dirres/2, by = dirres),
                        "-",
                        seq(3*dirres/2, 360-dirres/2, by = dirres)),
                  paste(360-dirres/2,"-",dirres/2))

  ## assign each wind direction to a bin
  if (debug>0){
    cat(dir.breaks,"\n")
    cat(dir.labels,"\n")
  }

  data$dir.binned <- cut(data[[dir]],
                         breaks = dir.breaks,
                         ordered_result = TRUE)
  levels(data$dir.binned) <- dir.labels

  ## Run debug if required ----
  if (debug>0){
    cat("levels(dir.binned) = ",levels(data$dir.binned),"\n")
    cat("names(data) = ", names(data), "\n")
    if (debug >1){
      cat(spd.binned,"\n")
      cat(dir.binned,"\n")
    }
  }

  ## create the plot ----
  plot.windrose <- ggplot(data = data,
                          aes(x = dir.binned,
                              fill = spd.binned)) +
    geom_bar()

  plot.windrose <- plot.windrose +
    scale_x_discrete(drop = FALSE,
                     labels = waiver()) +
    coord_polar(start = -((dirres/2)/360) * 2*pi) +
    scale_fill_manual(name = "Wind Speed (m/s)",
                      values = speedcuts.colors,
                      drop = FALSE) +
    labs(x = "") ## so it doesn't conflict with theme()
  ## theme(axis.title.x = element_blank())

  ## adjust axes if required
  if (!is.na(countmax)){
    plot.windrose <- plot.windrose +
      ylim(c(0,countmax))
  }

  ## print the plot
  ## print(plot.windrose)
  if(!decreasing) { ## ST
    plot.windrose <- plot.windrose +
      guides(fill = guide_legend(reverse = TRUE))
  }

  ## return the handle to the wind rose
  return(plot.windrose)
}
