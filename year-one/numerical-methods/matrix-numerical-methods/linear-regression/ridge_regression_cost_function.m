function [Error] = ridge_regression_cost_function(Theta, Y, FeMatrix, lambda)
    [m, ~] = size(FeMatrix);
  
    % Compute the hypothesis vector h(x)
    predictions = FeMatrix * Theta(2:end);
  
    % Compute squared errors
    squaredErrors = (predictions - Y) .^ 2;
  
    % Compute the base cost (mean squared error)
    Error = sum(squaredErrors) / (2 * m);
  
    % Add L2 regularisation term excluding Theta_0
    Error = Error + lambda * sum(Theta(2:end) .^ 2);
end
  