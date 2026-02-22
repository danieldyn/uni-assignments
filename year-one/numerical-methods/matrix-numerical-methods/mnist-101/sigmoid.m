% A vectorised function for the sigmoid calculation.
function [y] = sigmoid(x)
    y = 1 ./ (1 + exp(-x));
end
