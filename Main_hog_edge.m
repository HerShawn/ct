clear
close all
clc
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
addpath(genpath(pwd));
dir_img = dir('E:\2012 文字检测\测试集\ICDAR 2011\test-textloc-gt\*.jpg');
num_img = length(dir_img);
load('model_new.mat')
load train_hog2011.mat
for indexImg = 1:num_img
    if indexImg == 76||indexImg == 85
        continue
    end
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
%     if img_value == '182'||img_value == '191'
%         continue
%     end
    disp(['start compute ' img_value])
    img_name = ['E:\2012 文字检测\测试集\ICDAR 2011\test-textloc-gt\' dir_img(indexImg).name];
%     img_value = '406';
%     img_name = ['E:\2012 文字检测\测试集\ICDAR 2011\test-textloc-gt\' img_value '.jpg'];
    img = imread(img_name);
    [h,w,~] = size(img);
    img = im2double(img);
        sizeScale = ceil(sqrt(h*w/(1280*960)));
    img = imresize(img,1/sizeScale);
    img_gray = rgb2gray(img);
    IsSave = 1;
    Debug = 0;
    save_dir = 'E:\2012 文字检测\代码2011\Test_Data\';
    %% 计算参数
%    [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,IsSave,[save_dir 'Parameter\' img_value '.mat']);
    load([save_dir 'Parameter\' img_value '.mat']);
    [new_h, new_w, ~] = size(img);
%    [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,IsSave,[save_dir 'CorrespPoint\' img_value '.mat']);  %对应点列表
    load([save_dir 'CorrespPoint\' img_value '.mat']);
    %% 计算正方向
%     [cpoint_cell_p,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_p,cluster_label_big,color.hsi_p,color.rgb_p,Debug,IsSave,[save_dir 'Merge_P\'],img_value);
    load([save_dir 'Merge_P\' img_value '.mat']);
%     feature_vector = Compute_feature(cpoint_cell_p,cluster_label,new_corresp,IsSave,[save_dir 'Feature_P\' img_value '.mat']);
    load([save_dir 'Feature_P\' img_value '.mat']);
%     flag_chain = Character_Pair(cpoint_cell_p, color_edge,cluster_label,new_corresp,IsSave,[save_dir 'Chain_P\' img_value '.mat']);
    load([save_dir 'Chain_P\' img_value '.mat']);
    Classify_character_hog(cpoint_cell, color_edge, feature_vector, flag_chain, img, model,RLearners, RWeights,IsSave,[save_dir 'hog\p'],img_value,new_h,new_w);
    %% 计算负方向
 %   [cpoint_cell_n,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_n,cluster_label_big,color.hsi_n,color.rgb_n,0,IsSave,[save_dir 'Merge_N\'],img_value);
     load([save_dir 'Merge_N\' img_value '.mat']);
 %    feature_vector = Compute_feature(cpoint_cell_n,cluster_label,new_corresp,IsSave,[save_dir 'Feature_N\' img_value '.mat']);
     load([save_dir 'Feature_N\' img_value '.mat']);
%    flag_chain = Character_Pair(cpoint_cell_n, color_edge,cluster_label,new_corresp,IsSave,[save_dir 'Chain_N\' img_value '.mat']);
    load([save_dir 'Chain_N\' img_value '.mat']);
    Classify_character_hog(cpoint_cell, color_edge, feature_vector, flag_chain, img, model,RLearners, RWeights,IsSave,[save_dir 'hog\n'],img_value,new_h,new_w);
    if 0
        
        bw_result = bw_result_p|bw_result_n;
        color_r = max(cat(3,rgb_result_p(:,:,1),rgb_result_n(:,:,1)),[],3);
        color_g = max(cat(3,rgb_result_p(:,:,2),rgb_result_n(:,:,2)),[],3);
        color_b = max(cat(3,rgb_result_p(:,:,3),rgb_result_n(:,:,3)),[],3);
        rgb_result = cat(3,color_r,color_g,color_b);
        
        color_r = max(cat(3,show_img_p(:,:,1),show_img_n(:,:,1)),[],3);
        color_g = max(cat(3,show_img_p(:,:,2),show_img_n(:,:,2)),[],3);
        color_b = max(cat(3,show_img_p(:,:,3),show_img_n(:,:,3)),[],3);
        show_img = cat(3,color_r,color_g,color_b);
        
        imwrite(rgb_result,[save_dir '\PosNeg\rgb' img_value '.tif']);
        imwrite(show_img,[save_dir '\PosNeg\edge_class' img_value '.tif']);
        imwrite(bw_result,[save_dir '\PosNeg\bw_result' img_value '.tif']);
        
        num_p = size(result_p,1);
        num_n = size(result_n,1);
        result_last = zeros(num_p+num_n,4);
        factor_w = new_w/w;
        factor_h = new_h/h;
        for i = 1:num_p
            result_last(i,1) = result_p(i,1)/factor_w;
            result_last(i,2) = result_p(i,2)/factor_h;
            result_last(i,3) = result_p(i,3)/factor_w;
            result_last(i,4) = result_p(i,4)/factor_h;
        end
        for i = 1:num_n
            result_last(i+num_p,1) = result_n(i,1)/factor_w;
            result_last(i+num_p,2) = result_n(i,2)/factor_h;
            result_last(i+num_p,3) = result_n(i,3)/factor_w;
            result_last(i+num_p,4) = result_n(i,4)/factor_h;
        end
        dlmwrite([save_dir 'location\' img_value '.txt'], result_last);
    end
end
