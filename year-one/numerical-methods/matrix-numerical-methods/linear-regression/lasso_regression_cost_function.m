function [Error] = lasso_regression_cost_function(Theta, Y, FeMatrix, lambda)
    [m, ~] = size(FeMatrix);
  
    % Compute hypothesis values (ignoring Theta_0)
    predictions = FeMatrix * Theta(2:end);
  
    % Compute squared error term
    squaredErrors = (Y - predictions) .^ 2;
  
    % Compute cost: mean squared error + L1 regularisation term
    Error = (1 / m) * sum(squaredErrors) + lambda * norm(Theta(2:end), 1);
end
  