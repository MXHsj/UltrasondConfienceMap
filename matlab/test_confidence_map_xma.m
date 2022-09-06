%% test confidence map
clc; clear; close all

bscan = imread('../images/test.bmp');
alpha = 2.0; beta = 90; gamma = 0.06;
tic
% map1 = confMap(bscan, alpha, beta, gamma);
map2 = attenuationWeighting2(bscan);
toc

figure
subplot(2,1,1)
imagesc(bscan); colormap gray
subplot(2,1,2)
imagesc(map2); colormap gray

