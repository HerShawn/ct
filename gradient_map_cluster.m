function gradient_map_cluster()
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
close all
tic;
i = 135;
Debug = 1;
dirimg = 'E:\2012 文字检测\测试集\ICADR 2003\testimg\';
dirresult = 'E:\2012 文字检测\实验结果\测试结果\';
disp(['start to compute the image of ' num2str(i)])
imgname = [dirimg num2str(i) '.jpg'];
resultname = [dirresult num2str(i) '.tif'];
img = imread(imgname);
img = im2single(img);
img_hsi = rgb2hsi(img);
img_gray = rgb2gray(img);
[h,w,~] = size(img);
[edge_img, magGrad, orientation, lowThresh,~] = Compute_edge(img);
if (Debug)
    figure;imshow(img)
    figure;imshow(magGrad)
end
% figure;imshow(edge_img)
%% 计算角点
corner_candidate = Corner_point(img_gray,edge_img);
edge_img = edge_img - corner_candidate;
[bw_img,~] = bwlabel(edge_img,8);
bw_img = wextend('2', 'zpd',bw_img,1);
corner_candidate = wextend('2', 'zpd',corner_candidate,1);
offset_neighbor = [-1; h+2; 1; -h-2; -h-1; -h-3; h+1; h+3];
for m  = 1:h+2
    for n = 1:w+2
        if corner_candidate(m,n)
            Index = m+(h+2)*(n-1);
            Neighbors = Index + offset_neighbor;
            bw_img(m,n) = max(bw_img(Neighbors));
        end
    end
end
bw_img = bw_img(2:end-1,2:end-1);
corner_candidate = corner_candidate(2:end-1,2:end-1);
time_corner = toc;
disp(['The time of corner computing is ' num2str(time_corner)])
%% 显示角点图
if (Debug)
    figure;imshow(bw_img)
    hold on
    [xl,yl] = find(corner_candidate);
    plot(yl,xl,'*')
    hold off
end
%% 计算距离变换
[distance_label,label] = bwdist(bw_img);
diff_x = floor((label-1)/h)+1-repmat(1:w,h,1);   %行
diff_y = rem(label-1,h)+1-repmat((1:h)',1,w);    %列
orientation_e = atan2(diff_y,diff_x);         % 当前点和目标点之间的夹角
orientation_point = orientation(label);       %当前点所关联的目标点的角度
orientation_diff = mod(abs(orientation_e-orientation_point),2*pi);
orientation_diff = min(orientation_diff,2*pi-orientation_diff);
flag_point = double(orientation_diff<=pi/4);
flag_point = flag_point + 2*double(orientation_diff>pi*3/4);
flag_point(logical(edge_img)) = 3;
cluster_label = bw_img(label);                %对全图点进行标定
time_distance = toc;
disp(['The time of distance transfer computing is ' num2str(time_distance-time_corner)])
%% 计算梯度值比较大的点的标定图
grad_big = magGrad>lowThresh;
cluster_label_big = OnePass_gray(cluster_label,bw_img,grad_big,distance_label);
time_label = toc;
disp(['The time of label computing is ' num2str(time_label-time_distance)])
%     figure;imshow(cluster_label_big)
clear diff_x diff_y dx dx_t dy dy_t edge_img  grad_big img_gray label magGrad_t orientation_diff orientation_e orientation_point 
%% 计算笔画宽度
[cpoint_cell_p,cpoint_cell_n,path_p, path_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big);  %对应点列表
time_cor = toc;
disp(['The time of corresponding point computing is ' num2str(time_cor-time_label)])
%     plot_corresp(magGrad,cpoint_cell_n,1);
%% 构建邻域
% neighbor_img = regionneigbour(cluster_label_big,num_bw);
neighbor_img = regionneigbour_new(bw_img,corner_candidate);
[cpoint_cell_p,cpoint_cell_n,corresp_new,color_edge] = Edge_merge(img_hsi,img,bw_img,neighbor_img,cpoint_cell_p,cpoint_cell_n,path_p, path_n,magGrad,lowThresh,cluster_label,flag_point,cluster_label_big);
bw_img = show_result(cpoint_cell_p,h,w);
imwrite(bw_img,[num2str(i) '.jpg']);
% figure;imshow(bw_img)
% figure;imshow(img_hsi)
% [character_pair flag_alone flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge);
% time_edgemerge = toc;
% [cpoint_cell_p,cpoint_cell_n,flag_edge,feature_vector] = Delete_noncharadter_edge(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,h);
% show_result(cpoint_cell_p,flag_edge,h,w);

% resultname1 = [dirresult 'feature' num2str(i) '.mat'];
% resultname2 = [dirresult 'position' num2str(i) '.mat'];
% resultname3 = [dirresult 'chain' num2str(i) '.mat'];
% resultname4 = [dirresult 'color_edge' num2str(i) '.mat'];
% resultname5 = [dirresult 'cluster_label' num2str(i) '.mat'];
% resultname6 = [dirresult 'corresp_new' num2str(i) '.mat'];
% resultname7 = [dirresult 'character_pair' num2str(i) '.mat'];
% save(resultname1,'feature_vector');
% save(resultname2,'cpoint_cell_p','cpoint_cell_n');
% save(resultname3,'flag_chain');
% save(resultname4,'color_edge');
% save(resultname5,'cluster_label');
% save(resultname6,'corresp_new');
% save(resultname7,'character_pair');
% imwrite(bw_img,resultname);
% disp(['The time of edge merging computing is ' num2str(time_edgemerge-time_cor)])
% if (Debug)
%     figure;imshow(show_img)
% end
% imwrite(show_img,resultname);
end