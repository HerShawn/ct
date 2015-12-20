function [location,rgb_result, show_img, bw_result]  = Classify_character(cpoint_cell, color_edge, feature_vector, flag_chain,img, model,RLearners, RWeights,IsSave, resultName, img_value, h, w)

% if direction == 1
%     dir = 'data_positive/';
% else
%     dir = 'data_negative/';
% end
% name1 = [dir 'feature/feature' num2str(img_index) '.mat'];
% name2 = [dir 'position/position' num2str(img_index) '.mat'];
% name3 = [dir 'chain/chain' num2str(img_index) '.mat'];
% name4 = [dir 'color_edge/color_edge' num2str(img_index) '.mat'];
% img = imread(['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICADR 2003\testimg\' num2str(img_index) '.jpg']);
% [h,w,~] = size(img);
% load(name1)
% load(name2)
% load(name3)
% load(name4)
% load('model_new.mat')
% [flag_character location feature_all] = classify_chain_one(cpoint_cell,color_edge, img, feature_vector, flag_chain, model);
[flag_character location] = classify_chain(cpoint_cell, color_edge,img, feature_vector, flag_chain, model, RLearners, RWeights);
num_chain = size(location,1);
if 1
    bw_result = zeros(h,w);
    rgb_result = ones(h,w,3);
    for i = 1:num_chain
        left = location(i,1);
        top = location(i,2);
        right = location(i,3);
        bottom = location(i,4);
        bw_result(top:bottom,left:right) = 1;
        rgb_result(top:bottom,left:right,:) = img(top:bottom,left:right,:);
    end
    show_img = show_result(cpoint_cell,h,w,flag_character);
else
    show_img = [];
    bw_result = [];
    rgb_result = [];
    %     imwrite(rgb_result,[resultName 'rgb' img_value '.tif']);
    %     imwrite(show_img,[resultName 'edge_class' img_value '.tif']);
    %     imwrite(bw_result,[resultName 'bw_result' img_value '.tif']);
end
%     result = [];
%     bw_result = zeros(h,w);
%     rgb_result = zeros(h,w,3);
%     for i = 1:num_chain
%         left = location(i,1);
%         top = location(i,2);
%         right = location(i,3);
%         bottom = location(i,4);
%         bw_result(top:bottom,left:right) = 1;
%         rgb_result(top:bottom,left:right,:) = img(top:bottom,left:right,:);
%     end
%     rgb_result = uint8(rgb_result);
%     show_img = show_result(cpoint_cell_p,h,w,flag_character);
%       figure;imshow(rgb_result)
%     imwrite(bw_result,[dir 'bw_result' num2str(img_index) '.tif']);
%     imwrite(rgb_result,[dir 'rgb_result' num2str(img_index) '.tif']);
%     % imwrite(show_img,[dir 'edge_class' num2str(img_index) '.jpg']);
%       figure;imshow(show_img)
end