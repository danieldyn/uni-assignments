function [Y, InitialMatrix] = parse_data_set_file(file_path)
    % Open the input file
    inputFile = fopen(file_path, 'r');
  
    % Read dimensions from the first line
    firstLine = fgetl(inputFile);
    dims = sscanf(firstLine, "%d", 2);
    m = dims(1);
    n = dims(2);
  
    % Initialise output structures
    InitialMatrix = cell(m, n);
    Y = zeros(m, 1);
  
    % Read and parse each line
    for i = 1:m
        line = fgetl(inputFile);
        tokens = strsplit(strtrim(line), " ");
  
        % First token is the output value
        Y(i) = str2double(tokens{1});
 
        % Remaining tokens are feature values (numeric or string)
        for j = 1:n
            value = str2double(tokens{j + 1});
            if isnan(value)
                % Store string if not a number
                InitialMatrix{i, j} = tokens{j + 1};
            else
                % Store numeric value
                InitialMatrix{i, j} = value;
            end
        end
    end
  
    % Close the file
    fclose(inputFile);
  end
  