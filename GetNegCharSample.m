
function GetNegCharSample()
clear
close all
clc
addpath('E:\matlab2014a\toolbox');
addpath(genpath(pwd));
dir_img = dir('G:\数据\icdar2011\test-textloc\*.jpg');
save_dir = 'G:\数据\Test_Data\';
num_img = length(dir_img);
load('model_new.mat')
for indexImg = 1:num_img
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    disp(['start compute ' img_value])
    img_name = ['G:\数据\icdar2011\test-textloc\' img_value '.jpg'];
    
    %% 读坐标
    gt_name = ['G:\数据\icdar2011\test-textloc\gt_' img_value '.txt'];
    fid = fopen(gt_name);
    txt_data = textscan(fid,'%d, %d, %d, %d, %s');
    fclose(fid);
    num_gt = length(txt_data{2});
    lc_gt = zeros(num_gt,4);
    for i = 1:num_gt
        lc_gt(i,1) = txt_data{1}(i);
        lc_gt(i,2) = txt_data{2}(i);
        lc_gt(i,3) = txt_data{3}(i);
        lc_gt(i,4) = txt_data{4}(i);
    end
    %%
    img = imread(img_name);
%     figure;imshow(img)
    [h,w,~] = size(img);
    if (h>1000||w>1200)
        continue
    end
    img = im2double(img);
    IsSave = 0;
    Debug = 0;
    %% 计算参数
    [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,IsSave,[save_dir 'Parameter\' img_value '.mat']);
    [new_h, new_w, ~] = size(img);
    [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,IsSave,[save_dir 'CorrespPoint\' img_value '.mat']);  %对应点列表
    %% 计算正方向
    [cpoint_cell_p,new_corresp_p,color_edge_p] = Edge_merge(bw_img,neighbor_img,cpoint_cell_p,cluster_label_big,color.hsi_p,color.rgb_p,color.pro_p,Debug,IsSave,[save_dir 'Merge_P\'],img_value);
    SaveSubImg(cpoint_cell_p, img, lc_gt);
    %% 计算负方向
    [cpoint_cell_n,new_corresp_n,color_edge_n] = Edge_merge(bw_img,neighbor_img,cpoint_cell_n,cluster_label_big,color.hsi_n,color.rgb_n,color.pro_n,Debug,IsSave,[save_dir 'Merge_N\'],img_value);
     SaveSubImg(cpoint_cell_n, img, lc_gt); 
end
end

function SaveSubImg(cpoint_cell, img, lc_gt)
num_gt = size(lc_gt,1);
num_edge = length(cpoint_cell);
for j = 1:num_edge
    x_location = cpoint_cell{j}(:,2);
    y_location = cpoint_cell{j}(:,1);
    top_cc = min(y_location);
    bottom_cc = max(y_location);
    left_cc = min(x_location);
    right_cc = max(x_location);
    height_cc = bottom_cc-top_cc+1;
    width_cc = right_cc-left_cc+1;
    flag = 0;
    if (height_cc*width_cc<10*10)
        continue
    end
    for k = 1:num_gt
        intersection_left = max(lc_gt(k,1),left_cc);
        intersection_top = max(lc_gt(k,2),top_cc);
        intersection_right = min(lc_gt(k,3),right_cc);
        intersection_bottom = min(lc_gt(k,4),bottom_cc);
        num_intersection = max(intersection_right-intersection_left+1,0)*max(intersection_bottom-intersection_top+1,0);
        interRatio = num_intersection/(intersection_right - intersection_left + 1)/(intersection_bottom - intersection_top + 1);
        if (interRatio>0.2)
            flag = 1;
            continue
        end
    end
    if (~flag)
        subImg = img(top_cc:bottom_cc,left_cc:right_cc,:);
        dirsub = dir(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\*.jpg']);
        subIndex = length(dirsub) + 1;
        subImgName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\' num2str(subIndex) '.jpg'];
        imwrite(subImg, subImgName);
    end
end
end

