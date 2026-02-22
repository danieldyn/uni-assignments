function [Labyrinth] = parse_labyrinth(file_path)
    % Open the input file for reading
    input_file = fopen(file_path, 'r');
  
    % Read the matrix dimensions from the first line
    dims = fscanf(input_file, '%d', 2);
    m = dims(1);
    n = dims(2);
  
    % Initialise the labyrinth matrix
    Labyrinth = zeros(m, n);
  
    % Read each row of the labyrinth matrix from the file
    for i = 1:m
        Labyrinth(i, :) = fscanf(input_file, '%d', n)';
    end
  
    % Close the input file
    fclose(input_file);
end
  