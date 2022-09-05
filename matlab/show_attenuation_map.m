clc;
clear all;
img = imread('1.bmp');
%%
img = im2double(img);
img = imadjust(img, [0.007, 0.81]);
alpha = 1.5;
% w1 = attenuationWeighting(img, alpha);
tic;
w2 = attenuationWeighting2(img);
toc;
figure;imshow(img);
% figure;imshow(w1);
% imwrite(w1, 'w1.bmp');
figure;imshow(w2);
imwrite(1 - w2, 'w2.bmp');
% figure;imshow(w1.*w2, []);