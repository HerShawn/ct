function [location_patch,bw_feature] = Word_seg(img,img_hsi,location,color_character_min,color_character_max,location_two_character)
if nargin == 5
    bw_feature = [];
    left = location(1);
    top = location(2);
    right = location(3);
    bottom = location(4);
    img = im2double(img);
    sub_img = img(top:bottom,left:right,:);
    sub_hsi = img_hsi(top:bottom,left:right,:);
    h = bottom - top + 1;
    w = right - left + 1;
    bw_img = Niblack(sub_img);
    num_point = zeros(1,2);
    th_color = 35/255;
    for direction = 1:2
        [bw_label,num_cc] = bwlabel(bw_img == (direction-1)*255,8);
        color_cc = zeros(num_cc,6);
        weight_cc = zeros(num_cc,1);
        for i = 1:h
            for j = 1:w
                value_label = bw_label(i,j);
                if (value_label)
                    if value_label == 1
                    end
                    weight_cc(value_label) = weight_cc(value_label) + 1;
                    color_point = [sub_hsi(i,j,1) sub_hsi(i,j,2) sub_hsi(i,j,3) sub_img(i,j,1) sub_img(i,j,2) sub_img(i,j,3)];
                    color_cc(value_label,:) = color_cc(value_label,:) + color_point;
                end
            end
        end
        color_cc = color_cc./(repmat(weight_cc,[1 6])+eps);
        IMcclab = regionprops(bw_label,'BoundingBox');
        for i = 1:num_cc
            %         if i == 138
            %         end
            %         flag_color1 = abs(color_cc(i,1) - color_character(1))<th_color&&abs(color_cc(i,2) - color_character(2))<th_color;
            %         flag_color2 = abs(color_cc(i,4) - color_character(4))<th_color&&abs(color_cc(i,5) - color_character(5))<th_color&&abs(color_cc(i,6) - color_character(6))<th_color;
            %         flag_color = flag_color1||flag_color2;
            %         flag_color = (abs(color_cc(i,4) - color_character(4))+abs(color_cc(i,5) - color_character(5))+abs(color_cc(i,6) - color_character(6)))<0.25;
            flag_color = Judge_color(color_cc(i,4:6),color_character_min(4:6),color_character_max(4:6),0.1);
            left_cc = IMcclab(i).BoundingBox(1,1);
            right_cc = IMcclab(i).BoundingBox(1,1)+IMcclab(i).BoundingBox(1,3);
            top_cc = IMcclab(i).BoundingBox(1,2);
            bottom_cc = IMcclab(i).BoundingBox(1,2)+IMcclab(i).BoundingBox(1,4);
            flag_position = (IMcclab(i).BoundingBox(1,4)>h/5&&bottom_cc/h>0.8)||IMcclab(i).BoundingBox(1,4)>h/3;
            if flag_color&&flag_position
            else
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
    IMcclab = regionprops(bw_label,'BoundingBox');
    rightcc=zeros(1,num_cc);
    leftcc=zeros(1,num_cc);
    for i=1:num_cc
        rightcc(i)=IMcclab(i).BoundingBox(1,1)+IMcclab(i).BoundingBox(1,3);
        leftcc(i)=IMcclab(i).BoundingBox(1,1);
    end
    % x1=sort(rightcc);
    % x2=sort(leftcc);
    disv=leftcc(2:end)-rightcc(1:end-1);
    meand = mean(disv);
    stdd = std(disv);
    p = 1.6;
    T = meand+p*stdd;
    flag_seg = disv>T;
    num_patch = sum(flag_seg)+1;
    location_patch = zeros(num_patch,4);
    point_seg = find(flag_seg);
    point_seg = [0 point_seg num_cc];
    % if num_patch == 1
    %     location_patch(i,:) = location;
    % else
    for i = 1:num_patch
        left_patch = leftcc(point_seg(i)+1)+0.5;
        right_patch = rightcc(point_seg(i+1))-0.5;
        [x_l,~] = find(bw_label(:,left_patch:right_patch));
        top_patch = min(x_l);
        bottom_patch = max(x_l);
        location_patch(i,:) = [left_patch+left-1,top_patch+top-1,right_patch+left-1,bottom_patch+top-1];
    end
else
    location_patch = [];
    bw_feature = zeros(8,2);
    left = location(1);
    top = location(2);
    right = location(3);
    bottom = location(4);
    img = im2double(img);
    sub_img = img(top:bottom,left:right,:);
    sub_hsi = img_hsi(top:bottom,left:right,:);
    h = bottom - top + 1;
    w = right - left + 1;
    bw_img = Niblack(sub_img);
    num_point = zeros(1,2);
    th_color = 35/255;
    for direction = 1:2
        [bw_label,num_cc] = bwlabel(bw_img == (direction-1)*255,8);
        color_cc = zeros(num_cc,6);
        weight_cc = zeros(num_cc,1);
        for i = 1:h
            for j = 1:w
                value_label = bw_label(i,j);
                if (value_label)
                    if value_label == 1
                    end
                    weight_cc(value_label) = weight_cc(value_label) + 1;
                    color_point = [sub_hsi(i,j,1) sub_hsi(i,j,2) sub_hsi(i,j,3) sub_img(i,j,1) sub_img(i,j,2) sub_img(i,j,3)];
                    color_cc(value_label,:) = color_cc(value_label,:) + color_point;
                end
            end
        end
        color_cc = color_cc./(repmat(weight_cc,[1 6])+eps);
        IMcclab = regionprops(bw_label,'BoundingBox');
        for i = 1:num_cc
            flag_color = Judge_color(color_cc(i,4:6),color_character_min(4:6),color_character_max(4:6),0.1);
            left_cc = IMcclab(i).BoundingBox(1,1);
            right_cc = IMcclab(i).BoundingBox(1,1)+IMcclab(i).BoundingBox(1,3);
            top_cc = IMcclab(i).BoundingBox(1,2);
            bottom_cc = IMcclab(i).BoundingBox(1,2)+IMcclab(i).BoundingBox(1,4);
            flag_position = (IMcclab(i).BoundingBox(1,4)>h/5&&bottom_cc/h>0.8)||IMcclab(i).BoundingBox(1,4)>h/3;
            if flag_color&&flag_position
            else
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
    IMcclab = regionprops(bw_label,'All');
    flag_index = zeros(1,2);
    for i = 1:2
        num_index = zeros(1,num_cc);
        for m = (location_two_character(i,2)-top+1):(location_two_character(i,4)-top+1)
            for n = (location_two_character(i,1)-left+1):(location_two_character(i,3)-left+1)
                value_label = bw_label(m,n);
                if value_label
                    num_index(value_label) = num_index(value_label) + 1;
                end
            end
        end
        [~,flag_index(i)] = max(num_index);
    end
    for i = 1:2
        l = flag_index(i);
        bw_feature(1,i) = IMcclab(l).Extent;
        bw_feature(2,i) = sum(sum(IMcclab(l).Image-imopen(IMcclab(l).Image,[1,1;1,1])))/IMcclab(l).Area;
        bw_feature(3,i) = IMcclab(l).Area/(((IMcclab(l).Perimeter)*(IMcclab(l).Perimeter))+realmin);
        bw_feature(4,i) = IMcclab(l).EulerNumber;
        bw_feature(5,i) = (IMcclab(l).ConvexArea-IMcclab(l).Area)/IMcclab(l).Area;
        bw_feature(6,i) = (sum(sum(IMcclab(l).FilledImage))-IMcclab(l).Area)/IMcclab(l).Area;
        bw_feature(7,i) = IMcclab(l).MinorAxisLength/(bottom-top+1);
        bw_feature(8,i) = IMcclab(l).Area/((location_two_character(i,3)-location_two_character(i,1)+1)*(location_two_character(i,4)-location_two_character(i,2)+1));
    end
end
end
function flag = Judge_color(color_cc,color_character_min,color_character_max,th_color)
num_color = length(color_cc);
flag = 1;
for i = 1:num_color
    flag = flag&&(color_cc(i)>color_character_min(i)-th_color)&&(color_cc(i)<color_character_max(i)+th_color);
end
end