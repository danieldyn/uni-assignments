function recoms = recommendations(path, liked_theme, num_recoms, min_reviews, num_features)
    % Read the matrix using helper function
    mat = read_mat(path);

    % Preprocess matrix (remove rows with too few reviews)
    mat = preprocess(mat, min_reviews);

    % Compute reduced SVD (rows of V correspond to themes)
    [~, ~, V] = svds(mat, num_features);

    % Number of themes
    [num_themes, ~] = size(V);

    % Compute cosine similarities with liked theme
    liked_vector = V(liked_theme, :)';
    similarities = zeros(num_themes, 1);
    for i = 1:num_themes
        similarities(i) = cosine_similarity(V(i, :)', liked_vector);
    end

    % Exclude the liked theme itself from recommendations
    similarities(liked_theme) = -Inf;

    % Sort themes by similarity descending and get top indices
    [~, sorted_indices] = sort(similarities, 'descend');
    recoms = sorted_indices(1:num_recoms);
end
