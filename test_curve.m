clear
clc
img = imread('ÇúÏßÅÅÁÐÎÄ×Ö.jpg');
% figure;imshow(img)
img = ~im2bw(img);
% bw = bwlabel(img,8);
% figure;imshow(bw)
rprops = regionprops(img,'Centroid');
pair_para = [1 2 0;
    2 3 0;
    3 4 0;
    4 5 0;
    5 6 0;
    6 7 0;
    7 8 0];
num_cc = 7;
for i = 1:num_cc
    diff_x = rprops(pair_para(i,2)).Centroid(1)-rprops(pair_para(i,1)).Centroid(1);
    diff_y = rprops(pair_para(i,2)).Centroid(2)-rprops(pair_para(i,1)).Centroid(2);
    orientation = atan2(diff_y,diff_x);
    pair_para(i,3) = orientation;
end
chain_para = Aggregation_Chain(pair_para);
center_l = zeros(8,2);
for i = 1:8
    center_l(i,1) = rprops(i).Centroid(1);
    center_l(i,2) = rprops(i).Centroid(2);
end
plot_aggregation_line(chain_para,img,center_l)