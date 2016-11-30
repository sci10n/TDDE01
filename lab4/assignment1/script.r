library(tree)
library(boot)
set.seed(12345)
data = read.csv("State.csv",sep = ";", header=TRUE)
data = data[order(data$MET),]

controll = tree.control(nrow(data), minsize = 8)
fit = tree( EX ~ as.numeric(MET), data, control = controll)

fit.cv = cv.tree(fit)
best_k = fit.cv$size[which.min(fit.cv$dev)]
optimal_tree = prune.tree(fit, best=best_k)

plot(optimal_tree)
text(optimal_tree)

plot(data$EX, data$MET, xlab = "expendature", ylab = "metropolitan")
plot(predict(optimal_tree), data$MET, xlab = "expendature", ylab = "metropolitan")

hist(residuals(optimal_tree))


 nonparama = function(data,index){
     sample = data[index,]
     controll = tree.control(nrow(sample), minsize = 8)
     fit = tree( EX ~ as.numeric(MET), data=sample, control = controll)
     optimal_tree = prune.tree(fit, best=best_k) 
     return(predict(optimal_tree, newdata=data))
 }
 
# 
 
 set.seed(12345)
 nonparam_boot = boot(data, statistic = nonparama, R=1000)
 confidence_bound = envelope(nonparam_boot,level=0.95)
 predictions = predict(optimal_tree,data)
 plot(data$MET, data$EX)
 points(data$MET, predictions, col="Green")
 lines(data$MET,confidence_bound$point[1,], col="Red")
 lines(data$MET,confidence_bound$point[2,], col="Red")
 
 
 parama_conf = function(data){
   controll = tree.control(nrow(data), minsize = 8)
   fit = tree( EX ~ as.numeric(MET), data=data, control = controll)
   optimal_tree = prune.tree(fit, best=best_k) 
   return(predict(optimal_tree, newdata=data))
 }
 
 parama_predic = function(data){
   controll = tree.control(nrow(data), minsize = 8)
   fit = tree( EX ~ as.numeric(MET), data=data, control = controll)
   optimal_tree = prune.tree(fit, best=best_k) 
   predictions = predict(optimal_tree, newdata=data)
   return(rnorm(nrow(data),predictions,sd(resid(fit))))
 }
 
 random_predictions = function(data, model){
  sample = data.frame(MET=data$MET, EX=data$EX)
  sample$EX = rnorm(nrow(data), predict(model,newdata=data),sd(resid(model)))
  return(sample)
}
 
  set.seed(12345)
  param_boot_conf = boot(data, statistic = parama_conf, R=1000, mle = optimal_tree, ran.gen = random_predictions, sim = "parametric")
  confidence_bound_param = envelope(param_boot_conf, level=0.95)
 # 
  set.seed(12345)
  param_boot_pred = boot(data, statistic = parama_predic, R=1000, mle = optimal_tree, ran.gen = random_predictions, sim = "parametric")
  prediction_bound_param = envelope(param_boot_pred, level=0.95)
 # 
  predictions = predict(optimal_tree,data)
 # 
  plot(data$MET, data$EX)
  points(data$MET, predictions, col="Green")
  lines(data$MET,confidence_bound_param$point[1,], col="Red")
  lines(data$MET,confidence_bound_param$point[2,], col="Red")
 # 
  lines(data$MET,prediction_bound_param$point[1,], col="Blue")
  lines(data$MET,prediction_bound_param$point[2,], col="Blue")
 