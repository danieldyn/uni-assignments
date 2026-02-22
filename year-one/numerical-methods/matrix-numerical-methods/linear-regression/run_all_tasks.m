function run_all_tasks()    
    % Parameters - Free to modify
    alpha = 0.001;      % Learning rate for gradient descent
    iter = 1000;        % Number of iterations
    lambda = 1.0;       % Regularisation parameter
    tol = 1e-6;         % Tolerance for normal equation
    
    % Choose only one of the below input options
    % Leave the other option commented

    % Load and parse CSV file
    % Change file name if necessary
    [Y, InitialMatrix] = parse_csv_file('Example.csv');
    
    % Load and parse text file
    % Change file name if necessary
    % [Y, InitialMatrix] = parse_data_set_file('Dataset.txt');
    
    % Convert mixed data into numerical format
    FeatureMatrix = prepare_for_regression(InitialMatrix);
    [m, n] = size(FeatureMatrix);

    % Normalise Feature Matrix
    [FeatureMatrix, mu, sigma] = normalise_features(FeatureMatrix);
    
    % Gradient Descent
    Theta_gd = gradient_descent(FeatureMatrix, Y, n, m, alpha, iter);
    cost_gd = linear_regression_cost_function(Theta_gd, Y, FeatureMatrix);
    fprintf('Gradient Descent Cost: %.5g\n', cost_gd);
    
    % Normal Equation (Conjugate Gradient)
    Theta_ne = normal_equation(FeatureMatrix, Y, tol, iter);
    cost_ne = linear_regression_cost_function(Theta_ne, Y, FeatureMatrix);
    fprintf('Normal Equation Cost: %.5g\n', cost_ne);
    
    % Ridge Regression Cost Evaluation
    cost_ridge = ridge_regression_cost_function(Theta_gd, Y, FeatureMatrix, lambda);
    fprintf('Ridge Regression Cost: %.5g\n', cost_ridge);
    
    % Lasso Regression Cost Evaluation
    cost_lasso = lasso_regression_cost_function(Theta_gd, Y, FeatureMatrix, lambda);
    fprintf('Lasso Regression Cost: %.5g\n', cost_lasso);
end
