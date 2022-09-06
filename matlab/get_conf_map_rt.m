% ======================================================
% file name: get_conf_map_rt.m
% description: generate confidence map in real-time
% author: Xihan Ma
% ======================================================

clc; clear; close all
rosshutdown

rosinit('localhost')
US_sub = rossubscriber("/Clarius/US");

bscan = imread('../images/test.bmp');
alpha = 2.0; beta = 90; gamma = 0.06;

downsample = 4;
freq = 30;
rate = rateControl(freq);

while 1
    US_msg = receive(US_sub);
    bscan = readImage(US_msg);
    bscan_dsmp = imresize(bscan, 1/downsample, 'nearest');
    map_dsmp = confMap(bscan_dsmp, alpha, beta, gamma);
    map = imresize(map_dsmp, downsample, 'nearest');
    map(bscan <= 0) = 0;         % mask out background
%     imagesc(bscan); colormap gray;
    imagesc(map); colormap gray;
    waitfor(rate);
end

