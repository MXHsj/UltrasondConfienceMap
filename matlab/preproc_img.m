function [img] = preproc_img(path)

img = imread(path);
img = im2double(img);
img = imadjust(img, [0.007, 0.81]);

end

