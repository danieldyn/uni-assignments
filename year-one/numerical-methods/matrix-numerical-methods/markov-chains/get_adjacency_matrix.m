function [Adj] = get_adjacency_matrix(Labyrinth)
    [m, n] = size(Labyrinth);
    num_nodes = m * n;
    WIN = num_nodes + 1;
    LOSE = num_nodes + 2;
  
    % Initialise adjacency matrix
    Adj = zeros(num_nodes + 2, num_nodes + 2);
  
    for i = 1:m
        for j = 1:n
            % Decode walls using Cohen-Sutherland encoding
            up    = bitand(Labyrinth(i, j), 8);
            down  = bitand(Labyrinth(i, j), 4);
            right = bitand(Labyrinth(i, j), 2);
            left  = bitand(Labyrinth(i, j), 1);
  
            % Compute the graph node index for the current cell
            position = (i - 1) * n + j;
  
            % Check upward movement
            if up == 0
                if i > 1
                    Adj(position, position - n) = 1;
                else
                    Adj(position, WIN) = 1;  % Transition to WIN from top row
                end
            end
  
            % Check downward movement
            if down == 0
                if i < m
                    Adj(position, position + n) = 1;
                else
                    Adj(position, WIN) = 1;  % Transition to WIN from bottom row
                end
            end
  
            % Check leftward movement
            if left == 0
                if j > 1
                    Adj(position, position - 1) = 1;
                else
                    Adj(position, LOSE) = 1;  % Transition to LOSE from left edge
                end
            end
  
            % Check rightward movement
            if right == 0
                if j < n
                    Adj(position, position + 1) = 1;
                else
                    Adj(position, LOSE) = 1;  % Transition to LOSE from right edge
                end
            end
        end
    end
  
    % Set self-loops for WIN and LOSE states
    Adj(WIN, WIN) = 1;
    Adj(LOSE, LOSE) = 1;
  
    % Convert to sparse format for efficiency
    Adj = sparse(Adj);
end
  