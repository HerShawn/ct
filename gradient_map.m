clear
clc
close all
dir = 'E:\文字检测2012\测试集\ICADR 2003\testimg\';
dirresult = 'E:\文字检测2012\实验结果\方向图\';
color = 0;
for i = 33:33
    imgname = [dir num2str(i) '.jpg'];
    resultname = [dirresult num2str(i) '.jpg'];
    img = imread(imgname);
    img = im2single(img);
    sigma = sqrt(2);
    [h,w,~] = size(img);
    if color
        magGrad = zeros(h,w);
        for j = 1:3
            [dx, dy] = smoothGradient(img(:,:,j), sigma);
            magGrad_t = hypot(dx, dy);
            magGrad = magGrad + magGrad_t;
        end
    else
        img = rgb2gray(img);
        %         figure;imshow(img)
        edge_img = edge(img,'canny');
        imshow(edge_img)
        [dx, dy] = smoothGradient(img, 1);
        magGrad = hypot(dx, dy);
        magGrad = magGrad/max(magGrad(:));
        figure;imshow(magGrad)
        %         orientation = atan2(dy,dx);
        %         orientation = (orientation+pi)/pi/2;
        %         figure;imshow(orientation)
    end
    %     figure;imshow(gray_img)
    %     figure;imshow(magGrad)
    %     a = graythresh(gray_img)/2.5;
    %     a = 0.25;
    %     edge_img = edge(gray_img,'canny',[0.4*a,a]);
    %     edge_img = edge(gray_img,'canny');
    %     figure;imshow(edge_img)
    %     imwrite(orientation,resultname)
end