function [X, y] = load_dataset(path)
    % Load the .mat file into a structure
    data = load(path);

    % Extract features and labels from the loaded structure
    X = data.X;
    y = data.y;
end
