function Classify_character_hog(cpoint_cell, color_edge, feature_vector, flag_chain,img, model,RLearners, RWeights,IsSave, resultName, img_value, h, w)

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
[location1 location2] = classify_chain_hog(cpoint_cell,color_edge, img, feature_vector, flag_chain, model, RLearners, RWeights);
num_chain1 = size(location1,1);
num_chain2 = size(location2,1);
if IsSave
    rgb_result1 = zeros(h,w,3);
    for i = 1:num_chain1
        left = location1(i,1);
        top = location1(i,2);
        right = location1(i,3);
        bottom = location1(i,4);
        rgb_result1(top:bottom,left:right,:) = img(top:bottom,left:right,:);
    end
    imwrite(rgb_result1,[resultName 'Posrgb' img_value '.tif']);
        rgb_result2 = zeros(h,w,3);
    for i = 1:num_chain2
        left = location2(i,1);
        top = location2(i,2);
        right = location2(i,3);
        bottom = location2(i,4);
        rgb_result2(top:bottom,left:right,:) = img(top:bottom,left:right,:);
    end
    imwrite(rgb_result2,[resultName 'Negrgb' img_value '.tif']);
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
%     % figure;imshow(rgb_result)
%     imwrite(bw_result,[dir 'bw_result' num2str(img_index) '.tif']);
%     imwrite(rgb_result,[dir 'rgb_result' num2str(img_index) '.tif']);
%     % imwrite(show_img,[dir 'edge_class' num2str(img_index) '.jpg']);
%     % figure;imshow(show_img)
end