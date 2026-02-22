function reduced_mat = preprocess(mat, min_reviews)
    [m, n] = size(mat);       % Get the size of the matrix
    reduced_mat = [];          % Initialize the reduced matrix

    for i = 1:m
        % Count the number of non-zero elements in the current row
        reviews = nnz(mat(i, :));

        % Include the row if it meets the minimum review threshold
        if reviews >= min_reviews
            reduced_mat = [reduced_mat; mat(i, :)];
        end
    end
end
