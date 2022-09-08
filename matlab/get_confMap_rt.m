% ======================================================
% file name: get_conf_map_rt.m
% description: generate confidence map in real-time
% author: Xihan Ma
% ======================================================

clc; clear; close all
rosshutdown

rosinit('localhost')
US_sub = rossubscriber('/Clarius/US');
confMap_err_pub = rospublisher('/ConfMap/in_plane_error', 'std_msgs/Float64');
confMap_err_msg = rosmessage(confMap_err_pub);
confMap_err_msg.Data = nan;

%%
bscan = imread('../images/test.bmp');
isRecVideo = true;
alpha = 1.5; beta = 100; gamma = 0.08;   % confMap params (2, 90, 0.06)
scale = 4;  % downsample scale
roi.x = 150; roi.z = 130; roi.w = 340; roi.h = 240;  % ROI in confidence map
freq = 30;
rate = rateControl(freq);

close all
h = figure('Position', [1920/4, 1080/4, 640, 480*2]);
if isRecVideo
    aviObj = VideoWriter([date,'-confMapRt']);
    aviObj.FrameRate = 10;
    aviObj.Quality = 100;
    open(aviObj);
end
while 1
    tic;
    % ===== get confidence map =====
    US_msg = receive(US_sub);
    bscan = readImage(US_msg);
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
    confMap_err_msg.Data = error;   % desired deviation
    % =====================================

    % ===== vis =====
    joint_display = [im2double(bscan); map];
%     joint_display = map;
    imagesc(joint_display); colormap gray; axis off
    hold on; 
    line([centroid, centroid],[1, size(joint_display,1)],'Color','red','LineWidth',1); % confidence centroid
    line([size(bscan,2)/2, size(bscan,2)/2],[1, size(joint_display,1)],'Color','green','LineWidth',1);
    hold off
    if isRecVideo
        writeVideo(aviObj, getframe(h));
    end
    % ===============
    send(confMap_err_pub, confMap_err_msg);
    waitfor(rate);
%     fprintf('loop rate: %f, in-plane-err: %f\n', toc, error);
    
end

%%
if isRecVideo
    close(aviObj);
end