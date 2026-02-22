function [FeatureMatrix] = prepare_for_regression(InitialMatrix)
    [m, n] = size(InitialMatrix);
    FeatureMatrix = [];
  
    for i = 1:m
        % Start building the i-th row from scratch
        currentRow = [];
  
        for j = 1:n
            data = InitialMatrix{i, j};
  
            if isnumeric(data)
                % Append numeric data directly
                currentRow = [currentRow, data];
  
            elseif strcmp(data, "yes")
                currentRow = [currentRow, 1];
  
            elseif strcmp(data, "no")
                currentRow = [currentRow, 0];
  
            elseif strcmp(data, "semi-furnished")
                currentRow = [currentRow, 1, 0];
  
            elseif strcmp(data, "unfurnished")
                currentRow = [currentRow, 0, 1];
  
            elseif strcmp(data, "furnished")
                currentRow = [currentRow, 0, 0];
            end
        end
  
        % Append the completed row to the feature matrix
        FeatureMatrix = [FeatureMatrix; currentRow];
    end
end
  