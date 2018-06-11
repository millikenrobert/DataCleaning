## Install required libraries
install.packages("dplyr")
install.packages("reshape2")
library("dplyr")

library("reshape2")


##Load Features
features <- file.path("UCI HAR Dataset/features.txt") %>%  read.table(header = FALSE)


##Load Activity
activity_labels <- file.path("UCI HAR Dataset/activity_labels.txt") %>%  read.table(header = FALSE)


##TRAINING IMPORT
#Load training files
training_data <- file.path("UCI HAR Dataset/train/X_train.txt") %>%  read.table(header = FALSE) 
training_labels <- file.path("UCI HAR Dataset/train/y_train.txt") %>%  read.table(header = FALSE)
training_subject <- file.path("UCI HAR Dataset/train/subject_train.txt") %>%  read.table(header = FALSE)


#Clean and rename column labels in training data
col_names <- gsub("-", "_", features$V2)
col_names <- gsub("[^a-zA-Z\\d_]", "", col_names)
names(training_data) <- make.names(names = col_names, unique = TRUE, allow_ = TRUE)

#Clean and rename column labels in labels data
names(training_labels) <- "Activities"  
training_labels$Activity <- factor(training_labels$Activities, levels = activity_labels$V1, labels = activity_labels$V2)

#Clean and rename column labels in subject data
names(training_subject) <- "Volunteer"




##TEST IMPORT
#### Test data

test_data <- file.path("UCI HAR Dataset/test/X_test.txt") %>%  read.table(header = FALSE) 
test_labels <- file.path("UCI HAR Dataset/test/y_test.txt") %>%  read.table(header = FALSE)
test_subject <- file.path("UCI HAR Dataset/test/subject_test.txt") %>%  read.table(header = FALSE)

#Clean and rename column labels in training data
col_names <- gsub("-", "_", features$V2)
col_names <- gsub("[^a-zA-Z\\d_]", "", col_names)
names(test_data) <- make.names(names = col_names, unique = TRUE, allow_ = TRUE)

#Clean and rename column labels in labels data
names(test_labels) <- "Activities"  
test_labels$Activity <- factor(test_labels$Activities, levels = activity_labels$V1, labels = activity_labels$V2)

#Clean and rename column labels in subject data
names(test_subject) <- "Volunteer"




## Merges the training and the test sets to create one data set
## Extracts only the measurements on the mean and standard deviation for each measurement.
merge_data <- rbind(
  cbind(training_data, training_labels, training_subject),
  cbind(test_data, test_labels, test_subject)
) %>%
  select(
    matches("mean|std"), 
    one_of("Volunteer", "Activities")
  )

## Independent tidy data set with the average of each variable for each activity and each subject.
id_cols <- c("Volunteer", "Activities")
tidy_data <- melt(
  merge_data, 
  id = id_cols, 
  measure.vars = setdiff(colnames(merge_data), id_cols)
) %>%
  dcast(Volunteer + Activities ~ variable, mean)

## Save the result
## Export to text
write.table(tidy_data, file = "clean_data.txt", sep = ",", row.names = FALSE)

