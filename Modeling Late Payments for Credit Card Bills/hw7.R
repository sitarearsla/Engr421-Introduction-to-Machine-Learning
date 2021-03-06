library(AUC)
library(onehot)
library(xgboost)

for (target in 1:3) {
  X_train <- read.csv(sprintf("hw07_target%d_training_data.csv", target), header = TRUE)
  Y_train <- read.csv(sprintf("hw07_target%d_training_label.csv", target), header = TRUE)
  X_test <- read.csv(sprintf("hw07_target%d_test_data.csv", target), header = TRUE)
  
  encoder <- onehot(X_train, addNA = TRUE, max_levels = Inf)
  X_train_d <- predict(encoder, data = X_train)
  X_test_d <- predict(encoder, data = X_test)
  
  y <- Y_train[,"TARGET"]
  
  xgb <- xgboost(data = X_train_d[, -1], 
                 label = y, 
                 eta = 0.01, 
                 max_depth = 3,
                 nrounds = 20, 
                 max_delta_step=10,
                 subsample = 0.5,
                 colsample_bytree = 0.4,
                 gamma = 5,
                 objective = "binary:logistic")
  
  training_scores <- predict(xgb, X_train_d[, -1])
  # AUC score for training data
  print(auc(roc(predictions = training_scores, labels = as.factor(Y_train[, "TARGET"]))))
  test_scores <- predict(xgb, X_test_d[, -1])
  write.table(cbind(ID = X_test[,"ID"], TARGET = test_scores), file = sprintf("hw07_target%d_test_predictions.csv", target), row.names = FALSE, sep = ",") 
}
