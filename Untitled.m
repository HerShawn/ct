clear
close all
clc

img_name = ['D:\E≈Ã\2012 Œƒ◊÷ºÏ≤‚\≤‚ ‘ºØ\ICDAR 2011\test-textloc-gt\' '159' '.jpg'];
    img = imread(img_name);
    figure;imshow(img)
    location = [484,620,918,725
553,488,879,589
476,67,940,147
475,180,943,254
];
num_rect = size(location,1);
for i = 1:num_rect
    rectangle('Position',[location(i,1),location(i,2),location(i,3) - location(i,1),location(i,4) - location(i,2)],'LineWidth',3,'EdgeColor','g');
end