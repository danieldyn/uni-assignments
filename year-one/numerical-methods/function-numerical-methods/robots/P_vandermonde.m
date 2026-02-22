function y_interp = P_vandermonde(coef, x_interp)
    n = length(x_interp);     % number of evaluation points
    m = length(coef) - 1;     % degree of polynomial

    % Preallocate result vector
    y_interp = zeros(n, 1);

    % Evaluate polynomial at each interpolation point
    for i = 1:n
        xi = x_interp(i);

        % Start with constant term
        yi = coef(1);

        % Add higher-order terms
        for j = 1:m
            yi = yi + coef(j + 1) * xi^j;
        end

        y_interp(i) = yi;
    end
end
