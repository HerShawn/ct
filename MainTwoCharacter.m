function MainTwoCharacter()
clear
close all
clc
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
addpath(genpath(pwd));
dir_img = dir('E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\*.jpg');
num_img = length(dir_img);
load('model_new.mat')
for indexImg = 1:num_img
    if indexImg == 76||indexImg == 85
        continue
    end
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    disp(['start compute ' img_value])
    img_name = ['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\' dir_img(indexImg).name];
    img = imread(img_name);
    img = im2double(img);
    [h,w,~] = size(img);
    sizeScale = ceil(sqrt(h*w/(1280*960)));
    img = imresize(img,1/sizeScale);
    Show_two_character(img_value,img,model,1);
    Show_two_character(img_value,img,model,0);
end
end