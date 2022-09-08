% ======================================================
% file name: get_conf_map_rt.m
% description: generate confidence map in real-time
% author: Xihan Ma
% ======================================================

clc; clear; close all

%
bscan = imread('../images/test.bmp');
alpha = 1.5; beta = 100; gamma = 0.08;   % confMap params (2, 90, 0.06)
scale = 4;  % downsample scale
roi.x = 150; roi.z = 130; roi.w = 340; roi.h = 240;  % ROI in confidence map

tic;
% ===== get confidence map =====
map_dsmp = confMap(imresize(bscan,1/scale,'nearest'), alpha, beta, gamma);
map = imresize(map_dsmp, scale, 'nearest');
map(bscan <= 0) = 0;         % mask out background
% ==============================

% ===== get confidence barycenter =====
map_crop = map(roi.z:roi.z+roi.h, roi.x:roi.x+roi.w);
Nc = sum(map_crop, 'all');
weights = sum(map_crop);
deviation = (0:1:size(map_crop,2)-1) - floor(size(map_crop,2)/2);
centroid = round(sum(deviation.*weights)/Nc) + floor(size(map_crop,2)/2) + roi.x;
error = size(bscan,2)/2 - centroid;
% =====================================

% ===== vis =====
% joint_display = [im2double(bscan); map];
joint_display = map;
imagesc(joint_display); colormap gray; axis off
hold on; 
line([centroid, centroid],[1, size(joint_display,1)],'Color','red','LineWidth',1); % confidence centroid
line([size(bscan,2)/2, size(bscan,2)/2],[1, size(joint_display,1)],'Color','green','LineWidth',1);
hold off
% ===============

toc;