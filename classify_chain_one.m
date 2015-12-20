function [flag_character location feature_all] = classify_chain_one(cpoint_cell,color_edge, img, feature_vector, flag_chain, model)
% [~,~,flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge);
% [~,~,~,feature_vector] = Delete_noncharadter_edge(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,h);
num_character = length(cpoint_cell);
flag_character = zeros(1,num_character);
location = [];
[~,votes] = classRF_predict(feature_vector([1 5:10],:)',model);
probability = votes(:,1)./sum(votes,2);
feature_all = [];
for i = 1:num_character
    location_x = cpoint_cell{i}(:,2);
    location_y = cpoint_cell{i}(:,1);
    top = min(location_y);
    bottom = max(location_y);
    left = min(location_x);
    right = max(location_x);
    if probability(i)<0.5&&~flag_chain(i)
        sub_img = img(top:bottom,left:right,:);
        bw_img = Get_ccEdge(sub_img,color_edge(i,4:6));
        
        
        
        location = [location;left top right bottom];
        feature_all = [feature_all feature_vector(:,i)];
    end
end
end
