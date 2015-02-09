source("http://bioconductor.org/biocLite.R")
biocLite("genefilter")
#Load Libraries
library(dplyr)
library(plyr)
library(data.table)
library(genefilter)

#Building Functions
addSummaries <- function(orig, calcappend, header1, header2) {
	h1 <- eval(substitute(header1))
	h2 <- eval(substitute(header2))
	orig[,h1] <- rowMeans(calcappend)
	orig[,h2] <- rowSds(calcappend)
	orig
}

#Loading MetaData
activity.labels <- read.csv("data/UCI/activity_labels.txt", sep=" ", header=FALSE)
y.test <- read.csv("data/UCI/test/y_test.txt", sep=" ", header=FALSE)
summaries <- merge(activity.labels, y.test)
subjects <- read.csv("data/UCI/test/subject_test.txt", sep=" ", header=FALSE)
summaries[,"subject.id"] <- subjects
rm(activity.labels,y.test,subjects)

#Loading Test Base Data
tmp <- read.table("data/UCI/test/x_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"xtest.mean","xtest.sds")
rm(tmp)

#Loading Test Interial Summaries
tmp <- read.table("data/UCI/test/Inertial Signals/body_acc_x_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"xacc.test.mean","xacc.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/body_acc_y_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"yacc.test.mean","yacc.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/body_acc_z_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"zacc.test.mean","zacc.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/body_gyro_x_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"xgyr.test.mean","xgyr.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/body_gyro_y_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"ygyr.test.mean","ygyr.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/body_gyro_z_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"zgyr.test.mean","zgyr.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/total_acc_x_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"xtotacc.test.mean","xtotacc.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/total_acc_y_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"ytotacc.test.mean","ytotacc.test.sds")
rm(tmp)
tmp <- read.table("data/UCI/test/Inertial Signals/total_acc_z_test.txt", header=FALSE)
summaries <- addSummaries(summaries,tmp,"ztotacc.test.mean","ztotacc.test.sds")
rm(tmp)


#Loading Training Base
train.summaries <- read.csv("data/UCI/train/subject_train.txt", sep=" ", header=FALSE)
train.summaries <- rename(train.summaries, subject.id = V1)
tmp <- read.table("data/UCI/train/x_train.txt", header=FALSE)
train.summaries <- addSummaries(train.summaries,tmp,"xtrain.mean","xtrain.sds")
rm(tmp)