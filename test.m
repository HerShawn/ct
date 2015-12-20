function test()
clear
clc
close all
dirimg = 'E:\文字检测2012\测试集\ICADR 2003\testimg\';
for i = 28:28
    imgname = [dirimg num2str(i) '.jpg'];
    img = imread(imgname);
    img = im2single(img);
    sigma = sqrt(2);
    [h,w,~] = size(img);
    img_gray = rgb2gray(img);
    [dx, dy] = smoothGradient(img_gray, sqrt(2));
    magGrad = hypot(dx, dy);
    orientation = atan2(dy,dx);
    magGrad = magGrad/max(magGrad(:));
    %% 计算阈值
    lowThresh = graythresh(magGrad)*0.6;
    highThresh = lowThresh/0.4;
    Thresh = [lowThresh highThresh];
    edge_img = edge(img_gray,'canny',[lowThresh highThresh]);
    edge_img = bwmorph(edge_img,'thin',Inf);
    %% 计算角点
    filterLength = 8*ceil(sigma);
    n = (filterLength - 1)/2;
    x = -n:n;
    c = 1/(sqrt(2*pi)*sigma);
    gaussKernel = c * exp(-(x.^2)/(2*sigma^2));
    gaussKernel = gaussKernel/sum(gaussKernel);
    temp = gaussKernel'*gaussKernel;
    img_gray = imfilter(img_gray, temp', 'conv', 'replicate');
    c1 = cornermetric(img_gray);
    corner_candidate = c1>1e-6&edge_img;
    corner_endpoint = bwmorph(edge_img,'endpoints');
    [rx,cx] = find(corner_endpoint);
    bw_end = bwselect(corner_candidate,cx,rx,8);
    corner_candidate(bw_end) = 0;
    corner_candidate = bwmorph(corner_candidate,'shrink',Inf);
    %% 显示结果
        figure;imshow(edge_img)
        hold on
        [xl,yl] = find(corner_candidate);
        plot(yl,xl,'*')
        hold off
    %% 计算距离变换
    edge_img_seg = edge_img - corner_candidate;
    [bw_img,num_bw] = bwlabel(edge_img_seg,8);
    [distance,label] = bwdist(edge_img_seg);
    %     diff_x = floor((label-1)/h)+1 - repmat(1:w,h,1);%行
    %     diff_y = rem(label-1,h)+1 - repmat((1:h)',1,w);%列
    %     orientation_e = atan2(diff_y,diff_x);% 当前点和目标点之间的夹角
    %     orientation_point = orientation(label); %当前点所关联的目标点的角度
    %     orientation_diff = mod(abs(orientation_e-orientation_point),2*pi);
    %     orientation_diff = min(orientation_diff,2*pi-orientation_diff);
    %     flag_point = double(orientation_diff<=pi/2);
    %     flag_point = flag_point + 2*double(orientation_diff>pi*2/4);
    %     flag_point(logical(edge_img)) = 3;
    cluster_label = bw_img(label);
    grad_min = magGrad>lowThresh;
    %% 计算笔画宽度
    cpoint = Corresponding_point(magGrad,orientation,edge_img_seg,cluster_label,Thresh);  %对应点列表
    cpoint_cell_p = cell(num_bw,1);
    cpoint_cell_n = cell(num_bw,1);
    for j = 1:length(cpoint)
        k = bw_img(cpoint(j,1),cpoint(j,2));
        zeros_index = cpoint(j,3) == 0|cpoint(j,4) == 0;
        distance_point = sqrt(sum((cpoint(j,1)-cpoint(j,3))^2+(cpoint(j,2)-cpoint(j,4))^2));
        orientation_diff_point = cpoint(j,11);
        cpoint_cell_p{k} = [cpoint_cell_p{k};distance_point orientation_diff_point zeros_index];
        zeros_index = cpoint(j,7) == 0|cpoint(j,8) == 0;
        distance_point = sqrt(sum((cpoint(j,1)-cpoint(j,7))^2+(cpoint(j,2)-cpoint(j,8))^2));
        orientation_diff_point = cpoint(j,12);
        cpoint_cell_n{k} = [cpoint_cell_n{k};distance_point orientation_diff_point zeros_index];
    end
    energy_orientation = zeros(1,num_bw);
    energy_sw = zeros(1,num_bw);
    for j = 1:num_bw
        zeros_index_v = cpoint_cell_n{j}(:,3);
        orientation_v = cpoint_cell_n{j}(:,2);
        orientation_v = orientation_v(~zeros_index_v);
        energy_orientation(j) = length(zeros_index_v)/sum(~zeros_index_v)*sum(orientation_v)/length(orientation_v);
        distance_v = cpoint_cell_n{j}(:,1);
        distance_v = distance_v(~zeros_index_v);
        energy_sw(j) = length(zeros_index_v)/sum(~zeros_index_v)*(1-sum(distance_v>median(distance_v)*2/3&distance_v<median(distance_v)*4/3)/length(distance_v));
        %         std(cpoint_cell_p{j}(:,1))/mean(cpoint_cell_p{j}(:,1));
    end
    energy_orientation = energy_orientation/pi;
    cluster_label_max = zeros(h,w);
    for k = 1:max(cluster_label(:))
        e = cluster_label == k&grad_min;
        [rstrong,cstrong] = find(bw_img == k);
        label_re = bwselect(e,cstrong,rstrong,8);
        cluster_label_max(label_re) = k;
    end
    index_zeros = (cluster_label_max == 0);
    cluster_label_max(index_zeros) = 1;
    imshow_img = energy_orientation(cluster_label_max)+energy_sw(cluster_label_max);
    imshow_img = 1-imshow_img/max(imshow_img(:));
    imshow_img(index_zeros) = 0;
    %     imshow_img = imadjust(imshow_img);
    figure;imshow(imshow_img,[])
    figure;imshow(bw_img)
    %         figure;imshow(magGrad)
    %         hold on
    %         for j = 1:length(cpoint)
    %             if bw_img(cpoint(j,1),cpoint(j,2)) == 97
    %                 plot(cpoint(j,8),cpoint(j,7),'*b');
    %             end
    %         end
    %         hold off
end
end


