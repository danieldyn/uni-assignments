function [X_norm, mu, sigma] = normalise_features(X)
    mu = mean(X);
    sigma = std(X);
    sigma(sigma == 0) = 1; % Avoid division by zero
    X_norm = (X - mu) ./ sigma;
end