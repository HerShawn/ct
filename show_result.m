function [show_img,gray_img] = show_result(cpoint_cell_p,h,w,flag_edge)
% show_img = zeros(h,w,3);
show_img = ones(h,w,3);
gray_img = zeros(h,w);
if nargin > 3
    for i = 1:length(flag_edge)
        if flag_edge(i)
            color_v = rand(1,3);
            for k = 1:size(cpoint_cell_p{i},1)
                show_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2),1) = color_v(1);
                show_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2),2) = color_v(2);
                show_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2),3) = color_v(3);
            end
        end
    end
else
    for i = 1:length(cpoint_cell_p)
        color_v = rand(1,3);
        for k = 1:size(cpoint_cell_p{i},1)
            show_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2),1) = color_v(1);
            show_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2),2) = color_v(2);
            show_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2),3) = color_v(3);
            gray_img(cpoint_cell_p{i}(k,1),cpoint_cell_p{i}(k,2)) = i;
        end
    end
end
% figure;imshow(gray_img)
end