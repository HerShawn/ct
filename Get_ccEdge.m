function [location_patch] = Get_ccEdge(sub_img,sub_hsi,color_character_min,color_character_max)
[h,w,~] = size(sub_img);
bw_img = Niblack(sub_img);
num_point = zeros(1,2);
for direction = 1:2
    [bw_label,num_cc] = bwlabel(bw_img == (direction-1)*255,8);
    color_cc = zeros(num_cc,6);
    weight_cc = zeros(num_cc,1);
    for i = 1:h
        for j = 1:w
            value_label = bw_label(i,j);
            if (value_label)
                weight_cc(value_label) = weight_cc(value_label) + 1;
                color_point = [sub_hsi(i,j,1) sub_hsi(i,j,2) sub_hsi(i,j,3) sub_img(i,j,1) sub_img(i,j,2) sub_img(i,j,3)];
                color_cc(value_label,:) = color_cc(value_label,:) + color_point;
            end
        end
    end
    color_cc = color_cc./(repmat(weight_cc,[1 6])+eps);
    IMcclab = regionprops(bw_label,'BoundingBox');
    for i = 1:num_cc
        flag_color = Judge_color(color_cc(i,4:6),color_character_min(4:6),color_character_max(4:6),0.15);
%         bottom_cc = IMcclab(i).BoundingBox(1,2)+IMcclab(i).BoundingBox(1,4);
%         flag_position = (IMcclab(i).BoundingBox(1,4)>h/5&&bottom_cc/h>0.8)||IMcclab(i).BoundingBox(1,4)>h/3;
        flag_position = IMcclab(i).BoundingBox(1,4)>h/9;
        if ~(flag_color&&flag_position)
            bw_label(bw_label == i) = 0;
        end
    end
    if direction == 1
        [bw_label1, num_cc1] = bwlabel(bw_label,8);
    else
        [bw_label2, num_cc2] = bwlabel(bw_label,8);
    end
    num_point(direction) = sum(sum(bw_label~=0));
end
if num_point(1)>num_point(end)
    bw_label = bw_label1;
    num_cc = num_cc1;
else
    bw_label = bw_label2;
    num_cc = num_cc2;
end
if num_cc == 0
    location_patch = [];
    return;
end
%% 合并上下结构
[~, ~, location_patch] = MergeTopBottom(bw_label);
end

function flag = Judge_color(color_cc,color_character_min,color_character_max,th_color)
num_color = length(color_cc);
flag = 1;
for i = 1:num_color
    flag = flag&&(color_cc(i)>color_character_min(i)-th_color)&&(color_cc(i)<color_character_max(i)+th_color);
end
end

% function  bw_label = Get_ccEdge(img,color)
% [h,w,~] = size(img);
% bw_img = Niblack(img);
% for direction = 1:2
%     [bw_label,num_cc] = bwlabel(bw_img == (direction-1)*255,8);
%     IMcclab  = regionprops(bw_label, 'BoundingBox');
%     for i = 1:num_cc
%         if (IMcclab(i).BoundingBox(1,4)<h/8)
%             bw_label(bw_label == i) = 0;
%         end
%     end
%     [bw_label,num_cc] = bwlabel(bw_label,8);
%     color_cc = zeros(num_cc,3);
%     weight_cc = zeros(num_cc,1);
%     for m = 1:h
%         for n = 1:w
%             value_label = bw_label(m,n);
%             if (value_label)
%                 weight_cc(value_label) = weight_cc(value_label) + 1;
%                 color_point = [img(m,n,1) img(m,n,2) img(m,n,3)];
%                 color_cc(value_label,:) = color_cc(value_label,:) + color_point;
%             end
%         end
%     end
%     color_cc = color_cc./(repmat(weight_cc,[1 3])+eps);
%     IMcclab = regionprops(bw_label,'BoundingBox');
%     value_vec = zeros(1,num_cc);
%     for p = 1:num_cc
%         color_value = sum(abs(color - color_cc(p,:)));
%         size_value = 2*(1 - IMcclab(p).BoundingBox(1,4)/h*IMcclab(p).BoundingBox(1,3)/w);
%         value_vec(p) = color_value + size_value;
%     end
%     if direction == 1
%         [value1, index1] = min(value_vec);
%         bw_label1 = bwlabel(bw_label == index1,8);
%     else
%         [value2, index2] = min(value_vec);
%         bw_label2 = bwlabel(bw_label == index2,8);
%     end
% end
% if value1<value2
%     bw_label = bw_label1;
% else
%     bw_label = bw_label2;
% end
% end

