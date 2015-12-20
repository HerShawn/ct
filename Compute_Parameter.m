function [magGrad,orientation,bw_img,cluster_label,cluster_label_big,img,neighbor_img,color] = Compute_Parameter(img,Debug,IsSave,parameterName,RLearners, RWeights)
if nargin == 2
    IsSave = 0;
elseif nargin == 1
    Debug = 0;
    IsSave = 0;
end
if Debug
    tic
end
[h,w,~] = size(img);
sigma = sqrt(2);
sizeScale = ceil(sqrt(h*w/(1280*960)));
 edge_img = Compute_edge(img,sigma);
% figure;imshow(edge_img)
% img_gray = rgb2gray(img);

% locationSmall = DectectSmall(edge_img, img,RLearners, RWeights);
% magGrad = [];
% orientation = [];
% bw_img = [];
% cluster_label = [];
% cluster_label_big = [];
% neighbor_img = [];
% color = [];
% return
locationSmall = [];
% img = imresize(img,1/sizeScale);
[h,w,~] = size(img);
img_gray = rgb2gray(img);
[edge_img, magGrad, orientation, lowThresh,~] = Compute_edge(img,sigma,locationSmall);
if Debug
%     figure;imshow(~edge_img);title('1');
    toc
end
img_hsi = rgb2hsi(img);
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
if (Debug)
    %带有计算出来的角点的边缘图
%     figure;imshow(~edge_img);title('2');
    hold on
    [xl,yl] = find(corner_candidate);
    plot(yl,xl,'*')
    hold off
end
%% 计算距离变
[distance_label,label] = bwdist(bw_img);
%陈奇师兄在这里改正了一下
label=double(label);
%
diff_x = floor((double(label)-1)/h)+1-repmat(1:w,h,1);   %行
diff_y = rem(label-1,h)+1-repmat((1:h)',1,w);    %列
orientation_e = atan2(diff_y,diff_x);         % 当前点和目标点之间的夹角
orientation_point = orientation(label);       %当前点所关联的目标点的角度
orientation_diff = mod(abs(orientation_e-orientation_point),2*pi);
orientation_diff = min(orientation_diff,2*pi-orientation_diff);
flag_point = double(orientation_diff<=pi/4);
flag_point = flag_point + 2*double(orientation_diff>pi*3/4);
flag_point(logical(edge_img)) = 3;
cluster_label = bw_img(label);                %对全图点进行标定
%% 计算梯度值比较大的点的标定图
grad_big = magGrad>lowThresh;
% cluster_label=uint32(cluster_label);
cluster_label_big = OnePass_gray(cluster_label,bw_img,grad_big,distance_label);
neighbor_img = regionneigbour_new(bw_img,corner_candidate);
load w2c
img_Pro = im2c(img*255,w2c,-2);
% [color_hsi_p,color_rgb_p,color_pro_p] = Mean_color(img_hsi,img,img_Pro,cluster_label,flag_point,magGrad,lowThresh,1);
% [color_hsi_n,color_rgb_n,color_pro_n] = Mean_color(img_hsi,img,img_Pro,cluster_label,flag_point,magGrad,lowThresh,0);
[color_hsi_p,color_rgb_p,color_pro_p] = MeanColor(img_hsi,img,img_Pro,cluster_label,flag_point,magGrad,lowThresh,1);
[color_hsi_n,color_rgb_n,color_pro_n] = MeanColor(img_hsi,img,img_Pro,cluster_label,flag_point,magGrad,lowThresh,0);
color.hsi_p = color_hsi_p;
color.hsi_n = color_hsi_n;
color.rgb_p = color_rgb_p;
color.rgb_n = color_rgb_n;
color.pro_p = color_pro_p;
color.pro_n = color_pro_n;
if IsSave
    save(parameterName,'magGrad','orientation','bw_img','cluster_label','cluster_label_big','neighbor_img','color')
end
end
% function locationSmall = DectectSmall(edge_img, img, sizeScale,RLearners, RWeights)
% [h,w] = size(edge_img);
% th_h = max(0.05*h,25);
% se = strel('line',sizeScale*2+1,0);
% img_dilate = imdilate(edge_img,se);
% [bw_dilate,num] = bwlabel(img_dilate,8);
% props = regionprops(bw_dilate,'BoundingBox');
% left = zeros(1,num);
% top = zeros(1,num);
% right = zeros(1,num);
% bottom = zeros(1,num);
% for i = 1:num
%     left(i) = props(i).BoundingBox(1,1)+0.5;
%     right(i) = props(i).BoundingBox(1,1)+props(i).BoundingBox(1,3)-0.5;
%     top(i) = props(i).BoundingBox(1,2)+0.5;
%     bottom(i) = props(i).BoundingBox(1,2)+props(i).BoundingBox(1,4)-0.5;
% end
% height = bottom - top + 1;
% width = right - left + 1;
%
% %% judge chain
% for i = 1:num
% %     disp(i)
%     if height(i)<th_h&&width(i)/height(i)>2
%         chain_img = bw_dilate(top(i):bottom(i),left(i):right(i));
%         chain_img = chain_img == i;
%         regionProp = regionprops(chain_img,'Orientation');
%         rotateBwImage = imrotate(chain_img,-regionProp.Orientation);
%
%         [y_rotate, x_rotate] = find(rotateBwImage);
%         left_rotate = min(x_rotate);
%         top_rotate = min(y_rotate);
%         right_rotate = max(x_rotate);
%         bottom_rotate = max(y_rotate);
%         flag_occupy = sum(chain_img(:)~=0)/(bottom_rotate - top_rotate + 1)/(right_rotate - left_rotate + 1)>1/3;
%         flag_num = (bottom_rotate - top_rotate + 1)*(right_rotate - left_rotate + 1)>48*8;
%         if ~flag_occupy||~flag_num
%             continue
%         end
%         sub_img = img(top(i):bottom(i),left(i):right(i),:);
%         sub_img = imrotate(sub_img,-regionProp.Orientation);
%         sub_img = sub_img(top_rotate:bottom_rotate,left_rotate:right_rotate,:);
%         feature = Compute_HogFeature(sub_img);
%         ResultR = Classify(RLearners, RWeights, feature');
%         %         bw_dilate_sub = bw_dilate(top_sub:bottom_sub,left_sub:right_sub,:);
%         %         bw_dilate_sub = imrotate(bw_dilate_sub,-regionProp.Orientation);
%         %         bw_dilate_sub = bw_dilate_sub(top_rotate:bottom_rotate,left_rotate:right_rotate,:);
%
%         if ResultR>0
%             %             figure;imshow(sub_img)
%             %             figure;imshow(chain_img)
%             str = num2str(round(rand(1,1)*10000));
%             imwrite(sub_img,[str '_img' '.tif']);
%             imwrite(chain_img,[str '_edge' '.tif']);
%         end
%     end
% end
% locationSmall = [];
% end