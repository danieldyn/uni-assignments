function [G, c] = get_Jacobi_parameters(Link)
    [m, ~] = size(Link);
  
    % Extract the submatrix of transitions excluding the WIN and LOSE states
    G = Link(1:m-2, 1:m-2);
  
    % Extract the column vector representing transitions to the WIN state
    c = Link(1:m-2, m-1);
  
    % Ensure both outputs are in sparse format
    G = sparse(G);
    c = sparse(c);
end
  