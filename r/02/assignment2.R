#setting up the directory
setwd("D:/MONASH/FIT3152/A2")

rm(list = ls()) 
WAUS <- read.csv("WarmerTomorrow2022.csv") 
L <- as.data.frame(c(1:49)) 
set.seed(31954081) # Your Student ID is the random seed 
L <- L[sample(nrow(L), 10, replace = FALSE),] # sample 10 locations 
WAUS <- WAUS[(WAUS$Location %in% L),] 
WAUS <- WAUS[sample(nrow(WAUS), 2000, replace = FALSE),] # sample 2000 rows


#1
#need to set date to the x axis eh sort by dates, month and year
WAUS$Date<-as.Date(with(WAUS,paste(Year,Month,Day,sep="-")),"%Y-%m-%d")
WAUS[order(as.Date(WAUS$Date, format="%Y-%m-%d")),]

library(dplyr)
library(rpart)
library(tree) # for Decision Tree
library(randomForest) # for Random Forest
library(e1071) # for Naive Bayes
library(adabag) # for Bagging and Boosting
library(neuralnet) # for ANN
library(ROCR) # for AUC and ROC
library(rpart)
library(rpart.plot)
library(corrplot)
library("factoextra")
library("FactoMineR")


#take the 0 so we know today is warmer than tmr
#1 is today(previous day) is colder than tmr(today)
#count total of one divided by all rows total then times 100
today_warmer <- WAUS %>%S
                filter(WarmerTomorrow==1)

today_warmer_percentage <- (count(today_warmer) / count(WAUS)*100)
today_warmer_percentage

warmerOrNot <- c(as.numeric(today_warmer_percentage), 100 - as.numeric(today_warmer_percentage))
labels <- c("Warmer", "Not Warmer")
pie(warmerOrNot,labels)

#summary
#https://www.statmethods.net/stats/descriptives.html#:~:text=R%20provides%20a%20wide%20range%20of%20functions%20for,provide%20a%20range%20of%20descriptive%20statistics%20at%20once.
summary(WAUS)

#install.packages('pastecs')
#require(pastecs)
#stat.desc(WAUS)

#omit location and date etc. from the predictions as it is probably not affecting but we still need for labels and info purpose

functions <- c(sd,var,range)
for(var in functions) {
  print(var)
  print(sapply(WAUS, var, na.rm=TRUE))
}

#notice there are many NA's in the data
#the NA's causing problem with the data so there are some calculations error

#2
#drop the NA's
WAUS <- WAUS[rowSums(is.na(WAUS)) == 0,]
for(var in functions) {
  print(var)
  print(sapply(WAUS, var, na.rm=TRUE))
}

WAUS <- WAUS %>% select(-Day,-Month,-Year,-Date) 
WAUS$WindDir3pm = as.factor(WAUS$WindDir3pm)
WAUS$WindDir9am = as.factor(WAUS$WindDir9am)
WAUS$WindGustDir = as.factor(WAUS$WindGustDir)
WAUS$WarmerTomorrow = as.factor(WAUS$WarmerTomorrow)

#3
set.seed(31954081) #Student ID as random seed 
train.row = sample(1:nrow(WAUS), 0.7*nrow(WAUS))  
WAUS.train = WAUS[train.row,] 
WAUS.test = WAUS[-train.row,]

nrow(WAUS.train)
nrow(WAUS.test)


#4 and ROC
#https://d3cgwrxphz0fqu.cloudfront.net/38/e2/38e2bc6f81d1dd5659be73c3fb5b3a87888fb811?response-content-disposition=inline%3Bfilename%3D%22FIT3152%20Tutorial%2009%20%2B%20Solutions.pdf%22&response-content-type=application%2Fpdf&Expires=1652663160&Signature=VCnF0iMA2B2hAeiNuf8NMNKcvtMqICBa~~tWygIOT3l30vlaIOTDZ0Zttp1aoXqpNdpsS6431Hk14K2RU0E-JpldKpsVEKzaEDyEsWVCeKnQg7sI3JKB0NshrztqavrwpQZe1k33Ol~egKwM-nUQ6Js55LBrbz4h6AIm1y7awIGLmZGEtlD0h3t0YsMQ5RRRnez-xCwc6EL6bov4ZdhT4u8H19Y3zSXDDFAzQ1qEMlfAi1nr4U9t50UFoQx0bAW66rFIlyI-XLcMtzu1vOFSSrIshDByH56TRSia09OsEqUEb-ujeluTIlsc58UD9Ra893nWUzfR2TIWaOxSQOwyUg__&Key-Pair-Id=APKAJRIEZFHR4FGFTJHA
#decision tree ###############################################
WAUS.tree =  tree(WarmerTomorrow ~., data = WAUS.train)
summary(WAUS.tree)
plot(WAUS.tree)
text(WAUS.tree, pretty = 0)
WAUS.predtree = predict(WAUS.tree, WAUS.test, type = "class")

# do predictions as probabilities and draw ROC
WAUS.pred.tree = predict(WAUS.tree, WAUS.test, type = "vector")

# computing a simple ROC curve (x-axis: fpr, y-axis: tpr)
# labels are actual values, predictors are probability of class
WAUSDpred <- prediction( WAUS.pred.tree[,2], WAUS.test$WarmerTomorrow)
WAUSDperf <- performance(WAUSDpred,"tpr","fpr")
plot(WAUSDperf)
abline(0,1) 

#naive bayes ##################################################
WAUS.bayes = naiveBayes(WarmerTomorrow ~. , data = WAUS.train)

# outputs as confidence levels
WAUS.predbayes = predict(WAUS.bayes, WAUS.test)
WAUSpred.bayes = predict(WAUS.bayes, WAUS.test, type = 'raw')
WAUSBpred <- prediction( WAUSpred.bayes[,2], WAUS.test$WarmerTomorrow)
WAUSBperf <- performance(WAUSBpred,"tpr","fpr")
plot(WAUSBperf, add=TRUE, col = "blueviolet") 

summary(WAUS.predbayes)


#Bagging #######################################################
WAUS.bag <- bagging(WarmerTomorrow ~. , data = WAUS.train, mfinal=5)
WAUSpred.bag <- predict.bagging(WAUS.bag, WAUS.test)

WAUSBagpred <- prediction( WAUSpred.bag$prob[,2], WAUS.test$WarmerTomorrow)
WAUSBagperf <- performance(WAUSBagpred,"tpr","fpr")
plot(WAUSBagperf, add=TRUE, col = "blue")

#Boosting ########################################################
WAUS.Boost <- boosting(WarmerTomorrow ~. , data = WAUS.train, mfinal=10)
WAUSpred.boost <- predict.boosting(WAUS.Boost, newdata=WAUS.test)
WAUSBoostpred <- prediction( WAUSpred.boost$prob[,2], WAUS.test$WarmerTomorrow)
WAUSBoostperf <- performance(WAUSBoostpred,"tpr","fpr")
plot(WAUSBoostperf, add=TRUE, col = "red")

# Random Forest#####################################################
WAUS.test <- na.omit(WAUS.test)
WAUS.train <- na.omit(WAUS.train)
WAUS.rf <- randomForest(WarmerTomorrow ~. , data = WAUS.train, na.action = na.exclude)
WAUSpred.rf <- predict(WAUS.rf, WAUS.test, type="prob")
WAUSpredrf <- predict(WAUS.rf, WAUS.test)
WAUSFpred <- prediction( WAUSpred.rf[,2], WAUS.test$WarmerTomorrow)
WAUSFperf <- performance(WAUSFpred,"tpr","fpr")
plot(WAUSFperf, add=TRUE, col = "darkgreen") 


#5
#Decision Tree #########################
# do predictions as classes on tree and draw a table
t1=table(Predicted_Class = WAUS.predtree, Actual_Class = WAUS.test$WarmerTomorrow)
cat("\n#Decision Tree Confusion\n")
print(t1)

#naive bayes ############################
t2=table(Predicted_Class = WAUS.predbayes, Actual_Class = WAUS.test$WarmerTomorrow)
cat("\n#NaiveBayes Confusion\n")
print(t2)

#Random Forest ############################
t3=table(Predicted_Class = WAUSpredrf, Actual_Class = WAUS.test$WarmerTomorrow)
cat("\n#Random Forest Confusion\n")
print(t3)

#Boosting ################################
cat("\n#Boosting Confusion\n")
print(WAUSpred.boost$confusion) 

#Bagging ###################################
cat("\n#Bagging Confusion\n")
print(WAUSpred.bag$confusion) 


#check all accuracy
accuracyDtree = round(sum(diag(t1))/sum(t1),4)
accuracyNB = round(sum(diag(t2))/sum(t2),4)
accuracyBag = round((1 - WAUSpred.bag$error), 4)
accuracyBoost = round((1 - WAUSpred.boost$error), 4)
accuracyRF = round(sum(diag(t3))/sum(t3), 4)

accuracyDtree
accuracyNB
accuracyBag
accuracyBoost



#6


# Plot ROC curve and calculate AUC for each classifier 
num_models = 5 # number of models used
model_names = c("Decision Tree", "Naive Bayes", "Bagging", "Boosting", "Random Forest")
cust_colors = c("red", "blue", "dark green","purple", "dark orange") # list of colors
preds = cbind(WAUS.pred.tree[,2], WAUSpred.bayes[,2], WAUSpred.bag$prob[,2], WAUSpred.boost$prob[,2], WAUSpred.rf[,2]) # list of prediction prob in different models 
auc = c()
for (i in 1:num_models) {
  pred = prediction(preds[,i], WAUS.test$WarmerTomorrow)
  plot(performance(pred, "tpr", "fpr"), 
       add=(i!=1), col=cust_colors[i], main="ROC Curve For Each Classifier") # ROC
  cauc = performance(pred, "auc") # AUC
  cauc2 = round(as.numeric(cauc@y.values), 4) # Round up to 4 decimal places
  auc = append(auc, cauc2)
  print(paste0(cauc@y.name," (AUC) for ", model_names[i], ": ", cauc2))
}
legend("bottomright", legend=c("Decision Tree", "Naive Bayes", "Bagging", "Boosting", "Random Forest"),col=c("red", "blue", "dark green","purple", "dark orange"), lty=1, cex=0.8)



#if add manually one by one
DTauc = performance(WAUSDpred, "auc")
AUC_DT = round(as.numeric(DTauc@y.values),4)
AUC_DT

NBauc = performance(WAUSBpred, "auc")
AUC_NB = round(as.numeric(NBauc@y.values),4)
AUC_NB

BAGauc = performance(WAUSBagpred, "auc")
AUC_BAG = round(as.numeric(BAGauc@y.values),4)
AUC_BAG

BOOSTauc = performance(WAUSBoostpred, "auc")
AUC_BOOST = round(as.numeric(BOOSTauc@y.values),4)
AUC_BOOST

RFauc = performance(WAUSFpred, "auc")
AUC_RF = round(as.numeric(RFauc@y.values),4)
AUC_RF


legend("bottomright", legend=c("decision tree", "Naive Bayes", "Bagging", "Boosting", "Random forest"),col=c("black", "blueviolet","blue", "red", "darkgreen"), lty=1, cex=0.8)


#7
accuracy = c(accuracyDtree, accuracyNB, accuracyBag, accuracyBoost, accuracyRF)
AUC = c(AUC_DT, AUC_NB, AUC_BAG, AUC_BOOST, AUC_RF)
compare = cbind(accuracy,AUC)
rownames(compare) <- c("Decision tree", "Naive Bayes", "Bagging", "Boostiong", "Random forest")
compare

#8
#Attribute importance ####
cat("\n#Decision Tree Attribute Importance\n")
print(summary(WAUS.tree))
cat("\n#Baging Attribute Importance\n")
print(sort(WAUS.bag$importance,decreasing = T))
cat("\n#Boosting Attribute Importance\n")
print(sort(WAUS.Boost$importance,decreasing = T))
cat("\n#Random Forest Attribute Importance\n")
print(WAUS.rf$importance[order(-WAUS.rf$importance),])
# Cannot determine the importance of variables used in Naive Bayes as it only calculates the probabilities of each variable given


#9
#By hand : decision tree because it categorized all the needed and can be deducted by human eyes
# Visualize the decision tree (see how we can prune)
plot(print(WAUS.tree))
text(WAUS.tree, pretty=0)

fit <- rpart(WarmerTomorrow ~., data = WAUS.train, method = 'class')
rpart.plot(fit, extra = 106)

# Use K-fold cv function to generate attributes for observation use
test_dt.fit = cv.tree(WAUS.tree, FUN = prune.tree)
test_dt.fit

# Choose the smallest $dev and $k for pruning process
pruned_dt.fit = prune.misclass(WAUS.tree, best = 3)
summary(pruned_dt.fit) 

# < Observation >
# You would get k = 0 and it simply means model performance won't get changed 
# although the tree is simplified into one with 2 leaf nodes in the end.

# View the pruned decision tree
plot(pruned_dt.fit) 
text(pruned_dt.fit, pretty=0)

# Calculate accuracy
pruned_dt.predict = predict(pruned_dt.fit, WAUS.test, type="class") 
pruned_dt.cm = table(actual=WAUS.test$WarmerTomorrow, predicted=pruned_dt.predict) # confusion matrix
pruned_dt.cm 
pruned_dt.acc = round(sum(diag(pruned_dt.cm))/sum(pruned_dt.cm), 4)
print(paste0("Accuracy for Decision Tree after pruning: ", pruned_dt.acc))

set.seed(31954081)
new_rf.fit = randomForest(WarmerTomorrow ~ ., data=WAUS.train, mtry = 7)
#use cv to generate attributes
#https://stackoverflow.com/questions/31637259/random-forest-crossvalidation-in-r
#rf.crossValidation(WAUS.rf, WAUS.test, n=99, plot=TRUE, seed = 31954081 )
# Run cross validation for random forest
rain_rfcv = rfcv(trainx=WAUS.train[,c(1:20)], trainy=WAUS.train[,c(21)], step=0.8)
rain_rfcv$error.cv

print(new_rf.fit$importance[order(-WAUS.rf$importance),])

# Calculate accuracy
new_rf.predict = predict(new_rf.fit, WAUS.test)
new_rf.cm = table(actual=WAUS.test$WarmerTomorrow, predicted=new_rf.predict) # confusion matrix
new_rf.cm 
new_rf.acc = round(sum(diag(new_rf.cm))/sum(new_rf.cm), 4)
print(paste0("Accuracy for Random Forest after CV: ", new_rf.acc))

# < Observation >
# When doing sampling, the number of variables don't really give significant differences.

# Generate summary table for comparison purpose
new_acc = c(pruned_dt.acc, new_rf.acc)
new_summary_table = rbind(Initial_Accuracy=c(accuracyDtree,accuracyRF), Improved_Accuracy=new_acc)
colnames(new_summary_table) = model_names[c(1,5)]
new_summary_table

#11
# Make indicator
new_WAUS = WAUS # make a copy of current dataset to avoid modification on it
new_WAUS$TmrNotWarmer = new_WAUS$WarmerTomorrow == 0
new_WAUS$TmrWarmer = new_WAUS$WarmerTomorrow == 1
#location_categorical_vars = model.matrix(~ Location + 0, data=new_WAUS) # "+0" is to solve the problem that one of the variables is being ignored

# Exclude some unimportant variables. change this
#new_WAUS = new_WAUS[,-c(0:6,8,11:19)] 

# Normalise data (0 - 1)
normalise_ = function(col){
  return((col - min(col))/(max(col) - min(col)))
}

# Apply normalise function to all predictors that are not categorical
predictors = apply(new_WAUS[,c(1:6,8,11:19)], 2, normalise_) 
new_WAUS = cbind(predictors, new_WAUS[,c(7,9:10,20:23)])

# Check the attribute of each variable
summary(new_WAUS)

# Split data into train and test
set.seed(31954081) #Student ID as random seed 
train.row = sample(0:nrow(new_WAUS), 0.7*nrow(new_WAUS)) # Split into 70% and 30%
new_WAUS.train = new_WAUS[train.row,] # Assign 70% to train data
new_WAUS.test = new_WAUS[-train.row,] # Assign 30% to test data

# 11 Build ANN
set.seed(31954081)
new_WAUS.train$Location <- as.numeric(new_WAUS.train$Location)
new_WAUS.train$TmrNotWarmer <- as.numeric(new_WAUS.train$TmrNotWarmer)
new_WAUS.train$TmrWarmer <- as.numeric(new_WAUS.train$TmrWarmer)
new_WAUS.train$WindDir3pm <- as.numeric(new_WAUS.train$WindDir3pm)
new_WAUS.train$WindDir9am <- as.numeric(new_WAUS.train$WindDir9am)
new_WAUS.train$WindGustDir <- as.numeric(new_WAUS.train$WindGustDir)

nn.fit = neuralnet(WarmerTomorrow~ . -TmrWarmer -TmrNotWarmer, new_WAUS.train, hidden = 1, linear.output=F)
#nn.fit = neuralnet(WarmerTomorrow~ MaxTemp + Sunshine + Pressure9am + Temp9am + Temp3pm, new_WAUS.train, hidden = 1, linear.output=F)

# Visualize ANN
plot(nn.fit)

# Print the weights
nn.fit$result.matrix

# Make prediction using test set
new_WAUS.test$TmrNotWarmer <- as.numeric(new_WAUS.test$TmrNotWarmer)
new_WAUS.test$TmrWarmer <- as.numeric(new_WAUS.test$TmrWarmer)
new_WAUS.test$WindDir3pm <- as.numeric(new_WAUS.test$WindDir3pm)
new_WAUS.test$WindDir9am <- as.numeric(new_WAUS.test$WindDir9am)
new_WAUS.test$WindGustDir <- as.numeric(new_WAUS.test$WindGustDir)

# Print the weights
nn.fit$result.matrix

# Make prediction using test set
nn.predict = compute(nn.fit, new_WAUS.test[,-c(21:23)]) 


# Make prediction
nn.predr = round(nn.predict$net.result, 0)
nn.predrdf = as.data.frame(as.table(nn.predr))

# Remove rows classified 0 - leave only classified 1 - check by the
nn.predrdfs = nn.predrdf[!nn.predrdf$Freq==0,]
nn.predrdfs$Freq = NULL
colnames(nn.predrdfs) = c("Obs", "WarmerTomorrow")
nn.predrdfs = nn.predrdfs[order(nn.predrdfs$Obs),]

# Create confusion matrix and calculate the accuracy
nn.cm = table(observed=new_WAUS.test$WarmerTomorrow, predicted=nn.predrdfs$WarmerTomorrow)
nn.cm
nn.acc = round(sum(diag(nn.cm))/sum(nn.cm)*100, 2)
print(paste0("Accuracy for ANN:", nn.acc, "%"))


#IMPORTANT NN
#new_WAUS.train$WarmerTomorrow <- as.numeric(new_WAUS.train$WarmerTomorrow)
#M = cor(new_WAUS.train[,-c(22:23)])
#corrplot(M, order = 'hclust', addrect = 2)
#M[21,]

#If want to try pca
#https://bioinfo4all.wordpress.com/2021/01/31/tutorial-6-how-to-do-principal-component-analysis-pca-in-r/ 
