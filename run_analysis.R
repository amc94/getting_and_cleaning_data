#getting the data set

if(!dir.exists("data")){dir.create("data")}
file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file_url, destfile = "data/Dataset.zip", method = "curl")

#unzip the files
unzip("data/Dataset.zip", exdir="data")

#get the needed files
data_path <- "data/UCI HAR Dataset"
files <- list.files(data_path, recursive = TRUE)
files

#remove the files from the Inertial directories
files <- files[!grepl("*/Inertial", files)]

#remove the info files
files <- files[-c(3,4)]

#read the files
activity_labels <- read.table(file.path(data_path, files[1]), header = FALSE)
features <- read.table(file.path(data_path, files[2]), header = FALSE)

#combine the data sets
subject_test <- read.table(file.path(data_path, files[3]), header = FALSE)
subject_train <- read.table(file.path(data_path, files[6]), header = FALSE)

X_test <- read.table(file.path(data_path, files[4]), header = FALSE)
X_train <- read.table(file.path(data_path, files[7]), header = FALSE)

y_train <- read.table(file.path(data_path, files[8]), header = FALSE)
y_test <- read.table(file.path(data_path, files[5]), header = FALSE)

features_data <- rbind(X_train, X_test)
activity_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

colnames(features_data) <- features$V2
colnames(subject_data) <- "subject"
colnames(activity_data) <- "activityCode"
merged_data <- cbind(features_data, subject_data, activity_data)

#extract only the measurements of the mean and std
mean_std_measurements <- features$V2[grep("mean|std", features$V2)]
desired_columns <- c(mean_std_measurements, "subject", "activityCode")
desired_data <- merged_data[,desired_columns]

#Uses descriptive activity names to name the activities in the data set
desired_data$activityCode <- activity_labels[desired_data$activityCode, 2]
colnames(desired_data)[which(names(desired_data) == "activityCode")] <- "Activity"

#Appropriately labels the data set with descriptive variable names. 
names(desired_data) <- gsub("^t","Time", names(desired_data))
names(desired_data) <- gsub("^f", "Frequency" ,names(desired_data))
names(desired_data) <- gsub("Acc", "Accelerometer" ,names(desired_data))
names(desired_data) <- gsub("gyro", "Gyroscope",names(desired_data))
names(desired_data) <- gsub("-mean\\()","Mean" ,names(desired_data))
names(desired_data) <- gsub("-std\\()", "STD" ,names(desired_data))
names(desired_data) <- gsub("mag", "Magnitutde" ,names(desired_data))
names(desired_data) <- gsub("Freq\\()", "Frequency", names(desired_data))

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(dplyr)
Mean_of_desired_data <- aggregate.data.frame(desired_data, list(Subject = desired_data$subject,
                                                                Activity = desired_data$Activity), mean)
