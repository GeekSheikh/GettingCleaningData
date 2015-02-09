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

#Loading base Train Data
subject_train <- read.table("data/UCI/train/subject_train.txt", header=FALSE)
act_labels <- read.table("data/UCI/activity_labels.txt", header=FALSE)
train_act_codes <- read.table("data/UCI/train/y_train.txt", header=FALSE)
features <- read.table("data/UCI/features.txt", header=FALSE)

subject_train <- rename(subject_train, TrainSubjectID = V1)
train <- data.table(subject_train, train_act_codes)
train <- rename(train, TrainActivityCode = V1)
features <- as.character(features[,2])
xtrain <- read.table("data/UCI/train/x_train.txt", header=FALSE, col.names=features)
train <- cbind(TrainSubjectID = train$TrainSubjectID,TrainActivityCode = train$TrainActivityCode,xtrain[,1:561])

tmp <- data.frame(cbind(TrainSubjectID = train$TrainSubjectID,TrainActivityCode = train$TrainActivityCode,train[,grepl("mean", colnames(train))]))
tmp <- data.frame(cbind(tmp[1:48], train[,grepl("std()", colnames(train))]))
train <- data.table(tmp)