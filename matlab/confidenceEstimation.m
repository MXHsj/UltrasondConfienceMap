%  	Compute confidence map
%   Input:
%       A:      Processed image, weighted image according to distance to transducers
%       seeds, labels:  Seeds,labels for the random walks framework
%       beta:   Random walks parameter
%       gamma:  Horizontal penalty factor
%   Output:
%       map:    confidence map, size is [n_rows, n_cols, 2]
function [probabilities] = confidenceEstimation(A, seeds, labels, beta, gamma)
    % Index matrix with boundary padding
    G = find(ones(size(A))); %
    G = reshape(G, size(A)); % reshape into 2D lattice

    pad = 1;

    G = padarray(G, [pad pad]); % pad zeros at beginning and end of rows
    B = padarray(A, [pad pad]);

    % Laplacian
    D = confidenceLaplacian(G, B, beta, gamma);

    % Select marked columns from Laplacian to create L_M and B^T
    B = D(:, seeds); % set seeds

    % Select marked nodes to create B^T
    N = sum(G(:) > 0);
    i_U = 1:N;
    i_U(seeds) = 0;
    i_U = find(i_U); % Index of unmarked nodes
    B = B(i_U, :);

    % Remove marked nodes from Laplacian by deleting rows and cols
    D(:, seeds) = [];
    D(seeds, :) = [];

    % Adjust labels
    label_adjust = min(labels);
    labels = labels - label_adjust + 1; % labels > 0

    % Find number of labels (K)
    labels_record(labels) = 1;
    labels_present = find(labels_record);
    number_labels = length(labels_present); % number of labels
    % Define M matirx
    M = zeros(length(seeds), number_labels);

    for k = 1:number_labels
        M(:, k) = (labels(:) == labels_present(k));
    end

    % Right-handside (-B^T*M)
    rhs = sparse(-B * M);

    % Solve system
    if (number_labels == 2)
        x = D \ rhs(:, 1);
        x(:, 2) = 1.0 - x(:, 1);
    else
        x = D \ rhs;
    end

    % Prepare output
    probabilities = zeros(N, number_labels);

    for k = 1:number_labels
        % Probabilities for unmarked nodes
        probabilities(i_U, k) = x(:, k);
        % Max probability for marked node of each label
        probabilities(seeds(labels == k), k) = 1.0;
    end

    % Final reshape with same size as input image (no padding)
    probabilities = reshape(probabilities, [size(A, 1) size(A, 2) number_labels]);
end
