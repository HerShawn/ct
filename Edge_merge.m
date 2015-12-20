function [cpoint_cell,new_corresp,color_edge] = Edge_merge(bw_img,neighbor_img,cpoint_cell,cluster_label_big,color_hsi,color_rgb,color_pro,Debug,IsSave,savename,img_value)
%% 对边缘按照像素的个数进行排序
if nargin == 8
    IsSave = 0;
end
num_bw = max(bw_img(:));
[h,w] = size(bw_img);
num_edge_v = zeros(1,num_bw);    %每个边缘的点个数
for m = 1:h
    for n = 1:w
        if (bw_img(m,n))
            num_edge_v(bw_img(m,n)) = num_edge_v(bw_img(m,n))+1;
        end
    end
end
[~,index_edge] = sort(num_edge_v,'descend');
%% 查找需要合并的边缘
new_corresp = 1:num_bw;   % 原边缘和新边缘的对应关系
while (~isempty(index_edge))
    index_point = index_edge(1);  % 处理的边缘索引
    %     disp(index_point)
    if index_point == 818
    end
    index_point = new_corresp(index_point);
    index_edge = index_edge(2:end);
    while (1)
        index_point_tabel = find(new_corresp == index_point);
        neighbor_v = [];
        for m = 1:length(index_point_tabel)
            neighbor_v = [neighbor_v neighbor_img{index_point_tabel(m)}];
        end
        neighbor_v = unique(new_corresp(neighbor_v));
        neighbor_v = neighbor_v(neighbor_v~=index_point);
        
        num_neighbor = length(neighbor_v);
        if ~num_neighbor
            break
        end
        %% 判断笔画是正方向还是负方向
        [mean_d,~,~,v1] = Stroke_attribute(cpoint_cell{index_point});
        num_point_start = size(cpoint_cell{index_point},1);
        %% 邻域之间是否合并的判断
        merge_flag = zeros(1,num_neighbor);
        for k = 1:num_neighbor
            index_neighbor = neighbor_v(k);
            num_point = size(cpoint_cell{index_neighbor},1);
            if (num_point>num_point_start)
                continue
            end
            th_color = 0.2;
            th_color2 = 35/255;
            th_stroke = 0.15;
            stroke_op = mean_d;
            [stroke_pp, ~, ~, v2] = Stroke_attribute(cpoint_cell{index_neighbor});
            color_diff_p1 = abs(color_hsi(index_point,1)-color_hsi(index_neighbor,1))+abs(color_hsi(index_point,2)-color_hsi(index_neighbor,2));
            color_diff_p3 = abs(color_rgb(index_point,1)-color_rgb(index_neighbor,1))+abs(color_rgb(index_point,2)-color_rgb(index_neighbor,2))+abs(color_rgb(index_point,3)-color_rgb(index_neighbor,3));
            color_diff_p2 = abs(color_rgb(index_point,1)-color_rgb(index_neighbor,1))<th_color2&&abs(color_rgb(index_point,2)-color_rgb(index_neighbor,2))<th_color2&&abs(color_rgb(index_point,3)-color_rgb(index_neighbor,3))<th_color2;
%             color_diff_p4 = sum((color_pro(index_point,:)-color_pro(index_neighbor,:)).^2)<0.2;
            stroke_diffp = abs(stroke_op-stroke_pp)/stroke_op*(1-exp(-(stroke_op+2)/20));
            if (((color_diff_p1<th_color)&&(color_diff_p3)<0.8)||color_diff_p2)||((stroke_diffp<th_stroke)&&v2>0.8&&v1>0.8)
%             if color_diff_p4||((stroke_diffp<th_stroke)&&v2>0.8&&v1>0.8)
                merge_flag(k) = 1;
                continue;
            end
        end
        if (~sum(merge_flag))
            break
        end
        for k = 1:num_neighbor
            %% 如果合并
            if (merge_flag(k))
                index_neighbor = neighbor_v(k);
                equel_xx = find(new_corresp == index_neighbor);
                for m = 1:length(equel_xx)
                    index_edge(index_edge == equel_xx(m)) = [];
                end
                [cpoint_cell,color_hsi,color_rgb,color_pro,new_corresp] = Merge_Two_edge(cpoint_cell,color_hsi,color_rgb,color_pro,new_corresp,index_point,index_neighbor);
                index_point = index_point - (index_point>index_neighbor);
                neighbor_v(neighbor_v>index_neighbor) = neighbor_v(neighbor_v>index_neighbor) - 1;
            end
        end
    end
end
[cpoint_cell,new_corresp,color_hsi,color_rgb,color_pro] = Merge_Inter_Edge(cpoint_cell,color_hsi,color_rgb,color_pro,cluster_label_big,new_corresp);
% show_img = Show_merge(h,w,corresp_new,bw_img);
% result_bw = zeros(h,w);
% %% 判断是否进行合并
% for j = 1:num_bw
%     result_bw(bw_img == j) = new_corresp(j);
% end
%% 计算每个边缘颜色
color_edge = [color_hsi color_rgb];
if(Debug)
    bw_img = show_result(cpoint_cell,h,w);
%      figure;imshow(bw_img);title(3);
end
if IsSave
    bw_img = show_result(cpoint_cell,h,w);
    save([savename img_value '.mat'],'cpoint_cell','new_corresp','color_edge');
    imwrite(bw_img,[savename img_value '.tif']);
end
end

% function [cpoint_cell_p,cpoint_cell_n,path_p,path_n,new_corresp] = Merge_Inter_Edge(cpoint_cell_p,cpoint_cell_n,path_p,path_n,th_stroke_attr_high,cluster_label,new_corresp,h)
function [cpoint_new, corresp_new,color_hsi,color_rgb,color_pro] = Merge_Inter_Edge(cpoint_cell,color_hsi,color_rgb,color_pro,cluster_label,new_corresp)
%% 合并内部的边缘
num_edge = size(cpoint_cell,1);
flag_merge = zeros(1,num_edge);
[h,~] = size(cluster_label);
    for k = 1:num_edge
        
        y_location_p = cpoint_cell{k}(:,3);
        x_location_p = cpoint_cell{k}(:,4);
        index_point = y_location_p+(x_location_p-1)*h;
        index_point = index_point(index_point>0);
        label_point = cluster_label(index_point);
        label_point = new_corresp(label_point);
        label_point(label_point == k) = [];
        unique_label = unique(label_point);
        num_label = length(unique_label);
        num_label_v = zeros(1,num_label);
        for p = 1:num_label
            num_label_v(p) = sum(label_point == unique_label(p));
        end
        [num_max_label,index_max_label] = max(num_label_v);
        index_max_label = unique_label(index_max_label);   %对应点最多的标记
        
        x_location_ori = cpoint_cell{k}(:,2);
        y_location_ori = cpoint_cell{k}(:,1);
        top_ori = min(y_location_ori);
        bottom_ori = max(y_location_ori);
        left_ori = min(x_location_ori);
        right_ori = max(x_location_ori);
        height_ori = bottom_ori-top_ori+1;
        width_ori = right_ori-left_ori+1;
        if isempty(num_max_label)
            continue
        end
        x_location_des = cpoint_cell{index_max_label}(:,2);
        y_location_des = cpoint_cell{index_max_label}(:,1);
        top_des = min(y_location_des);
        bottom_des = max(y_location_des);
        left_des = min(x_location_des);
        right_des = max(x_location_des);
        height_des = bottom_des-top_des+1;
        width_des = right_des-left_des+1;
        
        location_cc = [left_ori, top_ori, right_ori, bottom_ori, height_ori, width_ori;...
            left_des, top_des, right_des, bottom_des, height_des, width_des];
        flag_position = IsOverlaped(location_cc);
        th_color = 0.2;
        th_color2 = 35/255;
        color_diff_p1 = (abs(color_hsi(k,1)-color_hsi(index_max_label,1))+abs(color_hsi(k,2)-color_hsi(index_max_label,2)))<th_color;
        color_diff_p2 = abs(color_rgb(k,1)-color_rgb(index_max_label,1))<th_color2&&abs(color_rgb(k,2)-color_rgb(index_max_label,2))<th_color2&&abs(color_rgb(k,3)-color_rgb(index_max_label,3))<th_color2;
        if (num_max_label/length(y_location_p))>0.6&&flag_position&&color_diff_p1&&color_diff_p2
            flag_merge(k) = index_max_label;
        end
    end
%% 根据计算结果合并内部块
[cpoint_new,corresp_new,color_hsi,color_rgb,color_pro] = Merge_Multiple_edge(cpoint_cell,new_corresp,flag_merge,color_hsi,color_rgb,color_pro);
end
function flag = IsOverlaped(location_cc)
rect1 = location_cc(1,:);
rect2 = location_cc(2,:);
% th = 0.5;
flag1 = (rect1(1)<=rect2(3)&&rect1(1)>=rect2(1)) || (rect1(3)>=rect2(1)&&rect1(3)<=rect2(3));
flag2 = (rect1(2)<=rect2(4)&&rect1(2)>=rect2(2)) || (rect1(4)>=rect2(2)&&rect1(4)<=rect2(4));
flag = flag1&&flag2;
end
%% 合并两个边缘
function [cpoint_cell,color_hsi,color_rgb,color_pro,new_corresp] = Merge_Two_edge(cpoint_cell,color_hsi,color_rgb,color_pro,new_corresp,index_point,index_neighbor)
new_corresp(new_corresp == index_neighbor) = index_point;
new_corresp(new_corresp>index_neighbor) = new_corresp(new_corresp>index_neighbor)-1;
n1 = length(cpoint_cell{index_point});
n2 = length(cpoint_cell{index_neighbor});
cpoint_cell{index_point} = [cpoint_cell{index_point};cpoint_cell{index_neighbor}];
cpoint_cell(index_neighbor) = [];
color_hsi(index_point,:) = (color_hsi(index_point,:)*n1+color_hsi(index_neighbor,:)*n2)/(n1+n2);
color_hsi(index_neighbor,:) = [];
color_rgb(index_point,:) = (color_rgb(index_point,:)*n1+color_rgb(index_neighbor,:)*n2)/(n1+n2);
color_rgb(index_neighbor,:) = [];
color_pro(index_point,:) = (color_pro(index_point,:)*n1+color_pro(index_neighbor,:)*n2)/(n1+n2);
color_pro(index_neighbor,:) = [];
% value = new_corresp(end);
end


function [cell_vec,flag]= find_merge_block(flag_merge)
k = 0;
cell_vec = {};
num_edge = length(flag_merge);
flag = zeros(1,num_edge);
for i = 1:num_edge
    if flag_merge(i)
        k = k+1;
        vec = [i flag_merge(i)];
        length_vec = 0;
        while(length_vec ~= length(vec))
            length_vec = length(vec);
            for p = 1:length(vec)
                vec = [vec find(flag_merge == vec(p))];
            end
            vec = [vec flag_merge(vec)];
            vec = vec(vec~=0);
            vec = unique(vec);
        end
        flag_merge(vec) = 0;
        cell_vec{k} = vec;
    end
end
for i = 1:k
    num_cc = length(cell_vec{i});
    for j = 1:num_cc
        flag(cell_vec{i}(j)) = i;
    end
end
end

function [cpoint_new, corresp_new,color_hsi_new,color_rgb_new,color_pro_new] = Merge_Multiple_edge(cpoint_cell,new_corresp,flag_merge,color_hsi,color_rgb,color_pro)
[cell_vec,flag]= find_merge_block(flag_merge);
p = 0;
num_edge = length(flag);
flag_tackle = zeros(1,num_edge);
num_edge_merge = sum(~flag)+length(cell_vec);
cpoint_new = cell(num_edge_merge,1);
corresp_new = cell(num_edge_merge,1);
color_hsi_new = zeros(num_edge_merge,3);
color_rgb_new = zeros(num_edge_merge,3);
color_pro_new = zeros(num_edge_merge,size(color_pro,2));
for i = 1:num_edge
    if (~flag(i))
        p = p+1;
        cpoint_new{p} = cpoint_cell{i};
        corresp_new{p} = find(new_corresp == i);
        color_hsi_new(p,:) = color_hsi(i,:);
        color_rgb_new(p,:) = color_rgb(i,:);
        color_pro_new(p,:) = color_pro(i,:);
        flag_tackle(i) = 1;
    elseif flag(i)&&(~flag_tackle(i))
        p = p+1;
        vec = cell_vec{flag(i)};
        flag_tackle(vec) = 1;
        num_cc = length(vec);
        for j = 1:num_cc
            n1 = size(cpoint_new{p},1);
            n2 = size(cpoint_cell{vec(j)},1);
            cpoint_new{p} = [cpoint_new{p};cpoint_cell{vec(j)}];
            corresp_new{p} = [corresp_new{p} find(new_corresp == vec(j))];
            color_hsi_new(p,:) = (color_hsi_new(p,:)*n1+color_hsi(vec(j),:)*n2)/(n1+n2);
            color_rgb_new(p,:) = (color_rgb_new(p,:)*n1+color_rgb(vec(j),:)*n2)/(n1+n2);
            color_pro_new(p,:) = (color_pro_new(p,:)*n1+color_pro(vec(j),:)*n2)/(n1+n2);
        end
    end
end
end