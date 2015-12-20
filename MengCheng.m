function MengCheng()
close all
clear
clc
img_database = 'E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\';
height = 80;
width = 60;
inter_x = 30;
inter_y = 20;
dir_img = dir([img_database '*.jpg']);
num_img = length(dir_img);
img_new_rgb = zeros(height*inter_y,width*inter_x,3);

img_org = imread('Andy-01.jpg');
img_org = im2double(img_org);
img_org = imresize(img_org,[height,width]);

for i = 1:height
    for j = 1:width
        disp([num2str(i) num2str(j)])
        index = ceil(rand(1,1)*num_img);
        imgname = [img_database dir_img(index).name];
        img_use = imread(imgname);
        img_use = imresize(img_use,[inter_y,inter_x]);
        img_use = im2double(img_use);
        sum_use_r = sum(sum(img_use(:,:,1)))/inter_y/inter_x;
        sum_use_g = sum(sum(img_use(:,:,2)))/inter_y/inter_x;
        sum_use_b = sum(sum(img_use(:,:,3)))/inter_y/inter_x;
        left = (j-1)*inter_x+1;
        top = (i-1)*inter_y+1;
        right = j*inter_x;
        bottom = i*inter_y;
        r_weight = img_org(i,j,1)/sum_use_r;
        g_weight = img_org(i,j,2)/sum_use_g;
        b_weight = img_org(i,j,3)/sum_use_b;
        img_new_rgb(top:bottom,left:right,1) = img_use(:,:,1)*r_weight;
        img_new_rgb(top:bottom,left:right,2) = img_use(:,:,2)*g_weight;
        img_new_rgb(top:bottom,left:right,3) = img_use(:,:,3)*b_weight;
        % img_new_rgb = hsi2rgb(img_new_hsi);
    end
end
figure;imshow((img_new_rgb))
end
