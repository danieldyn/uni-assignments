function similarity = cosine_similarity(A, B)
    % Normalise the vectors
    A = A / norm(A);
    B = B / norm(B);

    % Compute similarity using the dot product
    similarity = A' * B;
end
