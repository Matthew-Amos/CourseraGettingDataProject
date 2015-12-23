library(reshape)

# DATA PREPARATION STEPS
# DOWNLOAD & UNZIP DATA
# SKIP BELOW FOR COURSERA QUESTIONS
# ---------------------------------
origDir <- getwd()
if(!file.exists("data")) dir.create("data/tempraw", recursive = TRUE)
setwd("./data")

# Download file
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, "./rawData.zip", method = "curl")

# Unzip
unzip("./rawData.zip", exdir = "./extractedRaw")
setwd("./extractedRaw")

features <- read.table(paste(list.dirs()[2], "features.txt", sep = "/"))
activity_labels <- read.table(paste(list.dirs()[2], "activity_labels.txt", sep = "/"))
train <- cbind(
  read.table(paste(list.dirs()[2], "/train/subject_train.txt", sep = "/")),
  read.table(paste(list.dirs()[2], "/train/y_train.txt", sep = "/")),
  read.table(paste(list.dirs()[2], "/train/X_train.txt", sep = "/"))
)
test <- cbind(
  read.table(paste(list.dirs()[2], "/test/subject_test.txt", sep = "/")),
  read.table(paste(list.dirs()[2], "/test/y_test.txt", sep = "/")),
  read.table(paste(list.dirs()[2], "/test/X_test.txt", sep = "/"))
)

setwd("..")
# ---------------------------------

# COURSERA QUESTIONS
# PART 1: Bind test and train set
out <- rbind(train, test)

# PART 4: Descriptive variable names
colnames(out) <- c("subject", "activity", as.character(features[,2]))

# PART 2: Extract only mean and standard deviation
## meanFreq excluded
out <- out[, which(sapply(colnames(out), function(x)
                (grepl("mean()", x) && !grepl("Freq", x)) || 
                grepl("std()", x) ||
                x == "subject" ||
                x == "activity"
              ))]

# PART 3: Descriptive activity names
out$activity <- sapply(out$activity, function(x) 
  activity_labels[activity_labels[,1] == x,2])
out$subject <- as.factor(out$subject)
out$activity <- as.factor(out$activity)

# PART 5: Create summary data set
out.summary <- aggregate(out[,3:ncol(out)], 
                list(subject = out$subject, activity = out$activity), 
                mean)

# ---------------------------------
setwd(origDir)
# uncomment below code to remove extracted ZIP data
# unlink("./data/extractedRaw", recursive = TRUE)

# Save files
write.table(out, "./fullDataSet.txt", row.names = FALSE)
write.table(out.summary, "./dataSummary.txt", row.names = FALSE)
