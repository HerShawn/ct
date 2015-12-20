%该方法主要是显示stroke width transform 方法的笔画宽度结果
function  [cpoint_cell_p,cpoint_cell_n] = Corresponding_point_org(magGrad,orientation,bw_img)
%  cpoint 为输出的对应点关系矩阵 为m*n m为边缘点的个数 n分别为 1横坐标 2纵坐标 3所属的标定
%  4正对应点的横坐标 5纵坐标 6距离 7角度差 8负对应点的横坐标 9纵坐标 10距离 11角度差
num_point = sum(bw_img(:)~=0);
cpoint = zeros(num_point,11);
[h,w] = size(magGrad);
%% 标定每个点的方向
direction = ones(h,w)*(-1);
direction = direction + double((orientation<=1/4*pi&orientation>-pi/4));
direction = direction + 2*double((orientation<=3/4*pi&orientation>pi/4));
direction = direction + 3*double((orientation>3/4*pi)|(orientation<=-3/4*pi));
direction = direction + 4*double((orientation<=-1/4*pi&orientation>-3/4*pi));
max_swidth = min(h,w)/6; % 最大的笔画宽度
%% 主循环 计算每个点的对应点
kk = 0;
for m = 1:h
    for n = 1:w
        if bw_img(m,n)
            kk = kk+1;
            cpoint(kk,1) = m;
            cpoint(kk,2) = n;
            cpoint(kk,3) = bw_img(m,n);
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
                label_path = bw_img((x_location-1)*h+y_location);
                best_label = find(label_path~=0,2);
                if sum(label_path~=0) > 1
                    cpoint(kk,4+(d_direction-1)*4) = y_location(best_label(2));
                    cpoint(kk,5+(d_direction-1)*4) = x_location(best_label(2));
                end
            end
        end
    end
end
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

end