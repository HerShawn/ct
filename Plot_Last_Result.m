clear
close all
clc
img_value = '00_13';
img_name = ['E:\2012 文字检测\测试集\svt1\img\' img_value '.jpg'];
txt_name = ['E:\2012 文字检测\SVT结果\location\' img_value '.txt'];
img = imread(img_name);
figure;imshow(img);
hold on
location = dlmread(txt_name);
num_rect = size(location,1);
for i = 1:num_rect
    rectangle('Position',[location(i,1),location(i,2),location(i,3) - location(i,1),location(i,4) - location(i,2)],'LineWidth',3,'EdgeColor','g');
end
txt_name = ['E:\2012 文字检测\SVT结果\gt\' img_value '.txt'];
location = dlmread(txt_name);
num_rect = size(location,1);
for i = 1:num_rect
    rectangle('Position',[location(i,1),location(i,2),location(i,3) - location(i,1),location(i,4) - location(i,2)],'LineWidth',3,'EdgeColor','b');
end