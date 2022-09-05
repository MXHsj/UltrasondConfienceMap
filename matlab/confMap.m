%  	Compute confidence map
%   Input:
%       data:   ultrasound RF data, each colume is a scan line [m,n]
%       mode:   'RF' or 'B' mode data
%       alpha, beta, gamma: See Medical Image Analysis reference, adjust
%       parameters based on image mode
%   Output:
%       map:    Confidence map for data
function [ map ] = confMap( data, alpha, beta, gamma, mode)
% default parameters
if nargin < 4
    alpha = 2.0;
    beta = 90;
    gamma = 0.05;
end
% default image mode
if(nargin < 5)
    mode = 'B';
end
% normalization
data = double(data);
data = (data - min(data(:))) ./ ((max(data(:))-min(data(:)))+eps);
% transform to hilbert space
if(strcmp(mode, 'RF'))
    data = abs(hilbert(data));
end
% Seeds and labels (boundary conditions)
seeds = [];
labels = [];
sc = 1: size(data, 2);                  % all elements columns
sr_up = ones(1, length(sc));            % all 1
seed = sub2ind(size(data), sr_up, sc);  % convert subscripts to linear coordinates
seed = unique(seed);
seeds = [seeds seed];
% Label 1
label = zeros(1,length(seed));
label = label + 1;
labels = [labels label];                % set probe elements to 1
sr_down = ones(1,length(sc));
sr_down = sr_down * size(data,1);       % [n_rows....n_rows]
seed = sub2ind(size(data),sr_down,sc);  % all coordinates for the last row
seed = unique(seed);
seeds = [seeds seed];
%Label 2
label = zeros(1,length(seed));
label = label + 2;
labels = [labels label];                % label last row as 2
% Attenuation with Beer-Lambert
% W = attenuationWeighting(data, alpha);  % attenuation weight matrix
W = attenuationWeighting2(data);
% Apply weighting directly to image
% Same as applying it individually during the formation of the Laplacian
data = data .* W;                       % calculate weighted sum
% Find condidence values
map = confidenceEstimation( data, seeds, labels, beta, gamma);
% Only keep probabilities for virtual source notes.
map = map(:, :, 1);   % size is [n_rows, n_cols, 2]
end

