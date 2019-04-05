
angle.test <- function(theta) {
  theta.rad <- theta*pi/180
  x <- cos(theta.rad)
  y <- sin(theta.rad)
  theta.deg <- atan2(y, x)*180/pi
  ifelse(theta.deg < 0, (theta.deg + 360) %% 360L, theta.deg)
}

plot(0:361, aat(0:361))

angle.test(360)

