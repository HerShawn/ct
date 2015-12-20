function edge_test()
clear
clc
close all

imgname = ['036' '.jpg'];
img = imread(imgname);
gray_img = rgb2gray(img);
gray_img = im2single(gray_img);
sigma = sqrt(2);
[dx, dy] = smoothGradient(gray_img, sigma);
magGrad = hypot(dx, dy);
figure;imshow(magGrad)
[lowThresh, highThresh] = selectThresholds(magGrad);
% edge_img = edge(gray_img,'zerocross',[lowThresh, highThresh]);
edge_img = edge(gray_img,'log',0);
figure;imshow(edge_img)
end

function [lowThresh, highThresh] = selectThresholds(magGrad)

PercentOfPixelsNotEdges = .9; % Used for selecting thresholds
ThresholdRatio = .4;          % Low thresh is this fraction of the high.
[m,n] = size(magGrad);
counts=imhist(magGrad, 64);
highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
    1,'first') / 64;
lowThresh = ThresholdRatio*highThresh;
end