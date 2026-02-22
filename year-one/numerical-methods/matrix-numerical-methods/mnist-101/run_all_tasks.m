function run_all_tasks()
    % Neural network architecture
    input_layer_size = 400;    % Example: 20x20 pixel images
    hidden_layer_size = 25;
    output_layer_size = 10;    % Example: 10 digit classes (0–9)
    lambda = 1;                % Regularisation parameter
    training_split = 0.8;      % 80% training, 20% test

    % Load dataset
    [X, y] = load_dataset('dataset.mat');

    % Split dataset
    [X_train, y_train, X_test, y_test] = split_dataset(X, y, training_split);

    % Initialise weights
    Theta1 = initialise_weights(input_layer_size, hidden_layer_size);
    Theta2 = initialise_weights(hidden_layer_size, output_layer_size);
    initial_params = [Theta1(:); Theta2(:)];

    % Set optimisation options
    % You can increase iterations if needed
    options = struct('MaxIter', 50);

    % Train neural network
    cost_func = @(p) cost_function(p, X_train, y_train, lambda, input_layer_size, hidden_layer_size, output_layer_size);
    trained_params = fmincg(cost_func, initial_params, options);

    % Predict using the trained model
    predicted = predict_classes(X_test, trained_params, input_layer_size, hidden_layer_size, output_layer_size);

    % Compute accuracy
    accuracy = mean(double(predicted == y_test)) * 100;
    fprintf('Test Accuracy: %.2f%%\n', accuracy);
end
