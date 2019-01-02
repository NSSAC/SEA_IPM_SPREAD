#Last modified: May 24, 2018

library(data.table)
library(mvpart)

#************* Start of Input *******************
infile <- "simulation_output.csv"
outfile <- "4.1_cart_tree.pdf"


#************* Start of Main ************************
dt <- fread(input=infile, header=TRUE)

DV <- data.matrix(dt[, list(likelihood, relative_time)])
df <- data.frame(dt)
fit=rpart(DV~start_month+moore+exp_delay+alpha_sd+alpha_fm+alpha_ld+time_window, method="mrt", data=df, control=rpart.control(minsplit=50, minbucket=20))

pdf(file=outfile, width=7, height=3)
par(mar=c(0.7, 0.7, 1, 0.05))
plot(fit, uniform=FALSE, branch=.5, margin=.09, compress=FALSE)
text(fit, splits = TRUE, which = 2, label = "yval", FUN = text, all.leaves = FALSE, pretty = NULL, tadj = 0.5, stats = TRUE, use.n = TRUE, bars = TRUE, legend = TRUE, xadj = 0.5, yadj = 1, bord = FALSE, big.pts = FALSE, cex=0.5)

dev.off()




