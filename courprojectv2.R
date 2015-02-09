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

checkPackages <- function(packages){
  if (length(base::setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))
  }
  library(reshape2,dplyr,plyr,data.table)
}
getData <- function(){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                desfile, "data/UCI.zip")
  unzip("data/UCI.zip", exdir="/data/UCI/")
}

packages <- c("reshape2","dplyr","plyr","data.table")

if (file.exists("data")){
  checkPackages(packages)
  getData()
}else {
  dir.create(file.path(data))
  getData()
}

#Loading base Train Data
subject_train <- read.table("data/UCI/train/subject_train.txt", header=FALSE)
act_labels <- read.table("data/UCI/activity_labels.txt", header=FALSE)
train_act_codes <- read.table("data/UCI/train/y_train.txt", header=FALSE)
features <- read.table("data/UCI/features.txt", header=FALSE)

subject_train <- dplyr::rename(subject_train, SubjectID = V1)
train <- data.table(subject_train, train_act_codes)
train <- dplyr::rename(train, ActivityCode = V1)
features <- as.character(features[,2])
xtrain <- read.table("data/UCI/train/x_train.txt", header=FALSE, col.names=features)
train <- cbind(SubjectID = train$SubjectID,ActivityCode = train$ActivityCode,xtrain[,1:561])

tmp <- data.frame(cbind(SubjectID = train$SubjectID,ActivityCode = train$ActivityCode,train[,grepl("mean", colnames(train))]))
tmp <- data.frame(cbind(tmp[1:48], train[,grepl("std()", colnames(train))]))
train <- data.table(tmp)
rm(tmp)

#Loading Base Test Data
subject_test <- read.table("data/UCI/test/subject_test.txt", header=FALSE)
test_act_codes <- read.table("data/UCI/test/y_test.txt", header=FALSE)
subject_test <- dplyr::rename(subject_test, TestSubjectID = V1)
test <- data.table(subject_test, test_act_codes)
test <- dplyr::rename(test, ActivityCode = V1)
xtest <- read.table("data/UCI/test/x_test.txt", header=FALSE, col.names=features)
test <- cbind(SubjectID = test$SubjectID,ActivityCode = test$ActivityCode,xtest[,1:561])

tmp <- data.frame(cbind(SubjectID = test$SubjectID,ActivityCode = test$ActivityCode,test[,grepl("mean", colnames(test))]))
tmp <- data.frame(cbind(tmp[1:48], test[,grepl("std()", colnames(test))]))
test <- data.table(tmp)
rm(tmp)

#Combine The Data & Add the Activity Descriptions
act_labels <- dplyr::rename(act_labels, ActivityCode = V1)
rawData <- rbind(train,test)
rawData <- merge(rawData, act_labels, by="ActivityCode")
rawData <- dplyr::rename(rawData, Activity = V2)
setcolorder(rawData, c(1:2,82,3:81))

#Tidy, Group & Sort The Data
measures <- names(select(rawData,c(4:82)))
mData <- melt(rawData,id=c("SubjectID","Activity"),measure.vars=measures)
summaryData <- dcast(mData, SubjectID + Activity ~ variable, mean)
