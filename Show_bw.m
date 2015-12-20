function bw_img = Show_bw(cpoint_cell,h,w,flag_cc)
bw_img = zeros(h,w);
num_edge = size(cpoint_cell,1);
if nargin<4
    for i = 1:num_edge
        x_location = cpoint_cell{i}(:,2);
        y_location = cpoint_cell{i}(:,1);
        bw_img((x_location-1)*h+y_location) = i;
    end
else
    k = 0;
    for i = 1:num_edge
        if flag_cc(i)
            k = k+1;
            x_location = cpoint_cell{i}(:,2);
            y_location = cpoint_cell{i}(:,1);
            bw_img((x_location-1)*h+y_location) = k;
        end
    end
end
%     figure;imshow(bw_img)
end