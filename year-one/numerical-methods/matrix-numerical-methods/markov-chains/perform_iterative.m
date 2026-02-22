function [x, err, steps] = perform_iterative(G, c, x0, tol, max_steps)
    % Get the size of the system
    [~, n] = size(G);
  
    % Initialise the solution vector
    x = zeros(n, 1);
  
    % Perform iterative method
    for p = 1:max_steps
        steps = p;
        x = G * x0 + c;
  
        % Check convergence
        if norm(x - x0) < tol
            break;
        end
  
        % Update the previous solution
        x0 = x;
    end
  
    % Compute final error
    err = norm(x - x0, 2);
end
  