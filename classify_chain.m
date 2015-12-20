function [flag_character location] = classify_chain(cpoint_cell,color_edge, img, feature_vector, flag_chain, model, RLearners, RWeights)
% [~,~,flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge);
% [~,~,~,feature_vector] = Delete_noncharadter_edge(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,h);
num_character = length(cpoint_cell);
flag_character = zeros(1,num_character);
location = [];
[~,votes] = classRF_predict(feature_vector([1 5:10],:)',model);
probability = votes(:,1)./sum(votes,2);
left = zeros(1,num_character);
right = zeros(1,num_character);
top = zeros(1,num_character);
bottom = zeros(1,num_character);
for i = 1:num_character
    location_x = cpoint_cell{i}(:,2);
    location_y = cpoint_cell{i}(:,1);
    top(i) = min(location_y);
    bottom(i) = max(location_y);
    left(i) = min(location_x);
    right(i) = max(location_x);
    %     if probability(i)<0.5&&~flag_chain(i)
    %         location = [location;left(i) top(i) right(i) bottom(i)];
    %     end
end
num_chain = max(flag_chain);
% % % % color_chain_min = ones(num_chain,6);
% % % % color_chain_max = zeros(num_chain,6);
% % % % % point_chain = zeros(num_chain,1);
% % % % for i = 1:num_character
% % % %     value_chain = flag_chain(i);
% % % %     if value_chain
% % % %         color_chain_min(value_chain,:) = min([color_edge(i,:);color_chain_min(value_chain,:)],[],1);
% % % %         color_chain_max(value_chain,:) = max([color_edge(i,:);color_chain_max(value_chain,:)],[],1);
% % % %     end
% % % % end
% for i = 1:num_character
%     value_chain = flag_chain(i);
%     if value_chain
%         num_point = size(cpoint_cell_p{i},1);
%         color_chain(value_chain,:) = color_chain(value_chain,:) + color_edge(i,:)*num_point;
%         point_chain(value_chain) = point_chain(value_chain)+num_point;
%     end
% end
% color_chain = color_chain./(repmat(point_chain,[1 6])+eps);


for i = 1:num_chain
    index_chain = find(flag_chain == i);
    chain_probability = mean(probability(index_chain));
    left_chain = min(left(index_chain));
    right_chain = max(right(index_chain));
    top_chain = min(top(index_chain));
    bottom_chain = max(bottom(index_chain));
    height_chain = bottom_chain - top_chain + 1;
    width_chain = right_chain - left_chain + 1;
    
    if chain_probability<0.5
        bwSubImg = zeros(height_chain, width_chain);
        for j = 1:length(index_chain)
            location_x = cpoint_cell{index_chain(j)}(:,2) - left_chain + 1;
            location_y = cpoint_cell{index_chain(j)}(:,1) - top_chain + 1;
            bwSubImg((location_x-1)*height_chain + location_y) = 1;
        end
        regionProp = regionprops(bwSubImg,'Orientation');
        rotateBwImage = imrotate(bwSubImg,-regionProp.Orientation);
        [y_rotate, x_rotate] = find(rotateBwImage);
        left_rotate = min(x_rotate);
        top_rotate = min(y_rotate);
        right_rotate = max(x_rotate);
        bottom_rotate = max(y_rotate);
        sub_img = img(top_chain:bottom_chain,left_chain:right_chain,:);
        sub_img = imrotate(sub_img,-regionProp.Orientation);
        sub_img = sub_img(top_rotate:bottom_rotate,left_rotate:right_rotate,:);
        feature = Compute_HogFeature(sub_img);
        ResultR = Classify(RLearners, RWeights, feature');
%         figure;imshow(sub_img)
%         if ResultR<0
%             imwrite(sub_img,[num2str(round(rand(1,1)*10000)) '.tif']);
%         end
        if ResultR>0
            chain_location = [left_chain top_chain right_chain bottom_chain];
            location_patch = SeparateWordAfter(cpoint_cell, index_chain);
            location = [location;location_patch];
            %        location_patch = Word_seg(img,img_hsi,chain_location,color_chain_min(i,:),color_chain_max(i,:));
            %       location = [location;location_patch];
            %             location = [location;chain_location];
            flag_character(index_chain) = 1;
        else
            [location_patch,index_each_patch] = SeparateWordAfter(cpoint_cell, index_chain);
            num_patch = size(location_patch,1);
            location_tmp = [];
            classify_value = zeros(1,num_patch);
            for p = 1:num_patch
                index_word = index_each_patch{p};
                left_word = min(left(index_word));
                right_word = max(right(index_word));
                top_word = min(top(index_word));
                bottom_word = max(bottom(index_word));
                height_word = bottom_word - top_word + 1;
                width_word = right_word - left_word + 1;
                
                bwSubImg = zeros(height_word, width_word);
                for j = 1:length(index_word)
                    location_x = cpoint_cell{index_word(j)}(:,2) - left_word + 1;
                    location_y = cpoint_cell{index_word(j)}(:,1) - top_word + 1;
                    bwSubImg((location_x-1)*height_word + location_y) = 1;
                end
                regionProp = regionprops(bwSubImg,'Orientation');
                rotateBwImage = imrotate(bwSubImg,-regionProp.Orientation);
                [y_rotate, x_rotate] = find(rotateBwImage);
                left_rotate = min(x_rotate);
                top_rotate = min(y_rotate);
                right_rotate = max(x_rotate);
                bottom_rotate = max(y_rotate);
                sub_img = img(top_word:bottom_word,left_word:right_word,:);
                sub_img = imrotate(sub_img,-regionProp.Orientation);
                sub_img = sub_img(top_rotate:bottom_rotate,left_rotate:right_rotate,:);
                feature = Compute_HogFeature(sub_img);
                ResultR = Classify(RLearners, RWeights, feature');
                classify_value(p) = ResultR;
                location_tmp = [location_tmp;location_patch(p,:)];
            end
            if sum(classify_value>0)/num_patch>0.5
                location = [location; location_tmp];
                flag_character(index_chain) = 1;
            end
        end
    end
end
end
% function Compute_Color(cpoint_p, cpoint_n)
% num_edge = size(cpoint_n,1);
% color_edge = zeros(num_edge,6);
% for i = 1:num_edge
%     [mean_dp, ~, ~, ~] = Stroke_attribute(cpoint_p{i});
%     [mean_dn, ~, ~, ~] = Stroke_attribute(cpoint_n{i});
%     th_dp = mean_dp*5/3;
%     th_dn = mean_dn*5/3;
%     [color_edge(i,1) color_edge(i,2) color_edge(i,3)] = Mean_color(color_r,color_g,color_b,path_p_new,i,magGrad,lowThresh,th_dp,h);
%     [color_edge(i,4) color_edge(i,5) color_edge(i,6)] = Mean_color(color_r,color_g,color_b,path_n_new,i,magGrad,lowThresh,th_dn,h);
% end
% end