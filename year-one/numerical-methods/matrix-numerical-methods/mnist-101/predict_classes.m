function [classes] = predict_classes(X, weights, input_layer_size, hidden_layer_size, output_layer_size)
    % Reconstruct Theta1 and Theta2 from the weights vector
    end_theta1 = hidden_layer_size * (input_layer_size + 1);
    Theta1 = reshape(weights(1:end_theta1), hidden_layer_size, input_layer_size + 1);
    Theta2 = reshape(weights(end_theta1 + 1:end), output_layer_size, hidden_layer_size + 1);

    % Initialise output and add bias term to input
    m = size(X, 1);
    classes = zeros(m, 1);
    X = [ones(m, 1), X];

    % Forward propagation (vectorised)
    z2 = X * Theta1';
    a2 = sigmoid(z2);
    a2 = [ones(m, 1), a2];  % Add bias unit to hidden layer
    z3 = a2 * Theta2';
    a3 = sigmoid(z3);       % Final activations (output layer)

    % Determine the predicted class (index of max probability)
    for i = 1:m
        [max_prob idx] = max(a3(i, :));
        classes(i) = idx;
    end
end
