function [J, grad] = cost_function(params, X, y, lambda, input_layer_size, hidden_layer_size, output_layer_size)
    % Recover Theta1 and Theta2 from the unrolled params vector
    end_theta1 = hidden_layer_size * (input_layer_size + 1);
    Theta1 = reshape(params(1:end_theta1), hidden_layer_size, input_layer_size + 1);
    Theta2 = reshape(params(end_theta1+1:end), output_layer_size, hidden_layer_size + 1);

    % Convert y into a binary matrix representation (one-hot encoding)
    I = eye(output_layer_size);
    Y = I(y, :);

    m = size(X, 1);  % number of training examples

    % Forward propagation
    X = [ones(m, 1), X];  % Add bias to input layer
    z2 = X * Theta1';     % Input to hidden layer
    a2 = sigmoid(z2);     
    a2 = [ones(m, 1), a2];  % Add bias to hidden layer
    z3 = a2 * Theta2';     % Input to output layer
    a3 = sigmoid(z3);      % Output layer activations (predictions)

    % Cost function (with regularisation)
    J = sum(sum(-Y .* log(a3) - (1 - Y) .* log(1 - a3))) / m;
    reg = (lambda / (2 * m)) * (sum(sum(Theta1(:, 2:end) .^ 2)) + sum(sum(Theta2(:, 2:end) .^ 2)));
    J = J + reg;

    % Backpropagation
    delta3 = a3 - Y;  % Output error
    grad_sigmoid = sigmoid(z2) .* (1 - sigmoid(z2));
    delta2 = (delta3 * Theta2(:, 2:end)) .* grad_sigmoid;

    % Compute gradients
    Delta1 = (delta2' * X) / m;
    Delta2 = (delta3' * a2) / m;

    % Regularise gradients (excluding bias terms)
    Delta1(:, 2:end) = Delta1(:, 2:end) + (lambda / m) * Theta1(:, 2:end);
    Delta2(:, 2:end) = Delta2(:, 2:end) + (lambda / m) * Theta2(:, 2:end);

    % Unroll gradients into a single vector
    grad = [Delta1(:); Delta2(:)];
end
