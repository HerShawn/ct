function gradient_map_cluster_test(img,direction,Debug,IsSave)
if nargin == 2
    Debug = 0;
    IsSave = 0;
end
img_hsi = rgb2hsi(img);
img_gray = rgb2gray(img);
[h,w,~] = size(img);
[edge_img, magGrad, orientation, lowThresh,~] = Compute_edge(img);
%% ����ǵ�
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
if (Debug)
    figure;imshow(bw_img)
    hold on
    [xl,yl] = find(corner_candidate);
    plot(yl,xl,'*')
    hold off
end
%% �������任
[distance_label,label] = bwdist(bw_img);
diff_x = floor((label-1)/h)+1-repmat(1:w,h,1);   %��
diff_y = rem(label-1,h)+1-repmat((1:h)',1,w);    %��
orientation_e = atan2(diff_y,diff_x);         % ��ǰ���Ŀ���֮��ļн�
orientation_point = orientation(label);       %��ǰ����������Ŀ���ĽǶ�
orientation_diff = mod(abs(orientation_e-orientation_point),2*pi);
orientation_diff = min(orientation_diff,2*pi-orientation_diff);
flag_point = double(orientation_diff<=pi/4);
flag_point = flag_point + 2*double(orientation_diff>pi*3/4);
flag_point(logical(edge_img)) = 3;
cluster_label = bw_img(label);                %��ȫͼ����б궨
%% �����ݶ�ֵ�Ƚϴ�ĵ�ı궨ͼ
grad_big = magGrad>lowThresh;
cluster_label_big = OnePass_gray(cluster_label,bw_img,grad_big,distance_label);
%% ����ʻ����
[cpoint_cell_p,cpoint_cell_n] = Corresponding_point(magGrad,orientation,bw_img,cluster_label_big);  %��Ӧ���б�
if IsSave
    save(['E:\2012 ���ּ��\����_�޸�\��Ӧ�����\position' num2str(i) '.mat'],'cpoint_cell_p','cpoint_cell_n');
end
% load(['E:\2012 ���ּ��\����_�޸�\��Ӧ�����\position' num2str(i) '.mat']);
%% ��������
neighbor_img = regionneigbour_new(bw_img,corner_candidate);
[cpoint_cell_p,cpoint_cell_n,corresp_new,color_edge] = Edge_merge(img_hsi,img,bw_img,neighbor_img,cpoint_cell_p,cpoint_cell_n,magGrad,lowThresh,cluster_label,flag_point,cluster_label_big,direction);
if(Debug)
    bw_img = show_result(cpoint_cell_p,h,w);
    figure;imshow(bw_img)
end
[character_pair flag_alone flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge,cluster_label,corresp_new,direction);
if direction == 1
    [cpoint_cell_p,cpoint_cell_n,flag_edge,feature_vector] = Compute_feature(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,ones(1,length(cpoint_cell_p)));
else
    [cpoint_cell_p,cpoint_cell_n,flag_edge,feature_vector] = Compute_feature(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,zeros(1,length(cpoint_cell_p)));
end

%% save result
if direction == 1
    dirresult = 'data_positive/';
else
    dirresult = 'data_negative/';
end
resultname1 = [dirresult 'feature/feature' num2str(i) '.mat'];
resultname2 = [dirresult 'position/position' num2str(i) '.mat'];
resultname3 = [dirresult 'chain/chain' num2str(i) '.mat'];
resultname4 = [dirresult 'color_edge/color_edge' num2str(i) '.mat'];
resultname5 = [dirresult 'cluster_label/cluster_label' num2str(i) '.mat'];
resultname6 = [dirresult 'corresp_new/corresp_new' num2str(i) '.mat'];
resultname7 = [dirresult 'character_pair/character_pair' num2str(i) '.mat'];
save(resultname1,'feature_vector');
save(resultname2,'cpoint_cell_p','cpoint_cell_n');
save(resultname3,'flag_chain');
save(resultname4,'color_edge');
save(resultname5,'cluster_label');
save(resultname6,'corresp_new');
save(resultname7,'character_pair');

end