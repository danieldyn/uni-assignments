function [matrix] = initialise_weights(L_prev, L_next)
    % Compute epsilon using the recommended heuristic
    epsilon = sqrt(6) / sqrt(L_prev + L_next);

    % Generate the random weight matrix with values in (-epsilon, epsilon)
    matrix = 2 * epsilon * rand(L_next, L_prev + 1) - epsilon;
end
