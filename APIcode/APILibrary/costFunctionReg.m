function [J, grad] = costFunctionReg(theta, X, y, lambda)
  m = length(y); 
  J = 0;
  grad = zeros(size(theta));

  h = sigmoid(X*theta);
  c1 = -y'*log(h); 
  c2 = (1-y)'*log(1-h);
  theta(1) = 0; 
  r = lambda / (2*m) * (theta'*theta);
  J = (1/m) * (c1-c2) + r;

  grad =  (1.0/m) .* X' * (h - y) + lambda / m * theta;
end