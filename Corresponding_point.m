function  [cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big,IsSave,parameterName)
%% 思路：可以根据当前点的梯度值 来自适应的计算方向射线上的梯度分布
%  cpoint 为输出的对应点关系矩阵 为m*n m为边缘点的个数 n分别为 1横坐标 2纵坐标 3所属的标定
%  4正对应点的横坐标 5纵坐标 6距离 7角度差 8负对应点的横坐标 9纵坐标 10距离 11角度差
if nargin == 4
    IsSave = 0;
end
% tic
num_point = sum(bw_img(:)~=0);
cpoint = zeros(num_point,11);
edge_img = bw_img~=0;
[h,w] = size(magGrad);
%% 标定每个点的方向
direction = ones(h,w)*(-1);
direction = direction + double((orientation<=1/4*pi&orientation>-pi/4));
direction = direction + 2*double((orientation<=3/4*pi&orientation>pi/4));
direction = direction + 3*double((orientation>3/4*pi)|(orientation<=-3/4*pi));
direction = direction + 4*double((orientation<=-1/4*pi&orientation>-3/4*pi));
max_swidth = min(h,w); % 最大的笔画宽度
% toc
%% 主循环 计算每个点的对应点
%% 第一次计算对应点
first_location = cell(num_point,10);
kk = 0;
for m = 1:h
    for n = 1:w
        if bw_img(m,n)
            kk = kk+1;
            %             tic
            % disp([m n])
            [cpointTmp,first_locationTmp] = Corresponding_point_First(magGrad,orientation,bw_img,cluster_label_big,direction,edge_img,m,n,max_swidth,h,w);
            cpoint(kk,:) = cpointTmp;
            first_location(kk,:) = first_locationTmp;
            %             toc
        end
    end
end
% toc
num_bw = max(bw_img(:));
cpoint_cell_p = cell(num_bw,1);
cpoint_cell_n = cell(num_bw,1);
y_location = cpoint(:,1);
x_location = cpoint(:,2);
cy_location_p = cpoint(:,4);
cx_location_p = cpoint(:,5);
cy_location_n = cpoint(:,8);
cx_location_n = cpoint(:,9);
zeros_index_p = cpoint(:,4) == 0|cpoint(:,5) == 0;
zeros_index_n = cpoint(:,8) == 0|cpoint(:,9) == 0;
distance_point_p = cpoint(:,6);
distance_point_n = cpoint(:,10);
orientation_diff_point_p = cpoint(:,7);
orientation_diff_point_n = cpoint(:,11);
for j = 1:num_bw
    k = cpoint(:,3) == j;
    index_p = find(k);
    cpoint_cell_p{j} = [y_location(k) x_location(k) cy_location_p(k) cx_location_p(k) distance_point_p(k) orientation_diff_point_p(k) zeros_index_p(k) index_p];
    cpoint_cell_n{j} = [y_location(k) x_location(k) cy_location_n(k) cx_location_n(k) distance_point_n(k) orientation_diff_point_n(k) zeros_index_n(k) index_p];
end
% toc
%% 根据第一次的结果 对最后结果进行修正
for j = 1:num_bw
    % 正样本点参数
    distance_p = cpoint_cell_p{j}(:,5);
    orientation_diff_p = cpoint_cell_p{j}(:,6);
    zeros_p = cpoint_cell_p{j}(:,7);
    index_p = cpoint_cell_p{j}(:,8);
    index_stroke_p = orientation_diff_p<pi/3&~zeros_p;
    meadian_distance = median(distance_p(index_stroke_p));
    for p = 1:length(distance_p)
        if ~zeros_p(p)
            k = index_p(p);
            y_location_vp = first_location{k,1};
            x_location_vp = first_location{k,2};
            grad_vp = first_location{k,3};
            distance_vp = first_location{k,4};
            orientation_diff_vp = first_location{k,5};
            dissimilarity_vp_new = exp(-orientation_diff_vp).*exp(-grad_vp).*exp(-3*abs(distance_vp-meadian_distance)/meadian_distance);
            [~,best_label] = max(dissimilarity_vp_new);
            % 结果记录
            cpoint(kk,4) = y_location_vp(best_label);
            cpoint(kk,5) = x_location_vp(best_label);
            cpoint(kk,6) = distance_vp(best_label);
            cpoint(kk,7) = orientation_diff_vp(best_label);
            cpoint_cell_p{j}(p,3) = y_location_vp(best_label);
            cpoint_cell_p{j}(p,4) = x_location_vp(best_label);
            cpoint_cell_p{j}(p,5) = distance_vp(best_label);
            cpoint_cell_p{j}(p,6) = orientation_diff_vp(best_label);
        end
    end
    % 负样本点参数
    distance_n = cpoint_cell_n{j}(:,5);
    orientation_diff_n = cpoint_cell_n{j}(:,6);
    zeros_n = cpoint_cell_n{j}(:,7);
    index_n = cpoint_cell_n{j}(:,8);
    index_stroke_n = orientation_diff_n<pi/3&~zeros_n;
    meadian_distance = median(distance_n(index_stroke_n));
    for p = 1:length(distance_n)
        if ~zeros_n(p)
            k = index_n(p);
            y_location_vn = first_location{k,6};
            x_location_vn = first_location{k,7};
            grad_vn = first_location{k,8};
            distance_vn = first_location{k,9};
            orientation_diff_vn = first_location{k,10};
            dissimilarity_vn_new = exp(-orientation_diff_vn).*exp(-grad_vn).*exp(-3*abs(distance_vn-meadian_distance)/meadian_distance);
            %             dissimilarity_vn_new = dissimilarity_vn.*exp(abs(distance_vn-meadian_distance)/meadian_distance);
            [~,best_label] = max(dissimilarity_vn_new);
            % 结果记录
            cpoint(kk,8) = y_location_vn(best_label);
            cpoint(kk,9) = x_location_vn(best_label);
            cpoint(kk,10) = distance_vn(best_label);
            cpoint(kk,11) = orientation_diff_vn(best_label);
            cpoint_cell_n{j}(p,3) = y_location_vn(best_label);
            cpoint_cell_n{j}(p,4) = x_location_vn(best_label);
            cpoint_cell_n{j}(p,5) = distance_vn(best_label);
            cpoint_cell_n{j}(p,6) = orientation_diff_vn(best_label);
        end
    end
end
% toc
% %% 路径记录
% path_p = cell(num_bw,1); % 正样本路径
% path_n = cell(num_bw,1); % 负样本路径
% for j = 1:num_bw
%     if j == 268
%     end
%     location_p = cpoint_cell_p{j}(:,[1,2,3,4]);
%     location_n = cpoint_cell_n{j}(:,[1,2,3,4]);
%     num_point = size(location_p,1);
%     %% 正样本
%     oy = location_p(:,1);
%     ox = location_p(:,2);
%     py = location_p(:,3);
%     px = location_p(:,4);
%     orientation = atan2(py-oy,px-ox);
%     direction = ones(num_point,1)*(-1);
%     direction = direction + double((orientation<=1/4*pi&orientation>-pi/4));
%     direction = direction + 2*double((orientation<=3/4*pi&orientation>pi/4));
%     direction = direction + 3*double((orientation>3/4*pi)|(orientation<=-3/4*pi));
%     direction = direction + 4*double((orientation<=-1/4*pi&orientation>-3/4*pi));
%     path_point = cell(num_point,2);
%     for k = 1:num_point
%         if (~px(k)||~py(k))
%             path_point{k,1} = [];
%             path_point{k,2} = [];
%             continue
%         end
%         switch direction(k)
%             case 0
%                 x_location = ox(k):px(k);                               % 列
%                 y_location = round(tan(orientation(k))*(x_location-ox(k))+oy(k));   % 行
%             case 1
%                 y_location = oy(k):py(k);
%                 x_location = round((y_location-oy(k))/tan(orientation(k))+ox(k));
%             case 2
%                 x_location = ox(k):-1:px(k);
%                 y_location = round(tan(orientation(k))*(x_location-ox(k))+oy(k));
%             case 3
%                 y_location = oy(k):-1:py(k);
%                 x_location = round((y_location-oy(k))/tan(orientation(k))+ox(k));
%         end
%         path_point{k,1} = y_location;
%         path_point{k,2} = x_location;
%     end
%     path_p{j} = path_point;
%     %% 负样本
%     oy = location_n(:,1);
%     ox = location_n(:,2);
%     py = location_n(:,3);
%     px = location_n(:,4);
%     orientation = atan2(py-oy,px-ox);
%     direction = ones(num_point,1)*(-1);
%     direction = direction + double((orientation<=1/4*pi&orientation>-pi/4));
%     direction = direction + 2*double((orientation<=3/4*pi&orientation>pi/4));
%     direction = direction + 3*double((orientation>3/4*pi)|(orientation<=-3/4*pi));
%     direction = direction + 4*double((orientation<=-1/4*pi&orientation>-3/4*pi));
%     path_point = cell(num_point,2);
%     for k = 1:num_point
%         if (~px(k)||~py(k))
%             path_point{k,1} = [];
%             path_point{k,2} = [];
%             continue
%         end
%         switch direction(k)
%             case 0
%                 x_location = ox(k):px(k);                               % 列
%                 y_location = round(tan(orientation(k))*(x_location-ox(k))+oy(k));   % 行
%             case 1
%                 y_location = oy(k):py(k);
%                 x_location = round((y_location-oy(k))/tan(orientation(k))+ox(k));
%             case 2
%                 x_location = ox(k):-1:px(k);
%                 y_location = round(tan(orientation(k))*(x_location-ox(k))+oy(k));
%             case 3
%                 y_location = oy(k):-1:py(k);
%                 x_location = round((y_location-oy(k))/tan(orientation(k))+ox(k));
%         end
%         path_point{k,1} = y_location;
%         path_point{k,2} = x_location;
%     end
%     path_n{j} = path_point;
% end

if IsSave
    save(parameterName,'cpoint_cell_p','cpoint_cell_n');
end
end

% function [cpoint,first_location] = Corresponding_point_First(cpoint,first_location,magGrad,orientation,bw_img,cluster_label_big,direction,edge_img,m,n,max_swidth,kk,h,w)
% cpoint(kk,1) = m;
% cpoint(kk,2) = n;
% cpoint(kk,3) = bw_img(m,n);
% orientation_p = orientation(m,n);
% direction_p = direction(m,n);
% for d_direction = 1:2                               %正负两个方向
%     direction_p = mod(direction_p+(d_direction-1)*2,4);
%     orientation_p = orientation_p+pi*(d_direction-1);
%     switch direction_p
%         case 0
%             x_d  = round(cos(orientation_p)*max_swidth);
%             x_location = n:min(n+x_d,w);                               % 列
%             y_location = round(tan(orientation_p)*(x_location-n)+m);   % 行
%             idx_location = find(y_location<=h&y_location>=1);
%             x_location = x_location(idx_location);
%             y_location = y_location(idx_location);
%         case 1
%             y_d  = round(sin(orientation_p)*max_swidth);
%             y_location = m:min(m+y_d,h);
%             x_location = round((y_location-m)/tan(orientation_p)+n);
%             idx_location = find(x_location<=w&x_location>=1);
%             x_location = x_location(idx_location);
%             y_location = y_location(idx_location);
%         case 2
%             x_d  = round(cos(orientation_p)*max_swidth);
%             x_location = n:-1:max(n+x_d,1);
%             y_location = round(tan(orientation_p)*(x_location-n)+m);
%             idx_location = find(y_location<=h&y_location>=1);
%             x_location = x_location(idx_location);
%             y_location = y_location(idx_location);
%         case 3
%             y_d  = round(sin(orientation_p)*max_swidth);
%             y_location = m:-1:max(m+y_d,1);
%             x_location = round((y_location-m)/tan(orientation_p)+n);
%             idx_location = find(x_location<=w & x_location>=1);
%             x_location = x_location(idx_location);
%             y_location = y_location(idx_location);
%     end
%     orientation_p = orientation_p-pi*(d_direction-1);
%     % 走过路径的标定
%     label_path = cluster_label_big((x_location-1)*h+y_location);
%     % 走过路径的梯度值
%     grad_path = magGrad((x_location-1)*h+y_location);
%     % 走过路径的方向值
%     orientation_path = orientation((x_location-1)*h+y_location);
%     edge_path = edge_img((x_location-1)*h+y_location);
%     %% 只计算梯度值大于阈值的点
%     [max_label_dis,norm_label] = Compute_ext(label_path,edge_path,grad_path);
%     num_label = length(max_label_dis);
%     orientation_diff = mod(abs(orientation_path(max_label_dis)-orientation_p-pi),2*pi);
%     orientation_diff = min(orientation_diff,2*pi-orientation_diff);
%     grad_diff = abs(grad_path(max_label_dis)-grad_path(1));
%     dissimilarity = exp(-orientation_diff).*exp(-norm_label(max_label_dis)+1).*exp(-grad_diff);
%
%     [~,best_label] = max(dissimilarity);
%     if num_label >= 1
%         cpoint(kk,4+(d_direction-1)*4) = y_location(max_label_dis(best_label));
%         cpoint(kk,5+(d_direction-1)*4) = x_location(max_label_dis(best_label));
%         cpoint(kk,6+(d_direction-1)*4) = sqrt((cpoint(kk,4+(d_direction-1)*4)-cpoint(kk,1))^2....
%             +(cpoint(kk,5+(d_direction-1)*4)-cpoint(kk,2))^2);
%         cpoint(kk,7+(d_direction-1)*4) = orientation_diff(best_label);
%         first_location{kk,1+(d_direction-1)*5} = y_location(max_label_dis);
%         first_location{kk,2+(d_direction-1)*5} = x_location(max_label_dis);
%         first_location{kk,3+(d_direction-1)*5} = grad_diff;
%         first_location{kk,4+(d_direction-1)*5} = sqrt((y_location(max_label_dis)-m).^2+(x_location(max_label_dis)-n).^2);
%         first_location{kk,5+(d_direction-1)*5} = orientation_diff;
%     end
% end
% end

function [cpoint,first_location] = Corresponding_point_First(magGrad,orientation,bw_img,cluster_label_big,direction,edge_img,m,n,max_swidth,h,w)
cpoint = zeros(1,11);
first_location = cell(1,10);
cpoint(1) = m;
cpoint(2) = n;
cpoint(3) = bw_img(m,n);
orientation_p = orientation(m,n);
direction_p = direction(m,n);
for d_direction = 1:2                               %正负两个方向
    direction_p = mod(direction_p+(d_direction-1)*2,4);
    orientation_p = orientation_p+pi*(d_direction-1);
    switch direction_p
        case 0
            x_d  = round(cos(orientation_p)*max_swidth);
            x_location = n:min(n+x_d,w);                               % 列
            y_location = round(tan(orientation_p)*(x_location-n)+m);   % 行
            idx_location = find(y_location<=h&y_location>=1);
            x_location = x_location(idx_location);
            y_location = y_location(idx_location);
        case 1
            y_d  = round(sin(orientation_p)*max_swidth);
            y_location = m:min(m+y_d,h);
            x_location = round((y_location-m)/tan(orientation_p)+n);
            idx_location = find(x_location<=w&x_location>=1);
            x_location = x_location(idx_location);
            y_location = y_location(idx_location);
        case 2
            x_d  = round(cos(orientation_p)*max_swidth);
            x_location = n:-1:max(n+x_d,1);
            y_location = round(tan(orientation_p)*(x_location-n)+m);
            idx_location = find(y_location<=h&y_location>=1);
            x_location = x_location(idx_location);
            y_location = y_location(idx_location);
        case 3
            y_d  = round(sin(orientation_p)*max_swidth);
            y_location = m:-1:max(m+y_d,1);
            x_location = round((y_location-m)/tan(orientation_p)+n);
            idx_location = find(x_location<=w & x_location>=1);
            x_location = x_location(idx_location);
            y_location = y_location(idx_location);
    end
    orientation_p = orientation_p-pi*(d_direction-1);
    % 走过路径的标定
    label_path = cluster_label_big((x_location-1)*h+y_location);
    % 走过路径的梯度值
    grad_path = magGrad((x_location-1)*h+y_location);
    % 走过路径的方向值
    orientation_path = orientation((x_location-1)*h+y_location);
    edge_path = edge_img((x_location-1)*h+y_location);
    %% 只计算梯度值大于阈值的点
    %     [max_label_dis,norm_label] = Compute_ext(label_path,edge_path,grad_path);
    edge_path(1) = 0;
    index_zero = edge_path==0;
    norm_label = cumsum(edge_path);
    norm_label(index_zero) = 0;
    max_label_dis = find(norm_label);
    num_label = length(max_label_dis);
    orientation_diff = mod(abs(orientation_path(max_label_dis)-orientation_p-pi),2*pi);
    orientation_diff = min(orientation_diff,2*pi-orientation_diff);
    grad_diff = abs(grad_path(max_label_dis)-grad_path(1));
    dissimilarity = exp(-orientation_diff).*exp(-norm_label(max_label_dis)+1).*exp(-grad_diff);
    
    [~,best_label] = max(dissimilarity);
    if num_label >= 1
        cpoint(4+(d_direction-1)*4) = y_location(max_label_dis(best_label));
        cpoint(5+(d_direction-1)*4) = x_location(max_label_dis(best_label));
        cpoint(6+(d_direction-1)*4) = sqrt((cpoint(4+(d_direction-1)*4)-cpoint(1))^2....
            +(cpoint(5+(d_direction-1)*4)-cpoint(2))^2);
        cpoint(7+(d_direction-1)*4) = orientation_diff(best_label);
        first_location{1+(d_direction-1)*5} = y_location(max_label_dis);
        first_location{2+(d_direction-1)*5} = x_location(max_label_dis);
        first_location{3+(d_direction-1)*5} = grad_diff;
        first_location{4+(d_direction-1)*5} = sqrt((y_location(max_label_dis)-m).^2+(x_location(max_label_dis)-n).^2);
        first_location{5+(d_direction-1)*5} = orientation_diff;
    end
end
end


function [max_label_dis,norm_label]= Compute_ext(label_path,edge_path,grad_path)
index_zero = label_path == 0;
norm_label = [0 diff(label_path)~=0];
norm_label(index_zero) = 0;
num_each_label = find(norm_label);    %每一个类出现的位置
norm_label = cumsum(norm_label);
norm_label(index_zero) = 0;
% num_label = length(num_each_label);
extr_point = edge_path;
extr_point(1) = 0;
index_edge = find(extr_point~=0);
for i = 1:length(index_edge)
    value_edge = norm_label(index_edge(i));
    norm_label(norm_label == value_edge) = 0;
end
data_point = unique(norm_label);
data_point = data_point(data_point~=0);
for i = 1:length(data_point)
    [~,index_max]= max(grad_path(norm_label == data_point(i)));
    extr_point(index_max+num_each_label(data_point(i))-1) = 1;
end
max_label_dis = find(extr_point);
% [~,max_label_dis] = sort(max_label_dis);
index_zero = extr_point==0;
norm_label = cumsum(extr_point);
norm_label(index_zero) = 0;
if isempty(max_label_dis)
    max_label_dis = [];
end
end