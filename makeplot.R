
require("ggplot2")

data.f1 = read.csv("logLikeAutoCorrelation.f1-s0-j0-r0.csv")
data.f1s1 = read.csv("logLikeAutoCorrelation.f1-s1-j0-r0.csv")
data.f1$Kernel = "Flip"
data.f1s1$Kernel = "Flip + step"
dat = rbind(data.f1,data.f1s1)
ggplot(aes(x=tau, y=logLikeAutoCorrelation, color=Kernel), data=dat) + geom_line() + xlim(0,1024) + ylim(0,1) + ylab("Log-likelihood autocorrelation") + xlab("Samples per term")
ggsave("plot.pdf")