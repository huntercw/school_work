#Read data 
set.seed(1234)

library(gtools)
library(dplyr)
#mydata<-read.csv("/Users/ninabrillhart/Downloads/cincinnati_traffic_crash_data__cpd.csv", header=TRUE)
mydata<-read.csv("/Users/coleh/OneDrive/Desktop/cincinnati_traffic_crash_data__cpd.csv", header=TRUE)
head(mydata)
summary(mydata)
str(mydata$CRASHSEVERITY)
str(mydata)

#make binary variables
mydata$CRASHSEVERITYID<-ifelse(mydata$CRASHSEVERITYID=="1",1,0)

#split data
index <- sample(nrow(mydata),nrow(mydata)*0.80)
train = mydata[index,]
test = mydata[-index,]

f <- as.formula("CRASHSEVERITYID ~ AGE + COMMUNITY_COUNCIL_NEIGHBORHOOD + CRASHLOCATION +
                DAYOFWEEK + GENDER + LIGHTCONDITIONSPRIMARY + MANNEROFCRASH + ROADCONDITIONSPRIMARY + 
                ROADCONTOUR + ROADSURFACE + TYPEOFPERSON + WEATHER + UNITTYPE")

#Logistic Regression
#can't use zip because too many levels
glm<- glm(f, data=train)
summary(glm)

#in sample prediction

pred_resp <- predict(glm,type="response")
#confusion matrix to calculation misclassifictation rate

#resp_train <- sum(train$CRASHSEVERITYID) / nrow(train)
table_glm_train <- table(train$CRASHSEVERITYID, (pred_resp > 0.5)*1, dnn=c("Truth","Predicted"))

glm_accuracy_train <- ((na.replace(table_glm_train[1],0)+na.replace(table_glm_train[4],0)) / sum(table_glm_train))

glm_train<- predict(glm, type="response")

#out of sample prediction
glm_test<- predict(glm, newdata = test, type="response")
table_glm_test <- table(test$CRASHSEVERITYID, (glm_test > 0.5)*1, dnn=c("Truth","Predicted"))
glm_accuracy_test <- ((na.replace(table_glm_test[1],0)+na.replace(table_glm_test[4],0)) / sum(table_glm_test))



#CART
library(rpart)

# convert categorical data to factor
#train$variable<- as.factor(train$variable)
#test$variable<- as.factor(train$variable)

#build tree
crash_rpart0 <- rpart(formula = f, data = train, method = "class")

#confusion matrix used to calculation misclassification rate
#pred0 <- predict(crash_rpart0, type="class")
#table(train$CRASHSEVERITYID, pred0, dnn = c("True", "Pred"))


#In-sample prediction
crash_train.pred.tree1<- predict(crash_rpart0, train, type="class")
tree_in_table <- table(train$CRASHSEVERITYID, crash_train.pred.tree1, dnn=c("Truth","Predicted"))
tree_accuracy_train <- ((na.replace(tree_in_table[1],0)+na.replace(tree_in_table[4],0)) / sum(tree_in_table))

#out-of-sample prediction - not sure if this is right!!
crash_test.pred.tree1<- predict(crash_rpart0, test, type="class")
tree_out_table <- table(test$CRASHSEVERITYID, crash_test.pred.tree1, dnn=c("Truth","Predicted"))
tree_accuracy_test <- ((na.replace(tree_out_table[1],0)+na.replace(tree_out_table[4],0)) / sum(tree_out_table))


#Random Forest
library(MASS)
library(randomForest)

f1 <- as.formula("as.factor(CRASHSEVERITYID) ~ AGE + COMMUNITY_COUNCIL_NEIGHBORHOOD + CRASHLOCATION +
                DAYOFWEEK + GENDER + LIGHTCONDITIONSPRIMARY + MANNEROFCRASH + ROADCONDITIONSPRIMARY + 
                ROADCONTOUR + ROADSURFACE + TYPEOFPERSON + WEATHER + UNITTYPE")
#NOTE: Error: can not handle categorical predictors with more than 53 categories.
crash_rf<- randomForest(f1, data = train, importance=TRUE, ntree=500)
crash_rf

rf_accuracy_train <- (crash_rf$confusion[1]+crash_rf$confusion[4]) / (crash_rf$confusion[1]+crash_rf$confusion[4]+
                                                                        crash_rf$confusion[2]+crash_rf$confusion[3] )

#out-of-sample prediction 
rf_test.pred<- predict(crash_rf, test, type="class")
rf_out_table <- table(test$CRASHSEVERITYID, rf_test.pred, dnn=c("Truth","Predicted"))
rf_accuracy_test <- ((na.replace(tree_out_table[1],0)+na.replace(tree_out_table[4],0)) / sum(tree_out_table))



#Boosting
library(adabag)
train$CRASHSEVERITYID= as.factor(train$CRASHSEVERITYID)
crash_boost= boosting(CRASHSEVERITYID~CRASHLOCATION + 
                        GENDER + INJURIES + LIGHTCONDITIONSPRIMARY + MANNEROFCRASH + 
                        ROADCONDITIONSPRIMARY + ROADCONTOUR + ROADSURFACE + WEATHER + SNA_NEIGHBORHOOD, data = train, boos = T)
save(crash_boost, file = "crash_boost.Rdata")

# Training AUC
pred_crash_boost= predict(crash_boost, newdata = train)
pred <- prediction(pred_crash_boost$prob[,2], train$CRASHSEVERITYID)
perf <- performance(pred, "tpr", "fpr")
plot(perf, colorize=TRUE)

#Get the AUC
unlist(slot(performance(pred, "auc"), "y.values"))

pred_crash_boost= predict(crash_boost, newdata = test)

# Testing AUC
pred <- prediction(pred_crash_boost$prob[,2], test$CRASHSEVERITYID)
perf <- performance(pred, "tpr", "fpr")
plot(perf, colorize=TRUE)

#Get the AUC
unlist(slot(performance(pred, "auc"), "y.values"))



