function [Y, InitialMatrix] = parse_csv_file(file_path)
    % Open the input file
    inputFile = fopen(file_path, 'r');
  
    % Skip the header line
    fgetl(inputFile);
  
    % Initialise line index
    lineIndex = 1;
  
    % Read each line
    while true
        line = fgetl(inputFile);
        if ~ischar(line)
            break; % End of file
        end
        
        % Split the line into tokens
        tokens = strsplit(line, ",");
  
        % First token belongs to output vector Y
        Y(lineIndex) = str2double(tokens{1});
  
        % Remaining tokens go into InitialMatrix
        for j = 1:12
            value = str2double(tokens{j + 1});
            if isnan(value)
                % Store string if not a number
                InitialMatrix{lineIndex, j} = tokens{j + 1};
            else
                % Store numeric value
                InitialMatrix{lineIndex, j} = value;
            end
        end
  
        lineIndex = lineIndex + 1;
    end

    % Ensure Y is a column vector
    Y = Y(:);

    % Close the input file
    fclose(inputFile);
end
