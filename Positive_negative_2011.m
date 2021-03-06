function [flag_pn] = Positive_negative_2011(cpoint_cell,imgprop)
num_character = size(cpoint_cell,1);
imgword = imgprop.location;
num_word = length(imgword);
location_gt = zeros(num_word,6);
for i = 1:num_word
    location_gt(i,:) = [imgword(i).left imgword(i).top imgword(i).right imgword(i).bottom imgword(i).w imgword(i).h];
end
flag_pn = zeros(1,num_character);
for i = 1:num_character
    x_location = cpoint_cell{i}(:,2);
    y_location = cpoint_cell{i}(:,1);
    top_cc = min(y_location);
    bottom_cc = max(y_location);
    left_cc = min(x_location);
    right_cc = max(x_location);
    height_cc = bottom_cc-top_cc+1;
    for j = 1:num_word
        vertical_flag = ~(top_cc>location_gt(j,4)||bottom_cc<location_gt(j,2));
        horizontal_flag = ~(left_cc>location_gt(j,3)||right_cc<location_gt(j,1));
        height_flag = height_cc/location_gt(j,6)<1.2&&height_cc/location_gt(j,6)>0.4;
        if vertical_flag&&horizontal_flag&&height_flag
            flag_pn(i) = 1;
            break
        end
    end
end
end