library(reshape2)
library(dplyr)

dataset_uri <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
work_dir <- './data/UCI HAR Dataset/'

if (!file.exists('./data')) {
  dir.create('./data')
}

if (!file.exists('./data/dataset.zip')) {
  download.file(dataset_uri, destfile='./data/dataset.zip')
}

work_dir <- './data/UCI HAR Dataset/'

#unzip('./data/dataset.zip', exdir='./data')

# Read measurements to memory
train_x <- read.csv(paste0(work_dir, 'train/X_train.txt'), header=F, sep='')
train_y <- read.csv(paste0(work_dir, 'train/y_train.txt'), header=F, sep='')
test_x <- read.csv(paste0(work_dir, 'test/X_test.txt'), header=F, sep='')
test_y <- read.csv(paste0(work_dir, 'test/y_test.txt'), header=F, sep='')

# Combine training set and test set
full_x <- rbind(train_x, test_x)
full_y <- rbind(train_y, test_y)
names(full_y) <- c('activity')

# Parse features
features = read.csv(paste0(work_dir, 'features.txt'), header=F, sep=' ')
names(features) <- c('id', 'name')

# Filter only desired features
follow_features <- features[grep('std|mean', features$name),]

# Name features
names(full_x)[follow_features$id] <- follow_features$name

# Drop undesired features
full_x <- full_x[,follow_features$id]

# Read activity types
activities <- read.csv(paste0(work_dir, 'activity_labels.txt'), header=F, sep='')
names(activities) <- c('id', 'name')

# Recode activities with factor name
full_y$activity <- as.factor(full_y$activity)
levels(full_y$activity) <- activities$name

# Add activity type to dataset
full <- cbind(full_y, full_x)

# Melt columns to a factor
full_tidy <- melt(full, id.vars=c('activity'))
full_tidy <- full_tidy %>% rename('measurement'='variable')

# Calculate averages for each activity/measurement type
summary <- full_tidy %>%
  group_by(activity, measurement) %>%
  summarise(average=mean(value))