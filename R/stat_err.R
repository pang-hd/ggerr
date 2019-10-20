## See https://community.rstudio.com/t/using-stat-instead-of-dplyr-to-summarize-groups-in-a-ggplot/13916/7?u=tp2750

SE <- function(x) sqrt(stats::var(x)/length(x))

StatErr <- ggplot2::ggproto("StatErr", Stat,
           compute_group = function(data, scales, na.rm = FALSE, spread = "sd", mult = 1) {
    x <- na.omit(data$x)
    y <- na.omit(data$y)
    xMean <- mean(x)
    yMean = mean(y)
    if(spread == "sd") {
      xDelta <- mult * sd(x)
      yDelta <- mult * sd(y)
    } else if(spread == "se") {
      xDelta = mult * SE(x)
      yDelta = mult * SE(y)
    } else {
      stop("stat_err only knows spreads: 'sd', 'se'")
    }
      data.frame(x=xMean, y=yMean, ymax=yMean + yDelta, ymin = yMean - yDelta, xmax = xMean + xDelta, xmin = xMean - xDelta)
  }
)

##' stat_err adds error-bars to scatterplot
##'
##' Adding a point at the median, and vertical errorbars requirer two call to stat_err(). Adding a horizontal error bar needs one more call.
##' ggplot(data =  iris, aes(x= Petal.Length, y=Petal.Width, group=Species)) + geom_point(aes(color=Species)) + stat_err(width=.1, spread = "se", mult = 2) + stat_err(geom="point") + stat_err(geom="errorbarh", height=.1, spread = "se", mult = 2)
##' @title stat_err
##' @param mapping needs some grouping, eg color or group in aes()
##' @param data normally inherited from call to ggplot()
##' @param geom use "errorbars" for vertical errorbar, "errorbarh" for horizontal errorbar, "point" for mean
##' @param position leave as "identity"
##' @param na.rm not used
##' @param show.legend std ggplot
##' @param inherit.aes std ggplot
##' @param ... passed on 
##' @param spread statistics to use: "sd" for standard deviation, "se" for standard error
##' @param mult factor to multiply on the "spread". Default 1 means error-bars are +/- 1 sd around the mean
##' @return used in ggplot()
##' @examples
##' ggplot(data =  iris, aes(x= Petal.Length, y=Petal.Width, group=Species)) +
##'   geom_point(aes(color=Species)) +
##'   stat_err(width=.1, spread = "se", mult = 2) +
##'   stat_err(geom="point") +
##'   stat_err(geom="errorbarh", height=.05, spread = "se", mult = 2)
##' @export
##' @import ggplot2
##' @author Thomas Poulsen
stat_err <- function(mapping = NULL, data = NULL, geom = "errorbar",
                        position = "identity", na.rm = FALSE, show.legend = NA, 
                        inherit.aes = TRUE, ..., spread = "sd", mult = 1) {
    ggplot2::layer(
                 data = data,
                 mapping = mapping,
                 stat = StatErr,
                 geom = geom,
                 position = position,
                 show.legend = show.legend,
                 inherit.aes = inherit.aes,
                 params = list(
                     spread = spread,
                     mult = mult,
                     ...
                 )
             )
}
