function [path] = heuristic_greedy(start_position, probabilities, Adj)
    [m, ~] = size(Adj);
  
    % Initialise the path and the visited vector
    path = start_position;
    visited = zeros(m, 1);
    visited(start_position) = 1;
  
    % Start building the path
    while ~isempty(path)
        position = path(end);
  
        % Check if the WIN node is reached
        if position == m - 1
            return;
        end
  
        % Get neighbours of the current node from adjacency matrix
        neighbours = find(Adj(position, :) == 1);
  
        % Find unvisited neighbours
        unvisited_neighbours = neighbours(visited(neighbours) == 0);
  
        if isempty(unvisited_neighbours)
            % Dead end reached, backtrack one step
            path(end) = [];
        else
            % Choose the unvisited neighbour with the highest probability
            [~, idx] = max(probabilities(unvisited_neighbours));
            next = unvisited_neighbours(idx);
  
            % Mark the selected neighbour as visited and extend the path
            visited(next) = 1;
            path = [path; next];
        end
    end
end
  