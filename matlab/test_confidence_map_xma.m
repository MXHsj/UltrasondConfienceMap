%% test confidence map
clc; clear; close all

bscan = imread('../images/test.bmp');
alpha = 2.0; beta = 90; gamma = 0.06;
% ===== run source code
tic
map0 = confMap(bscan, alpha, beta, gamma);
toc

% ===== run MEX file
% tic
% bscan_square = imresize(bscan, [480, 480]);
% map1 = confMap_mex(bscan_square, alpha, beta, gamma, 'B');
% toc

figure
subplot(3,1,1)
imagesc(bscan); colormap gray; axis equal tight
subplot(3,1,2)
imagesc(map0); colormap gray; axis equal tight
% subplot(3,1,3)
% imagesc(map1); colormap gray
