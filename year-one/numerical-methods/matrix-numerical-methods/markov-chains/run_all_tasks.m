function run_all_tasks()
    % Load and parse Cohen-Sutherland matrix
    % Edit the name of the file if necessary
    Labyrinth = parse_labyrinth('markov.txt');

    % Generate adjacency and link matrices
    % DO NOT MODIFY
    adjacencyMatrix = get_adjacency_matrix(Labyrinth);
    linkMatrix = get_link_matrix(Labyrinth);

    % Compute Jacobi iteration parameters
    % DO NOT MODIFY
    [jacobiMatrix, jacobiVector] = get_Jacobi_parameters(linkMatrix);

    % Prepare iterative solver
    % Modify tolerance and step limit if necessary
    [m, ~] = size(linkMatrix);
    x0 = zeros(m - 2, 1);   % initial guess for solution
    tol = 1e-10;            % convergence tolerance
    max_steps = 200;        % iteration limit

    % Solve system using Jacobi iteration
    % DO NOT MODIFY
    [solution, error, steps] = perform_iterative(jacobiMatrix, jacobiVector, x0, tol, max_steps);
    solution = [solution; 1; 1];  % extend probability vector

    % Compute path using heuristic greedy
    % DO NOT MODIFY
    path = heuristic_greedy(2, solution, adjacencyMatrix);
    [lines, cols] = size(Labyrinth);

    % Decode path and display it in Command Window (keep semicolon removed)
    decodedPath = decode_path(path, lines, cols)
end
