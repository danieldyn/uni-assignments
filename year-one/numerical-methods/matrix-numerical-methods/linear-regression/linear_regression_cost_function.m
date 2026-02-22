function [Error] = linear_regression_cost_function(Theta, Y, FeatureMatrix)
    [m, ~] = size(FeatureMatrix);
  
    % Compute predicted values, ignoring Theta_0
      predictions = FeatureMatrix * Theta(2:end);
  
    % Compute squared errors
    squaredErrors = (predictions - Y) .^ 2;
  
    % Compute mean squared error cost
    Error = (1 / (2 * m)) * sum(squaredErrors);
end
  