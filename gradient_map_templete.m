clear
clc
close all
dir = 'E:\���ּ��2012\���Լ�\ICADR 2003\testimg\';
dirresult = 'E:\���ּ��2012\ʵ����\�ݶ�ͼ([-1,1])\';
x = [-1,0,1];
y = x';
for i = 1:249
    imgname = [dir num2str(i) '.jpg'];
    resultname = [dirresult num2str(i) '.jpg'];
    img = imread(imgname);
    img = rgb2gray(img);
    dx = imfilter(double(img),x);
    dy = imfilter(double(img),y);
    magGrad = hypot(dx, dy);
    magmax = max(magGrad(:));
    if magmax > 0
        magGrad = magGrad / magmax;
    end
    imwrite(magGrad,resultname)
end