function [X_train, y_train, X_test, y_test] = split_dataset(X, y, percent)
    [m, ~] = size(X); % Get number of examples

    % Randomly shuffle the dataset
    permutation = randperm(m);
    X = X(permutation, :);
    y = y(permutation);

    % Determine the split index for training
    end_train = floor(percent * m);

    % Split into training and test sets
    X_train = X(1:end_train, :);
    y_train = y(1:end_train);
    X_test = X(end_train+1:end, :);
    y_test = y(end_train+1:end);
end
