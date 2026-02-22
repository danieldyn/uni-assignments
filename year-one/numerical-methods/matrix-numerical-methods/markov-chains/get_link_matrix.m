function [Link] = get_link_matrix(Labyrinth)  
    % Get the adjacency matrix from the Cohen-Sutherland matrix
    Adj = get_adjacency_matrix(Labyrinth);
  
    % Initialize the link matrix with zeros
    [m, ~] = size(Adj);
    Link = zeros(m, m);
  
    % For each node, assign equal transition probability to its neighbours
    for i = 1:m
        % Count the number of neighbours (non-zero entries in the row)
        neighbours = nnz(Adj(i, :));
  
        % Divide by the number of neighbours to get uniform probabilities
        if neighbours > 0
            Link(i, :) = Adj(i, :) / neighbours;
        end
    end
  
    % Convert the matrix to a sparse format for efficiency
    Link = sparse(Link);
end
  