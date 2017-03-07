require("ggplot2")
data=read.csv("allsim.t4.csv")
data$Terms <- cut (data$terms, breaks=c(-Inf,1.5,2.5,3.5,Inf), labels=c("1","2","3","4"))
data$Method[data$method == "model"] = "Bayesian"
data$Method[data$method == "hypergeometric"] = "Frequentist"
data$fpr <- 1 - data$specificity
ggplot(aes(x = fpr, y = recall, shape = Method, color = Terms, group = interaction(Method,Terms)), data = data) + geom_point() + xlab("1 - Specificity") + ylab("Recall") + theme(legend.position = c(.88,.25))
ggsave("allsim.color.pdf")
