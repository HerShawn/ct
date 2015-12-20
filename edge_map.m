function edge_map()
clear
clc
close all
dir = 'e:\文字检测2012\测试集\icadr 2003\testimg\';
dirresult = 'e:\文字检测2012\实验结果\边缘结果\';
for i = 1:249
    imgname = [dir num2str(i) '.jpg'];
    resultname = [dirresult num2str(i) '.jpg'];
    img = imread(imgname);
    gray_img = rgb2gray(img);
    gray_img = im2single(gray_img);
    sigma = sqrt(2);
    [dx, dy] = smoothGradient(gray_img, sigma);
    magGrad = hypot(dx, dy);
    magGrad = magGrad/max(magGrad(:));
    lowThresh = graythresh(magGrad)*0.6;
    highThresh = lowThresh/0.4;
    %     [lowThresh, highThresh] = selectThresholds(magGrad);
    edge_img = edge(gray_img,'canny',[lowThresh, highThresh]);
    imwrite(edge_img,resultname)
end
end

% function [lowThresh, highThresh] = selectThresholds(magGrad)
%
% PercentOfPixelsNotEdges = .9; % Used for selecting thresholds
% ThresholdRatio = .4;          % Low thresh is this fraction of the high.
% [m,n] = size(magGrad);
% counts=imhist(magGrad, 64);
% highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
%     1,'first') / 64;
% lowThresh = ThresholdRatio*highThresh;
% end