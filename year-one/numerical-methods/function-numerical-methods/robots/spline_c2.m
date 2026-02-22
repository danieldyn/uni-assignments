function coef = spline_c2(x, y)
    % Number of intervals
    n = length(x) - 1;

    % Sparse system matrix (most entries are zero)
    A = sparse(4 * n, 4 * n);
    b = zeros(4 * n, 1);

    % Condition 1: s_i(x_i) = y_i, for i = 0 : n-1
    for i = 1:n
        A(i, 4 * (i - 1) + 1) = 1;   % a_i
        b(i) = y(i);
    end

    % Condition 2: s_{n-1}(x_n) = y_n
    h = x(n + 1) - x(n);
    A(2 * n, 4 * (n - 1) + 1) = 1;
    A(2 * n, 4 * (n - 1) + 2) = h;
    A(2 * n, 4 * (n - 1) + 3) = h^2;
    A(2 * n, 4 * n) = h^3;
    b(2 * n) = y(n + 1);

    % Condition 3: continuity of function values at internal points
    %   s_i(x_{i+1}) = s_{i+1}(x_{i+1}), for i = 0 : n-2
    for i = 1:n-1
        h = x(i + 1) - x(i);
        A(n + i, 4 * (i - 1) + 1) = 1;       % a_i
        A(n + i, 4 * (i - 1) + 2) = h;       % b_i
        A(n + i, 4 * (i - 1) + 3) = h^2;     % c_i
        A(n + i, 4 * i) = h^3;     % d_i
        b(n + i) = y(i + 1);
    end

    % Condition 4: continuity of first derivatives
    %   s_i'(x_{i+1}) = s_{i+1}'(x_{i+1}), for i = 0 : n-2
    for i = 1:n-1
        h = x(i + 1) - x(i);
        A(2 * n + i, 4 * (i - 1) + 2) = 1;        % b_i
        A(2 * n + i, 4 * (i - 1) + 3) = 2 * h;    % c_i
        A(2 * n + i, 4 * i) = 3 * h^2;  % d_i
        A(2 * n + i, 4 * i + 2) = -1;       % -b_{i+1}
    end

    % Condition 5: continuity of second derivatives
    %   s_i''(x_{i+1}) = s_{i+1}''(x_{i+1}), for i = 0 : n-2
    for i = 1:n-1
        h = x(i + 1) - x(i);
        A(3 * n + i - 1, 4 * (i - 1) + 3) = 2;       % c_i
        A(3 * n + i - 1, 4 * i) = 6 * h;   % d_i
        A(3 * n + i - 1, 4 * i + 3) = -2;      % -c_{i+1}
    end

    % Condition 6: natural spline boundary conditions
    %   s_0''(x_0) = 0
    A(4 * n - 1, 3) = 2;

    %   s_{n-1}''(x_n) = 0
    h = x(n + 1) - x(n);
    A(4 * n, 4 * (n - 1) + 3) = 2;
    A(4 * n, 4 * n) = 6 * h;

    % Solve the linear system
    coef = linsolve(A, b);
end

