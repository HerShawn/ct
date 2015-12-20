function MainRecognitaion()
clear
clc
close all
addpath('E:\matlab2014a\toolbox');
addpath(genpath(pwd));
dir_img = dir('G:\数据\icdar2011\test-textloc\*.jpg');
addpath('G:\数据\孟泉代码\代码\GML_AdaBoost_Matlab_Toolbox_0.3');
save_dir = 'G:\数据\Test_Data\';
num_img = length(dir_img);
% load('model_new.mat')
% for indexImg = 1:num_img
    for indexImg = 1:1
    
        if indexImg == 76||indexImg == 85
        continue
    end
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    disp(['start compute ' img_value])
          img_value = '101';
    img_name = ['G:\数据\icdar2011\test-textloc\' img_value '.jpg'];
    img = imread(img_name);
    imgOrg = img;
    %     img = imread('11.jpg');
    [h,w,~] = size(img);
    %         sizeScale = ceil(sqrt(h*w/(1200*1600)));
    if (h*w>1200*1600)
     sizeScale = ceil(sqrt(h*w/(1200*1600)));   
    else
        sizeScale = 1;
    end
    img = imresize(img,1/sizeScale);
    img = im2double(img);
    
    IsSave = 0;
    Debug = 0;
    %% 计算参数
    tic
    [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,IsSave,[save_dir 'Parameter\' img_value '.mat']);
    toc
    [new_h, new_w, ~] = size(img);
    tic
    [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,IsSave,[save_dir 'CorrespPoint\' img_value '.mat']);  %对应点列表
    toc
    [cpoint_cell_p,new_corresp_p,color_edge_p] = Edge_merge(bw_img,neighbor_img,cpoint_cell_p,cluster_label_big,color.hsi_p,color.rgb_p,color.pro_p,Debug,IsSave,[save_dir 'Merge_P\'],img_value);
    flag_chain = Character_Pair(cpoint_cell_p, color_edge_p,cluster_label,new_corresp_p,IsSave,[save_dir 'Chain_P\' img_value '.mat']);
    [rectCharacterP, rectWordP] = Recognition(cpoint_cell_p,flag_chain,color_edge_p,img);
    [cpoint_cell_n,new_corresp_n,color_edge_n] = Edge_merge(bw_img,neighbor_img,cpoint_cell_n,cluster_label_big,color.hsi_n,color.rgb_n,color.pro_n,Debug,IsSave,[save_dir 'Merge_N\'],img_value);
    flag_chain = Character_Pair(cpoint_cell_n, color_edge_n,cluster_label,new_corresp_n,IsSave,[save_dir 'Chain_P\' img_value '.mat']);
    [rectCharacterN, rectWordN] = Recognition(cpoint_cell_n,flag_chain,color_edge_n,img);
    
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
    dlmwrite([save_dir 'location_recog\' img_value '.txt'], result_last);
    showImg = zeros(h,w,3);
    for i = 1:size(result_last,1)
        showImg(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,3),:) = imgOrg(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,3),:);
    end
    imwrite(uint8(showImg),[save_dir 'rgb_recog\' img_value '.tif']);
end
end


function [rect,rectWord] = Recognition(cpoint_cell,flag_chain,colorEdge,img)
imgHSI = rgb2hsi(img);
num_character = length(cpoint_cell);
rect = [];
rectWord = [];
featureAll = [];
% flagSolo = zeros(1,num_edge);
% for i = 1:num_edge
%     if flag_chain(i)>0
%         flagSolo(i) = 1;
%     end
% end
[h,w,~] = size(img);
num_chain = max(flag_chain);
%% color chain
color_chain_min = ones(num_chain,6);
color_chain_max = zeros(num_chain,6);
for i = 1:num_character
    value_chain = flag_chain(i);
    if value_chain
        color_chain_min(value_chain,:) = min([colorEdge(i,:);color_chain_min(value_chain,:)],[],1);
        color_chain_max(value_chain,:) = max([colorEdge(i,:);color_chain_max(value_chain,:)],[],1);
    end
end
%%
for i = 1:num_chain
    index_chain = find(flag_chain == i);
    left = w; right = 0; top = h; bottom = 0;
    numCC = length(index_chain);
    %     colorTmp = zeros(numCC,6);
    %     bwSubImg = zeros(height_chain, width_chain);
    for j = 1:numCC
        location_x = cpoint_cell{index_chain(j)}(:,2);
        location_y = cpoint_cell{index_chain(j)}(:,1);
        %         colorTmp(j,:) = colorEdge(index_chain(j),:);
        left = min(left, min(location_x));
        right = max(right, max(location_x));
        top = min(top, min(location_y));
        bottom = max(bottom, max(location_y));
    end
    %     colorTmp = mean(colorTmp,1);
    subImg = img(top:bottom,left:right,:);
    subHsi = imgHSI(top:bottom,left:right,:);
    
    location = Get_ccEdge(subImg,subHsi,color_chain_min(i,:),color_chain_max(i,:));
    if isempty(location)
        continue
    end
    location(1,:) = location(1,:) + left - 1;
    location(2,:) = location(2,:) + top - 1;
    location(3,:) = location(3,:) + left - 1;
    location(4,:) = location(4,:) + top - 1;
    for j = 1:size(location,2)
        subImg = img(location(2,j):location(4,j),location(1,j):location(3,j),:);
        subImg = imresize(subImg,[100 100]);
        
%         feature = hog(subImg,25,4);
        feature = hog(subImg);
        feature = feature(:)';
        feature = double(feature);
        featureAll = [featureAll; feature location(1,j) location(2,j) location(3,j) location(4,j) i];
    end
end
classMax = zeros(size(featureAll,1),62);
for j = [1:26 28:62]
    load(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(j) '.mat']);
    [~,y] = classRF_predict(featureAll(:,1:end-4),model);
    y = y(:,2)/500;
    classMax(:,j) = y;
end
[classValue, classIndex] = max(classMax,[],2);
rect = [];
for i = 1:num_chain
    index = featureAll(:,end) == i;
    if mean(classValue(index))>0.5
        rect = [rect; featureAll(index,end-4:end-1) classIndex(index)];
        rectWord = [rectWord;min(featureAll(index,end-4)),min(featureAll(index,end-3)),max(featureAll(index,end-2)),max(featureAll(index,end-1))];
    end
end
figure;imshow(img)
for i = 1:size(rect,1)
    rectangle('Position', [rect(i,1) rect(i,2) rect(i,3)-rect(i,1)+1 rect(i,4)-rect(i,2)+1],'EdgeColor','r');
    text(rect(i,1),rect(i,2),num2strR(rect(i,5)),'FontSize',18,'Color','b');
end
end


function feature = ComputeFeature(img)
img = imresize(img, [130 130]);
img = im2double(img);
[~, magGrad, orientation] = Compute_edge(img);
feature = HogFeatureChar(magGrad,orientation);
end

function charV = num2strR(v)
charV = zeros(1,length(v));
for i = 1:length(v)
    if v(i)<=10
        charV(i) = v(i) + 48 -1;
    elseif v(i)<=36
        charV(i) = v(i) +65 - 11;
    else
        charV(i) = v(i) +97 - 37;
    end
end
charV = char(charV);
end