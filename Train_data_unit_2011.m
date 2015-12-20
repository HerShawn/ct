function Train_data_unit_2011(imgprop,i)
% addpath('\\tsclient\D\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
% dirresult = '\\tsclient\E\2012 ���ּ��\ʵ����\ѵ�����2011\';
addpath('D:\Program Files\MATLAB\R2011a\toolbox\matlab tool box');
dirresult = 'E:\2012 ���ּ��\ʵ����\ѵ�����2011\';
color = 1;
disp(['start to compute the image of ' num2str(i)])
imgname = imgprop{i}.name;
resultname1 = [dirresult 'feature' num2str(i) '.mat'];
resultname2 = [dirresult 'label' num2str(i) '.mat'];
resultname3 = [dirresult 'position' num2str(i) '.mat'];

img = imread(imgname);
[h,w,~] = size(img);
if h>1200||w>1200
    img = imresize(img,[480,640]);
    for j = 1:length(imgprop{i}.location)
        imgprop{i}.location(j).left = max(round(imgprop{i}.location(j).left*640/w),1);
        imgprop{i}.location(j).top = max(round(imgprop{i}.location(j).top*480/h),1);
        imgprop{i}.location(j).right = min(round(imgprop{i}.location(j).right*640/w),w);
        imgprop{i}.location(j).bottom = min(round(imgprop{i}.location(j).bottom*480/h),h);
        imgprop{i}.location(j).w = imgprop{i}.location(j).right - imgprop{i}.location(j).left + 1;
        imgprop{i}.location(j).h = imgprop{i}.location(j).bottom - imgprop{i}.location(j).top + 1;
    end
end
imwrite(img,[dirresult num2str(i) '.jpg']);

img = im2single(img);
sigma = sqrt(2);
[h,w,~] = size(img);
if color
    magGrad = zeros(h,w);
    dx = zeros(h,w);
    dy = zeros(h,w);
    for j = 1:3
        [dx_t, dy_t] = smoothGradient(img(:,:,j), sigma);
        dx = dx+dx_t;
        dy = dy+dy_t;
        magGrad_t = hypot(dx_t, dy_t);
        magGrad = magGrad + magGrad_t;
    end
    img_gray = rgb2gray(img);
    orientation = atan2(dy,dx);
else
    img_gray = rgb2gray(img);
    [dx, dy] = smoothGradient(img_gray, sqrt(2));
    magGrad = hypot(dx, dy);
    orientation = atan2(dy,dx);
end
magGrad = magGrad/max(magGrad(:));
%% ������ֵ
lowThresh = graythresh(magGrad)*0.4;
highThresh = lowThresh/0.4;
edge_img = edge_canny(magGrad,dx,dy,lowThresh, highThresh);
edge_img = bwmorph(edge_img,'thin',Inf);
%% ����ǵ�
corner_candidate = Corner_point(img_gray,edge_img);
edge_img = edge_img - corner_candidate;
[bw_img,num_bw] = bwlabel(edge_img,8);
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
%% �������任
[distance_label,label] = bwdist(bw_img);
diff_x = floor((label-1)/h)+1 - repmat(1:w,h,1);   %��
diff_y = rem(label-1,h)+1 - repmat((1:h)',1,w);    %��
orientation_e = atan2(diff_y,diff_x);         % ��ǰ���Ŀ���֮��ļн�
orientation_point = orientation(label);       %��ǰ����������Ŀ���ĽǶ�
orientation_diff = mod(abs(orientation_e-orientation_point),2*pi);
orientation_diff = min(orientation_diff,2*pi-orientation_diff);
flag_point = double(orientation_diff<=pi/2);
flag_point = flag_point + 2*double(orientation_diff>pi*2/4);
flag_point(logical(edge_img)) = 3;
cluster_label = bw_img(label);                %��ȫͼ����б궨
%% �����ݶ�ֵ�Ƚϴ�ĵ�ı궨ͼ
grad_big = magGrad>lowThresh;
cluster_label_big = OnePass_gray(cluster_label,bw_img,grad_big,distance_label);
%% ����ʻ����
[cpoint_cell_p,cpoint_cell_n,path_p, path_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big);  %��Ӧ���б�
%% ��������
neighbor_img = regionneigbour_new(bw_img,corner_candidate);
[cpoint_cell_p,cpoint_cell_n,corresp_new,color_edge] = Edge_merge(img,bw_img,neighbor_img,cpoint_cell_p,cpoint_cell_n,path_p, path_n,magGrad,lowThresh,cluster_label_big);
[flag_pn] = Positive_negative_2011(cpoint_cell_p,imgprop{i});
show_img = show_result(cpoint_cell_p,h,w,flag_pn);
imwrite(show_img,[dirresult 'positive' num2str(i) '.jpg']);
show_img = show_result(cpoint_cell_p,h,w,~flag_pn);
imwrite(show_img,[dirresult 'negative' num2str(i) '.jpg']);

[~,~,~,feature_vector] = Delete_noncharadter_edge(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,h);
save(resultname1,'feature_vector');
save(resultname2,'flag_pn');
save(resultname3,'cpoint_cell_p','cpoint_cell_n');
% [character_pair flag_alone flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge);
% show_result(cpoint_cell_p,flag_edge,h,w);
end