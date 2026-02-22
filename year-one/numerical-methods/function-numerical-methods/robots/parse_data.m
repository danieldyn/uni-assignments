function [x, y] = parse_data(filename)
    % Open file for reading
    fileID = fopen(filename, 'r');

    % Read number of data points (n)
    n = fscanf(fileID, "%d", 1);

    % Read x values (n+1 entries)
    x = fscanf(fileID, "%d", n + 1);

    % Read y values (n+1 entries)
    y = fscanf(fileID, "%d", n + 1);

    % Close the file
    fclose(fileID);
end
