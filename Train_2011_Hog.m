function [RLearners RWeights] = Train_2011_Hog()
clear
close all
clc
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
addpath('E:\2012 ÎÄ×Ö¼ì²â\´úÂë2011\GML_AdaBoost_Matlab_Toolbox_0.3');
dir_file = 'E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\';
dir_img = dir([dir_file '*.jpg']);
dir_txt = dir([dir_file '*.txt']);
num_img = length(dir_img);
FeaturePositive = [];
FeatureNeg = [];
for i = 1:num_img
    disp(['start compute ' num2str(i)])
    img_name = [dir_file dir_img(i).name];
    txt_name = [dir_file dir_txt(i).name];
    img = imread(img_name);
    [h,w,~] = size(img);
    img = im2double(img);
    fid = fopen(txt_name);
    txt_data = textscan(fid,'%d,%d,%d,%d,%s');
    num_word = length(txt_data{2});
    position = zeros(num_word,4);
    for j = 1:num_word
        left = max(txt_data{1}(j),1);
        top = max(txt_data{2}(j),1);
        right = min(txt_data{3}(j),w);
        bottom = min(txt_data{4}(j),h);
        position(j,1) = left;
        position(j,2) = top;
        position(j,3) = right;
        position(j,4) = bottom;
        sub_img = img(top:bottom,left:right,:);
        %         figure;imshow(sub_img)
        sub_img = imresize(sub_img,[24 24*3]);
        feature = Compute_HogFeature(sub_img);
        FeaturePositive = [FeaturePositive;feature];
        if size(FeaturePositive,1) == 826
        end
    end
    %     [edge_img, ~, ~, ~, ~] = Compute_edge(img);
    %     edge_img = imdilate(edge_img,[0 1 0;1 1 1;0 1 0]);
    k = 0;
    p = 0;
    while (1)
        p = p+1;
        left = ceil(rand(1,1)*w);
        top = ceil(rand(1,1)*h);
        right = left + ceil(rand(1,1)*(w - left));
        bottom = top + ceil(rand(1,1)*(h - top)) ;
        flagSize = (right - left + 1)>10&&(bottom - top + 1)>10;
        flag_Overlap = IsOverlapped(left,top,right,bottom,position);
        if ((~flag_Overlap)&&flagSize)
            k = k+1;
            sub_img = img(top:bottom,left:right,:);
            sub_img = imresize(sub_img,[24 24*3]);
            %             figure;imshow(sub_img)
            feature = Compute_HogFeature(sub_img);
            FeatureNeg = [FeatureNeg; feature];
        end
        if k>=num_word*5||p>1000
            break
        end
    end
    fclose(fid);
    %     figure;imshow(edge_img)
end
% Step3: constructing weak learner
Feature = [FeaturePositive;FeatureNeg];
num_positive = size(FeaturePositive,1);
num_neg = size(FeatureNeg,1);
Label = [ones(1,num_positive) -1*ones(1,num_neg)];
% Step4: training with Gentle AdaBoost
MaxIter = 100; % boosting iterations
weak_learner = tree_node_w(3); % pass the number of tree splits to the constructor
[RLearners RWeights] = RealAdaBoost(weak_learner, Feature', Label, MaxIter);
save train_hog2011_new.mat RLearners RWeights
end

function flag_Overlap = IsOverlapped(left,top,right,bottom,position)
num_rec = size(position,1);
flag_Overlap = 0;
for i = 1:num_rec
    flag1 = (left>position(i,1)&&left<position(i,3)) || (right>position(i,1)&&right<position(i,3));
    flag1 = flag1 && (top<position(i,4)||bottom>position(i,2));
    flag2 = (top>position(i,2)&&top<position(i,4)) || (bottom>position(i,2)&&bottom<position(i,4));
    flag2 = flag2 && (left<position(i,3)||left>position(i,1));
    flag3 = left<=position(i,1)&&top<=position(i,2)&&right>=position(i,3)&&bottom>=position(i,4);
    flag = flag1||flag2||flag3;
    flag_Overlap = flag_Overlap|flag;
end
end