%% 计算一个边缘的颜色
function [color_hsi,color_rgb,color_pro] = Mean_color(varargin)
if nargin == 9
    [color_r,color_g,color_b,path,index_point,magGrad,lowThresh,th_d,h] = parse_inputs1(varargin{:});
    path_edge_v1 = path{index_point};
    num_point = size(path_edge_v1,1);
    point_index = [];
    point_weight = [];
    for p = 1:num_point
        path_py_v = path_edge_v1{p,1};
        path_px_v = path_edge_v1{p,2};
        if (~isempty(path_py_v))
            distance_v = sqrt((path_py_v-path_py_v(1)).^2+(path_px_v-path_px_v(1)).^2);
            index_v = path_py_v+(path_px_v-1)*h;
            index_v = index_v(distance_v<th_d);
            point_index = [point_index index_v];
            point_weight = [point_weight exp(-magGrad(index_v)/lowThresh*0.6931)];
        end
    end
    point_weight = point_weight/sum(point_weight);
    color_reo = sum(color_r(point_index).*point_weight);
    color_geo = sum(color_g(point_index).*point_weight);
    color_beo = sum(color_b(point_index).*point_weight);
else
    %% 计算每个边缘颜色
    [img_hsi,img_rgb,img_pro,cluster_label,flag_point,magGrad,lowThresh,direction] = parse_inputs2(varargin{:});
    color_h = img_hsi(:,:,1);
    color_s = img_hsi(:,:,2);
    color_i = img_hsi(:,:,3);
    color_r = img_rgb(:,:,1);
    color_g = img_rgb(:,:,2);
    color_b = img_rgb(:,:,3);
    num_edge = max(cluster_label(:));
    [h,w] = size(color_r);
    weight = zeros(num_edge,1);
    color_hsi = zeros(num_edge,3);
    color_rgb = zeros(num_edge,3);
    color_pro = zeros(num_edge,11);
    for i = 1:h
        for j = 1:w
            if flag_point(i,j) == (direction+1)
                index = cluster_label(i,j);
                weight_point = exp(-magGrad(i,j)/lowThresh*0.6931);
                weight(index) = weight(index) + weight_point;
                color_hsi(index,1) = color_hsi(index,1)+ color_h(i,j)*weight_point;
                color_hsi(index,2) = color_hsi(index,2)+ color_s(i,j)*weight_point;
                color_hsi(index,3) = color_hsi(index,3)+ color_i(i,j)*weight_point;
                color_rgb(index,1) = color_rgb(index,1)+ color_r(i,j)*weight_point;
                color_rgb(index,2) = color_rgb(index,2)+ color_g(i,j)*weight_point;
                color_rgb(index,3) = color_rgb(index,3)+ color_b(i,j)*weight_point;
                color_pro(index,:) = color_pro(index,:) + reshape(img_pro(i,j,:),[1,11])*weight_point;
            end
        end
    end
    color_hsi = color_hsi./(repmat(weight,[1 3])+eps);
    color_rgb = color_rgb./(repmat(weight,[1 3])+eps);
    color_pro = color_pro./(repmat(weight,[1 11])+eps);
end
end
function [color_r,color_g,color_b,path,index_point,magGrad,lowThresh,th_d,h] = parse_inputs1(varargin)
color_r = varargin{1};
color_g = varargin{2};
color_b = varargin{3};
path = varargin{4};
index_point = varargin{5};
magGrad = varargin{6};
lowThresh = varargin{7};
th_d = varargin{8};
h = varargin{9};
end
function [img_hsi,img_rgb,img_pro,cluster_label,flag_point,magGrad,lowThresh,direction] = parse_inputs2(varargin)
img_hsi = varargin{1};
img_rgb = varargin{2};
img_pro = varargin{3};
cluster_label = varargin{4};
flag_point = varargin{5};
magGrad = varargin{6};
lowThresh = varargin{7};
direction = varargin{8};
end