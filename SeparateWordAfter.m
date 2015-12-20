function [location_patch,index_each_patch] = SeparateWordAfter(cpoint_cell, index_chain)
num_character = length(index_chain);
right = zeros(1,num_character);
left = zeros(1,num_character);
top = zeros(1,num_character);
bottom = zeros(1,num_character);
for i=1:num_character
    location_x = cpoint_cell{index_chain(i)}(:,2);
    location_y = cpoint_cell{index_chain(i)}(:,1);
    right(i)= max(location_x);
    left(i)= min(location_x);
    bottom(i)= max(location_y);
    top(i)= min(location_y);
end
height = max(bottom) - min(top) + 1;
[left,position] = sort(left);
right = right(position);
top = top(position);
bottom = bottom(position);
disv=left(2:end)-right(1:end-1);
meand = median(disv);
stdd = std(disv);
p = 1;
T = meand*3/2+p*stdd;
% stdd = std(disv(disv<T));
% T = meand+1.6*stdd;
point_seg = find(disv>T&disv/height>1/8);
num_patch = length(point_seg)+1;
point_seg = [0 point_seg num_character];

index_each_patch = cell(1,num_patch);
for i = 1:num_patch
    position_vec = position((point_seg(i)+1):point_seg(i+1));
    index_each_patch{i} = index_chain(position_vec);
end
location_patch = zeros(num_patch,4);
for i = 1:num_patch
    start_point = point_seg(i)+1;
    end_point = point_seg(i+1); 
    left_patch = left(start_point);
    right_patch = right(end_point);
    top_patch = min(top(start_point:end_point));
    bottom_patch = max(bottom(start_point:end_point));
    location_patch(i,:) = [left_patch,top_patch,right_patch,bottom_patch];
end

end