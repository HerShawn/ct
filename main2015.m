clear
close all
clc
% addpath('C:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
% addpath('E:\matlab2014a\toolbox');
addpath('F:\Program Files\matlab\toolbox');
addpath('D:\coarse_localization\ct\GML_AdaBoost_Matlab_Toolbox_0.3');
addpath(genpath(pwd));
% dir_img = dir('G:\数据\test-textloc\*.jpg');
% dir_img = dir('E:\数据\icdar2011\train\train-textloc\*.jpg');
dir_img = dir('E:\数据\icdar2015\Challenge2_Test_Task12_Images\*.jpg');
% save_dir = 'E:\数据\Train_Data\';
save_dir = 'E:\数据\Train_Data_2015';
% save_result_dir='D:\hx\edgebox-contour-neumann\contour_2011train_detection';
save_result_dir='D:\hx\edgebox-contour-neumann\contour_2015train_detection';
num_img = length(dir_img);
load('model_new.mat')
load train_hog2011.mat
for indexImg = 5:num_img
    %     if indexImg == 76||indexImg == 85
    %         continue
    %     end
    img_value = dir_img(indexImg).name;
    img_value = img_value(1:end-4);
    %     if img_value == '182'||img_value == '191'
    %         continue
    %     end
    %     disp(['start compute ' img_value])
    %     img_name = ['E:\2012 文字检测\测试集\ICDAR 2011\test-textloc-gt\' dir_img(indexImg).name];
    %        img_value = '148';
    %     img_name = ['G:\数据\test-textloc\' img_value '.jpg'];
    % img_name = ['E:\数据\icdar2011\train\train-textloc\' img_value '.jpg'];
    img_name = ['E:\数据\icdar2015\Challenge2_Test_Task12_Images\' img_value '.jpg'];
    img = imread(img_name);
    g=img;
    %10.14 不显示图片，数据集里255张图片太多
    %        figure;imshow(img);title('原图');
    %
    
    [h,w,~] = size(img);
    sizeScale = ceil(sqrt(h*w/(1200*1600)));
    %      sizeScale = (sqrt(h*w/(1200*1600)));
    %    sizeScale = 1;
    img = imresize(img,1/sizeScale);
    img = im2double(img);
    IsSave = 0;
    Debug = 1;
    %% 计算参数
    tic
    [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,IsSave,[save_dir 'Parameter\' img_value '.mat'],RLearners, RWeights);
    toc
    %     continue
    %    load([save_dir 'Parameter\' img_value '.mat']);
    [new_h, new_w, ~] = size(img);
    tic
    [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,IsSave,[save_dir 'CorrespPoint\' img_value '.mat']);  %对应点列表
    toc
    %   load([save_dir 'CorrespPoint\' img_value '.mat']);
    %% 计算正方向
    tic
    [cpoint_cell,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_p,cluster_label_big,color.hsi_p,color.rgb_p,color.pro_p,Debug,IsSave,[save_dir 'Merge_P\'],img_value);
    toc
    %    load([save_dir 'Merge_P\' img_value '.mat']);
    feature_vector = Compute_feature(cpoint_cell,cluster_label_big,new_corresp,IsSave,[save_dir 'Feature_P\' img_value '.mat']);
    %    load([save_dir 'Feature_P\' img_value '.mat']);
    flag_chain = Character_Pair(cpoint_cell, color_edge,cluster_label,new_corresp,IsSave,[save_dir 'Chain_P\' img_value '.mat']);
    %   load([save_dir 'Chain_P\' img_value '.mat']);
    [result_p rgb_result_p,show_img_p, bw_result_p]= Classify_character(cpoint_cell, color_edge, feature_vector, flag_chain, img, model,RLearners, RWeights, IsSave,[save_dir 'Location_P\'],img_value,new_h,new_w);
    %% 计算负方向
    tic
    [cpoint_cell,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell_n,cluster_label_big,color.hsi_n,color.rgb_n,color.pro_n,Debug,IsSave,[save_dir 'Merge_N\'],img_value);
    toc
    %      load([save_dir 'Merge_N\' img_value '.mat'])
    feature_vector = Compute_feature(cpoint_cell,cluster_label_big,new_corresp,IsSave,[save_dir 'Feature_N\' img_value '.mat']);
    %      load([save_dir 'Feature_N\' img_value '.mat']);
    flag_chain = Character_Pair(cpoint_cell, color_edge,cluster_label,new_corresp,IsSave,[save_dir 'Chain_N\' img_value '.mat']);
    %      load([save_dir 'Chain_N\' img_value '.mat']);
    [result_n rgb_result_n,show_img_n, bw_result_n] = Classify_character(cpoint_cell, color_edge, feature_vector, flag_chain, img, model,RLearners, RWeights,IsSave,[save_dir 'Location_N\'],img_value,new_h,new_w);
    toc
    %     figure;imshow(rgb_result_p)
    % figure;imshow(rgb_result_n)
    if 1
        
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
        
        %           figure;imshow(img);title('检测效果');
        result_ct_last=[];
        for i=1:size(result_last, 1)
            %          rectangle('Position',[result_last(i,1) result_last(i,2) result_last(i,3)-result_last(i,1)+1 result_last(i,4)-result_last(i,2)+1], 'EdgeColor', 'g', 'LineWidth', 2);
            img(result_last(i,2)-1:result_last(i,2)+1,result_last(i,1):result_last(i,3)) = 1;
            img(result_last(i,4)-1:result_last(i,4)+1,result_last(i,1):result_last(i,3)) = 1;
            img(result_last(i,2):result_last(i,4),result_last(i,1):result_last(i,1)+2) = 1;
            img(result_last(i,2):result_last(i,4),result_last(i,3)-2:result_last(i,3)) = 1;
            %         imwrite(img,[save_dir 'detection\' img_value '.jpg']);
            %         pt = [result_last(i,1), result_last(i,2)];
            %         wSize = [result_last(i,3)-result_last(i,1)+1,result_last(i,4)-result_last(i,2)+1];
            %         des = drawRect(img,pt,wSize,3,[128 255 0] );
            %         img=des;
            %          subplot(1,2,1)
            %         imshow(img)
            %          rectangle('Position',[result_last(i,1) result_last(i,2) result_last(i,3)-result_last(i,1)+1 result_last(i,4)-result_last(i,2)+1], 'EdgeColor', 'g', 'LineWidth', 2);
            %         subplot(1,2,2)
            %          imshow(des)
            %         F=getframe(gcf);
            %         img(F.cdata);
            result_ct=[max(result_last(i,1),1) max(result_last(i,2),1) result_last(i,3)-result_last(i,1)  result_last(i,4)-result_last(i,2) ];
            
            result_ct_last=[result_ct_last ;result_ct];
            %           imwrite(img,[save_result_dir '\' num2str(indexImg+99) '.jpg']);
        end
        if ~isempty(result_ct_last)
        figure(indexImg);
        bbGt('showRes',g,result_ct_last,result_ct_last);
        save_name=[img_value '.jpg'];
        print(indexImg, '-dpng', save_name);
        end
        %         dlmwrite([save_result_dir '\' img_value '.txt'],result_last);
        dlmwrite([save_result_dir '\' img_value '.txt'], result_last, 'delimiter', ',','newline', 'pc');
        clear result_n rgb_result_n show_img_n  bw_result_n  result_p rgb_result_p show_img_p  bw_result_p
    end
end

