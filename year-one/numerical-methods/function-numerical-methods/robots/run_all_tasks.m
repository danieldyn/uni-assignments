function run_all_tasks()
    % Load data
    [x, y] = parse_data('input.txt');

    % Spline interpolation
    coef_spline = spline_c2(x, y);

    % Choose number of points for plotting
    nr_points = 200;

    % Plot spline interpolation
    figure;
    plot_spline(x, y, nr_points);
    title('Cubic Spline Interpolation');

    % Vandermonde interpolation
    coef_vander = vandermonde(x, y);

    % Plot Vandermonde interpolation
    figure;
    plot_vandermonde(x, y, nr_points);
    title('Vandermonde Polynomial Interpolation');

    % Evaluate interpolations at sample points
    x_test = linspace(min(x), max(x), 10)'; % 10 test points

    y_spline = P_spline(coef_spline, x, x_test);
    y_vander = P_vandermonde(coef_vander, x_test);

    % Display comparison table in console
    disp('Comparison of spline vs. Vandermonde at 10 test points:');
    T = table(x_test, y_spline, y_vander, 'VariableNames', {'x', 'Spline', 'Vandermonde'});
    disp(T);
end
