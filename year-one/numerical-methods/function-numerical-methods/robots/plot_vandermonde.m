function plot_vandermonde(x, y, nr_points)
    % Compute Vandermonde polynomial coefficients
    coef = vandermonde(x, y);

    % Generate evenly spaced points for plotting
    xlin = linspace(min(x), max(x), nr_points)';
    ylin = P_vandermonde(coef, xlin);

    % Plot polynomial curve
    plot(xlin, ylin, '-', 'Color', 'red'); 
    hold on;

    % Plot original data points
    plot(x, y, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'red', 'Color', 'red');
    hold off;

    % Add labels and formatting
    xlabel('x');
    ylabel('y');
    title('Robot Trajectory - Vandermonde Polynomial');
    set(gcf, 'Color', [0.8 0.8 0.8]); % light gray background
    grid on;
    grid minor;
end
