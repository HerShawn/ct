% function [flag_character location] = show_two_chain(cpoint_cell_p,cpoint_cell_n,img,img_hsi,color_edge, feature_vector, flag_chain, model)
% [~,votes] = classRF_predict(feature_vector([1 5:10],:)',model);
% probability = votes(:,1)./sum(votes,2);
% num_character = length(cpoint_cell_p);
% left = zeros(1,num_character);
% right = zeros(1,num_character);
% top = zeros(1,num_character);
% bottom = zeros(1,num_character);
% for i = 1:num_character
%     location_x = cpoint_cell_p{i}(:,2);
%     location_y = cpoint_cell_p{i}(:,1);
%     top(i) = min(location_y);
%     bottom(i) = max(location_y);
%     left(i) = min(location_x);
%     right(i) = max(location_x);
% end
% num_chain = max(flag_chain); 
% flag_character = zeros(1,num_character);
% location = [];
% for i = 1:num_chain
%     index_chain = flag_chain == i;
%     chain_probability = mean(probability(index_chain));
%     if chain_probability<0.5&&(sum(index_chain)==2)
%         left_chain = min(left(index_chain));
%         right_chain = max(right(index_chain));
%         top_chain = min(top(index_chain));
%         bottom_chain = max(bottom(index_chain));
%         location = [location;left_chain top_chain right_chain bottom_chain];
%         flag_character(index_chain) = 1;
%     end
% end
% end
function [location,flag_character] = show_two_chain(cpoint_cell, feature_vector, flag_chain, model)
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
flag_character = zeros(1,num_character);
location = [];

for i = 1:num_chain
    index_chain = flag_chain == i;
    chain_probability = mean(probability(index_chain));
    if chain_probability<0.5&&(sum(index_chain)==2)
        left_chain = min(left(index_chain));
        right_chain = max(right(index_chain));
        top_chain = min(top(index_chain));
        bottom_chain = max(bottom(index_chain));
        location = [location;left_chain top_chain right_chain bottom_chain];
        flag_character(index_chain) = 1;
    end
end
% dim = 10;
% feature_cc = zeros(sum(flag_character),dim);
% k = 0;
% for i = 1:num_character
%     if flag_character(i)
%         k = k+1;
%         feature_cc(k) = [feature_vector(:,i)' left(i) top(i) right(i) bottom(i) distance_chain(i) height_chain(i)];
%     end
% end
end
