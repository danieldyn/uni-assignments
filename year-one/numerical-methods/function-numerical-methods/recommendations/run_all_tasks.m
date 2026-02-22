function run_all_tasks()
    % Parameters
    path = 'data.csv';         % Path to the CSV file
    liked_theme = 13;          % Index of the liked theme
    num_recoms = 5;            % Number of recommendations to generate
    min_reviews = 2;           % Minimum number of reviews per theme
    num_features = 10;         % Number of SVD features to use
    
    % Generate the recommendations
    recom_indices = recommendations(path, liked_theme, num_recoms, min_reviews, num_features);

    % Display recommendations with original Theme-IDs
    fprintf('Top %d recommended themes similar to Theme-%d:\n', num_recoms, liked_theme);
    for i = 1:length(recom_indices)
        fprintf('Theme-%d\n', recom_indices(i));
    end
end
