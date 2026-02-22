function mat = read_mat(path)
    % Read the CSV file, skipping the first row and column
    mat = csvread(path, 1, 1);
end
