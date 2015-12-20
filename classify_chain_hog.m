function [location1 location2] = classify_chain_hog(cpoint_cell,color_edge, img, feature_vector, flag_chain, model, RLearners, RWeights)
% [~,~,flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge);
% [~,~,~,feature_vector] = Delete_noncharadter_edge(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,h);
[~,votes] = classRF_predict(feature_vector([1 5:10],:)',model);
probability = votes(:,1)./sum(votes,2);
num_character = length(cpoint_cell);
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
end
num_chain = max(flag_chain);

color_chain_min = ones(num_chain,6);
color_chain_max = zeros(num_chain,6);
% point_chain = zeros(num_chain,1);

for i = 1:num_character
    value_chain = flag_chain(i);
    if value_chain
        color_chain_min(value_chain,:) = min([color_edge(i,:);color_chain_min(value_chain,:)],[],1);
        color_chain_max(value_chain,:) = max([color_edge(i,:);color_chain_max(value_chain,:)],[],1);
    end
end


flag_character = zeros(1,num_character);
location1 = [];
location2 = [];
for i = 1:num_chain
    index_chain = flag_chain == i;
    chain_probability = mean(probability(index_chain));
    if chain_probability<0.5
        left_chain = min(left(index_chain));
        right_chain = max(right(index_chain));
        top_chain = min(top(index_chain));
        bottom_chain = max(bottom(index_chain));
        chain_location = [left_chain top_chain right_chain bottom_chain];
        sub_img = img(top_chain:bottom_chain,left_chain:right_chain,:);
        feature = Compute_HogFeature(sub_img);
        ResultR = Classify(RLearners, RWeights, feature');
        if ResultR>0
            flag_character(index_chain) = 1;
            location1 = [location1;chain_location];
        else
            flag_character(index_chain) = 2;
            location2 = [location2;chain_location];
        end
        %        location_patch = Word_seg(img,img_hsi,chain_location,color_chain_min(i,:),color_chain_max(i,:));
        %       location = [location;location_patch];       
%         flag_character(index_chain) = 1;
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