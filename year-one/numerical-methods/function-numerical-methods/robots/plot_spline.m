function plot_vandermonde(x, y, nr_points)
    % Compute spline coefficients
    coef = spline_c2(x, y);

    % Generate evenly spaced points for plotting
    xlin = linspace(min(x), max(x), nr_points)';
    ylin = P_spline(coef, x, xlin);

    % Plot spline curve and original data points
    plot(xlin, ylin, '-', 'Color', 'red'); % spline curve
    hold on;
    plot(x, y, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'red', 'Color', 'red'); % data points
    hold off;

    % Add labels and formatting
    xlabel('x');
    ylabel('y');
    title('Robot Trajectory - Spline Interpolation');
    set(gcf, 'Color', [0.8 0.8 0.8]); % light gray background
    grid on;
    grid minor;
end
