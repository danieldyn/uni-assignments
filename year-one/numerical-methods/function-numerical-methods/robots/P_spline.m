function y_interp = P_spline(coef, x, x_interp)
    n = length(x_interp);   % number of evaluation points
    m = length(x);          % number of knots
    y_interp = zeros(n, 1);

    for i = 1:n
        xi = x_interp(i);

        % Find the interval [x_j, x_{j+1}) containing xi
        for j = 1:m-1
            if xi >= x(j) && xi < x(j + 1)
                % Extract coefficients for interval j
                a = coef(4 * (j - 1) + 1);
                b = coef(4 * (j - 1) + 2);
                c = coef(4 * (j - 1) + 3);
                d = coef(4 * j);

                % Local coordinate
                h = xi - x(j);

                % Evaluate cubic polynomial
                y_interp(i) = a + b*h + c*h^2 + d*h^3;
                break;
            end
        end

        % Handle the edge case: if xi == last knot (x_n)
        if xi == x(m)
            a = coef(4 * (m - 2) + 1);
            b = coef(4 * (m - 2) + 2);
            c = coef(4 * (m - 2) + 3);
            d = coef(4 * (m - 1));

            h = xi - x(m - 1);
            y_interp(i) = a + b*h + c*h^2 + d*h^3;
        end
    end
end

