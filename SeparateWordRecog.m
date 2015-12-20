function [flag] = SeparateWordRecog(location)
num_character = size(location,1);
right = zeros(1,num_character);
left = zeros(1,num_character);
top = zeros(1,num_character);
bottom = zeros(1,num_character);
for i=1:num_character
    right(i)= location(i,3);
    left(i)= location(i,1);
    bottom(i)= location(i,4);
    top(i)= location(i,2);
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
flag = zeros(1,num_character);
for i = 1:num_character
    for j = 1:num_patch
        if (left(i)<=location_patch(j,3) && left(i)>=location_patch(j,1))
            flag(i) = j;
            continue;
        end
    end
end

[~,position2] = sort(position);
flag = flag(position2);
end