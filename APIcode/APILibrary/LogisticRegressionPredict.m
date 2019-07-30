function p = LogisticRegressionPredict(theta, X,y,lambda)
[theta, J, exit_flag]=GradientDescent(t,X,y,lambda);
 prediction = sigmoid(X*theta);
 p = floor(prediction/0.5);
end
  

 
  