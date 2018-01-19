setwd("/Users/bbdaniels/GitHub/stata/dev/stata2r")
install.packages("randomForest")
library(foreign)
library(randomForest)
data<-data.frame(read.dta("testout.dta"))
rf.output <- randomForest(price ~  price + mpg + trunk, data = data)
data[["predicted_price"]] <- rf.output[["predicted"]]
write.dta(data,"testin.dta")