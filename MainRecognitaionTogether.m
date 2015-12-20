function MainRecognitaionTogether()
clear
clc
close all
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
addpath(genpath(pwd));
dir_img = dir('E:\2012 文字检测\测试集\ICDAR 2011\test-textloc-gt\*.jpg');
save_dir = 'E:\2013毕设文字检测\试验结果\一起训练\';
num_img = length(dir_img);
% load('model_new.mat')
for indexImg = 1:num_img
    tic
    if indexImg == 76||indexImg == 85
        continue
    end
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    disp(['start compute ' img_value])
          img_value = '203';
    img_name = ['E:\2012 文字检测\测试集\ICDAR 2011\test-textloc-gt\' img_value '.jpg'];
    img = imread(img_name);
%          img = imread('11.jpg');
    imgOrg = img;

    [h,w,~] = size(img);
    %         sizeScale = ceil(sqrt(h*w/(1200*1600)));
    if (h*w>1200*1600)
        sizeScale = (sqrt(h*w/(1200*1600)));
    else
        sizeScale = 1;
    end
    img = imresize(img,1/sizeScale);
    img = im2double(img);
    SaveParameter = 1;
    SaveCorPoint = 1;
    IsSave = 1;
    Debug = 0;
    %% 计算参数
%     [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,SaveParameter,[save_dir 'Parameter\' img_value '.mat']);
    [new_h, new_w, ~] = size(img);
%      load([save_dir 'Parameter\' img_value '.mat']);
%     [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,SaveCorPoint,[save_dir 'CorrespPoint\' img_value '.mat']);  %对应点列表
%      load([save_dir 'CorrespPoint\' img_value '.mat']);
%     [cpoint_cell,new_corresp_p,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_p,cluster_label_big,color.hsi_p,color.rgb_p,color.pro_p,Debug,IsSave,[save_dir 'Merge_P\'],img_value);
%     flag_chain = Character_Pair(cpoint_cell, color_edge_p,cluster_label,new_corresp_p,IsSave,[save_dir 'Chain_P\' img_value '.mat']);
         load([save_dir 'Merge_P\' img_value '.mat']);
     load([save_dir 'Chain_P\' img_value '.mat']);

    [rectCharacterP, rectWordP, charP] = Recognition(cpoint_cell,flag_chain,color_edge,img,Debug);
%     [cpoint_cell,new_corresp_n,color_edge_n] = Edge_merge(bw_img,neighbor_img,cpoint_cell_n,cluster_label_big,color.hsi_n,color.rgb_n,color.pro_n,Debug,IsSave,[save_dir 'Merge_N\'],img_value);
%     flag_chain = Character_Pair(cpoint_cell, color_edge,cluster_label,new_corresp_n,IsSave,[save_dir 'Chain_N\' img_value '.mat']);
         load([save_dir 'Merge_N\' img_value '.mat']);
     load([save_dir 'Chain_N\' img_value '.mat']);
    [rectCharacterN, rectWordN, charN] = Recognition(cpoint_cell,flag_chain,color_edge,img,Debug);
    
    %% 存储结果
    num_p = size(rectWordP,1);
    num_n = size(rectWordN,1);
    result_last = zeros(num_p+num_n,4);
    char_last = cell(1,num_p+num_n);
    factor_w = new_w/w;
    factor_h = new_h/h;
    for i = 1:num_p
        result_last(i,1) = rectWordP(i,1)/factor_w;
        result_last(i,2) = rectWordP(i,2)/factor_h;
        result_last(i,3) = rectWordP(i,3)/factor_w;
        result_last(i,4) = rectWordP(i,4)/factor_h;
        char_last{i} = charP{i};
    end
    for i = 1:num_n
        result_last(i+num_p,1) = rectWordN(i,1)/factor_w;
        result_last(i+num_p,2) = rectWordN(i,2)/factor_h;
        result_last(i+num_p,3) = rectWordN(i,3)/factor_w;
        result_last(i+num_p,4) = rectWordN(i,4)/factor_h;
        char_last{i+num_p} = charN{i};
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
%     if sum(flag_merge)
       char_last(logical(flag_merge)) = [];
%     end
    result_last = floor(result_last);
    result_last = result_last + double(result_last == 0);
    showImg = zeros(h,w,3);
    for i = 1:size(result_last,1)
        showImg(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,3),:) = imgOrg(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,3),:);
    end
    fid = fopen([save_dir 'location14\' img_value '.txt'], 'wt');
    for i = 1:size(result_last,1)
        fprintf(fid, '%d\t%d\t%d\t%d\t%s\n', result_last(i,1),result_last(i,2),result_last(i,3),result_last(i,4),char_last{i});
    end
    
%     dlmwrite([save_dir 'location13\' img_value '.txt'], result_last);
%     imwrite(uint8(showImg),[save_dir 'rgb13\' img_value '.tif']);
    % figure;imshow(img)
% for i = 1:size(rect,1)
%     rectangle('Position', [rect(i,1) rect(i,2) rect(i,3)-rect(i,1)+1 rect(i,4)-rect(i,2)+1],'EdgeColor','r');
%     text(rect(i,1),rect(i,2),num2strR(rect(i,5)),'FontSize',18,'Color','b');
% end
end
end





function feature = ComputeFeature(img)
img = imresize(img, [130 130]);
img = im2double(img);
[~, magGrad, orientation] = Compute_edge(img);
feature = HogFeatureChar(magGrad,orientation);
end

