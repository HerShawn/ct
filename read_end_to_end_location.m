%% written by mengquan 2012-4-6
%% 读取end to end 文章 关于swt检测到得文字框 txt文档
close all
clear
clc
txtname = 'E:\文字检测2012\测试集\ICADR 2003\ICDAR_test.txt';
dir_result = 'E:\文字检测2012\实验结果\SWT最终结果\';
txtdata = importdata(txtname);
location = txtdata.data;
textdata = txtdata.textdata;
location = location(~isnan(location(:,1)),:);

last_location = zeros(size(location,1),5);
last_location(:,2:3) = location(:,1:2);
last_location(:,4) = location(:,1)+location(:,3);
last_location(:,5) = location(:,2)+location(:,4);

position_img = [];
imgname = [];
k = 0;
p = 0;
for i = 1:length(textdata)
    text_line = textdata{i};
    if ~strcmp(text_line, 'Box:')
        k = k+1;
        imgname{k} = text_line;
        position_img(k) = i;
    else
        p = p+1;
        last_location(p) = k;
    end
end
rectnum = diff(position_img)-1; %每张图像中的矩形框个数
rectnum = [rectnum length(textdata) - position_img(end)];
start = cumsum(rectnum)-rectnum;
img_dir = 'E:\文字检测2012\测试集\ICADR 2003\SceneTrialTest\';
img_num = length(imgname);
for i = 1:img_num
    img = imread([img_dir imgname{i}]);
%     figure;imshow(img)
    for j = 1:rectnum(i)
        img = plot_rectangle(img,location(start(i)+j,:),1);
%         figure;imshow(img)
%         rectangle('Position',location(start(i)+j,:),'EdgeColor','r');
    end
    imgname_write = [dir_result num2str(i) '.jpg'];
    imwrite(img,imgname_write);
end