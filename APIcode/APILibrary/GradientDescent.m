function  [theta, J, exit_flag]=GradientDescent(t,X,y,lambda)
initial_theta = zeros(size(X, 2), 1); 
options = optimset('GradObj', 'on', 'MaxIter', 400); 
[theta, J, exit_flag] = fminunc(@(t)(costFunctionReg(t, X, y, lambda)), initial_theta, options);
end