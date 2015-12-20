clear
clc
close all
img = imread('036.jpg');
img = im2single(img);
img_gray = rgb2gray(img);
% figure;imshow(imgrgb)
templete = 1;
color = 0;
[h,w,~] = size(img);

if templete == 0
    sigma = sqrt(2);
    if color
        magGrad = zeros(h,w);
        for j = 1:3
            [dx, dy] = smoothGradient(img(:,:,j), sigma);
            magGrad_t = hypot(dx, dy);
            magGrad = magGrad + magGrad_t;
        end
        figure;imshow(magGrad)
    else
        [dx, dy] = smoothGradient(img_gray, sigma);
        magGrad = hypot(dx, dy);
        magGrad = magGrad / max(magGrad(:)) ;
        figure;imshow(magGrad)
        Ib = binarization(img_gray);
        figure;imshow(Ib)
%         a = graythresh(magGrad)/2;
%         edge_map = edge(imgrgb,'canny',a);
%         figure;imshow(edge_map)
    end
else
    x = [-1,0,1];
    y = x';
    dx = imfilter(double(img_gray),x);
    dy = imfilter(double(img_gray),y);
    magGrad = hypot(dx, dy);
    magmax = max(magGrad(:));
    if magmax > 0
        magGrad = magGrad / magmax;
    end
    figure;imshow(magGrad)
end
