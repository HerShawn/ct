function FromEdgeCC(img,flag_character, cpoint_cell, color_edge)
[h,w,~] = size(img);
num_cc = length(flag_character);
bw_label = zeros(h,w);
for i = 1:num_cc
    if flag_character(i)
        location_x = cpoint_cell{i}(:,2);
        location_y = cpoint_cell{i}(:,1);
        top = min(location_y);
        bottom = max(location_y);
        left = min(location_x);
        right = max(location_x);
        sub_img = img(top:bottom,left:right,:);
        bw_label_sub = Get_ccEdge(sub_img,color_edge(i,4:6));
        bw_label(top:bottom,left:right) = bw_label_sub;
    end
end
figure;imshow(bw_label)
end