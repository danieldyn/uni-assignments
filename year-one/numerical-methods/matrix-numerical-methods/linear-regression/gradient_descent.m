function [Theta] = gradient_descent(FeatureMatrix, Y, n, m, alpha, iter)
    % Initialise solution
    Theta = zeros(n, 1);
  
    for p = 1:iter
        % Compute hypothesis values
        predictions = FeatureMatrix * Theta;
  
        % Compute error vector
        errors = predictions - Y;
  
        % Update each parameter using the gradient
        for j = 1:n
            gradient = (errors' * FeatureMatrix(:, j)) / m;
            Theta(j) = Theta(j) - alpha * gradient;
        end
    end
  
    % Append theta_0 = 0 at the beginning of the solution vector
    Theta = [0; Theta];
end
  