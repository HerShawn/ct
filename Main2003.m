%% 处理ICDAR2003测试集
clear
close all
clc
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
addpath('E:\2012 文字检测\代码2011\GML_AdaBoost_Matlab_Toolbox_0.3');
addpath(genpath(pwd));
dir_img = dir('E:\2012 文字检测\测试集\ICADR 2003\testimg\*.jpg');
save_dir = 'E:\2013毕设文字检测\试验结果\ICDAR2003\';
num_img = length(dir_img);
load('model_new.mat')
load train_hog2011.mat
for indexImg = 1:num_img
     if indexImg == 132
         continue
     end
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    disp(['start compute ' img_value])
    img_name = ['E:\2012 文字检测\测试集\ICADR 2003\testimg\' img_value '.jpg'];
    img = imread(img_name);
%     figure;imshow(img)
    [h,w,~] = size(img);
       img = im2double(img);
 
    IsSave = 0;
    Debug = 0;
    %% 计算参数
%     [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,IsSave,[save_dir 'Parameter\' img_value '.mat'],RLearners, RWeights);
%     continue
    load([save_dir 'Parameter\' img_value '.mat']);
    [new_h, new_w, ~] = size(img);
%    [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,IsSave,[save_dir 'CorrespPoint\' img_value '.mat']);  %对应点列表
   load([save_dir 'CorrespPoint\' img_value '.mat']);
    %% 计算正方向
    [cpoint_cell,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_p,cluster_label_big,color.hsi_p,color.rgb_p,color.rgb_p,Debug,IsSave,[save_dir 'Merge_P\'],img_value);
     flag_chain = Character_Pair(cpoint_cell, color_edge,cluster_label,new_corresp,IsSave,[save_dir 'Chain_P\' img_value '.mat']);
     [rectCharacterP, rectWordP] = Recognition(cpoint_cell,flag_chain,color_edge,img,Debug);

    %% 计算负方向
    [cpoint_cell,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_n,cluster_label_big,color.hsi_n,color.rgb_n,color.rgb_n,Debug,IsSave,[save_dir 'Merge_N\'],img_value);
    flag_chain = Character_Pair(cpoint_cell, color_edge,cluster_label,new_corresp,IsSave,[save_dir 'Chain_N\' img_value '.mat']);
    [rectCharacterN, rectWordN] = Recognition(cpoint_cell,flag_chain,color_edge,img,Debug);
    %% 存储结果
    num_p = size(rectWordP,1);
    num_n = size(rectWordN,1);
    result_last = zeros(num_p+num_n,4);
    factor_w = new_w/w;
    factor_h = new_h/h;
    for i = 1:num_p
        result_last(i,1) = rectWordP(i,1)/factor_w;
        result_last(i,2) = rectWordP(i,2)/factor_h;
        result_last(i,3) = rectWordP(i,3)/factor_w;
        result_last(i,4) = rectWordP(i,4)/factor_h;
    end
    for i = 1:num_n
        result_last(i+num_p,1) = rectWordN(i,1)/factor_w;
        result_last(i+num_p,2) = rectWordN(i,2)/factor_h;
        result_last(i+num_p,3) = rectWordN(i,3)/factor_w;
        result_last(i+num_p,4) = rectWordN(i,4)/factor_h;
    end
    flag_merge = zeros(1,num_p+num_n);
    for i = 1:num_p+num_n
        for j  = 1:num_p+num_n
            flag = result_last(i,1)>result_last(j,1)&&result_last(i,2)>result_last(j,2)&&result_last(i,3)<result_last(j,3)&&result_last(i,4)<result_last(j,4);
            if flag
                flag_merge(i) = flag;
                continue
            end
        end
    end
    result_last(logical(flag_merge),:) = [];
    result_last = floor(result_last);
    result_last = result_last + double(result_last == 0);
    showImg = zeros(h,w,3);
    for i = 1:size(result_last,1)
        showImg(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,3),:) = img(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,3),:);
    end
    dlmwrite([save_dir '\location\' img_value '.txt'], result_last);
    imwrite(showImg,[save_dir '\PosNeg\rgb' img_value '.tif']);
end

