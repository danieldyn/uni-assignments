function [Theta] = normal_equation(FeaturesMatrix, Y, tol, iter)
    [m, n] = size(FeaturesMatrix);
  
    % Define A and b for the linear system A * Theta = b
    A = FeaturesMatrix' * FeaturesMatrix;
    b = FeaturesMatrix' * Y;
  
    % Check if A is positive definite
    try
        chol(A); % Will error if A is not positive definite
    catch
        % A is not positive definite; return zero vector
        Theta = zeros(n + 1, 1);
        return;
    end
  
    % Initialise for Conjugate Gradient
    Theta = zeros(n, 1);
    r = b - A * Theta;  % Initial residual
    v = r;
    toleranceSquared = tol ^ 2;
    k = 1;
  
    % Conjugate Gradient loop
    while k <= iter && (r' * r > toleranceSquared)
        Av = A * v;
        alpha = (r' * r) / (v' * Av);
        Theta = Theta + alpha * v;
        r_new = r - alpha * Av;
        beta = (r_new' * r_new) / (r' * r);
        v = r_new + beta * v;
        r = r_new;
        k = k + 1;
    end
  
    % Append Theta_0 = 0 at the beginning of the solution vector
    Theta = [0; Theta];
end
  