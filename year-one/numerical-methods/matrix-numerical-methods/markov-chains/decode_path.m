function [decoded_path] = decode_path(path, lines, cols)  
    % Initialise decoded path, ignoring the final WIN state
    decoded_path = zeros(length(path) - 1, 2);
  
    for p = 1:length(path) - 1
        position = path(p);
  
        % Compute column index (handle zero modulo case)
        column = mod(position, cols);
        if column == 0
            column = cols;
        end
  
        % Compute row index from linear index
        row = position / cols;
        if row > floor(row)
            row = floor(row) + 1;
        end
  
        % Store coordinate pair
        decoded_path(p, :) = [row, column];
    end
end
  