function feature_all = GetNegSample(edge_img, img, position)
feature_all = [];
[h,w] = size(edge_img);
th_h = max(0.05*h,25);
se = strel('line',3,0);
img_dilate = imdilate(edge_img,se);
[bw_dilate,num] = bwlabel(img_dilate,8);
props = regionprops(bw_dilate,'BoundingBox');
left = zeros(1,num);
top = zeros(1,num);
right = zeros(1,num);
bottom = zeros(1,num);
for i = 1:num
    left(i) = props(i).BoundingBox(1,1)+0.5;
    right(i) = props(i).BoundingBox(1,1)+props(i).BoundingBox(1,3)-0.5;
    top(i) = props(i).BoundingBox(1,2)+0.5;
    bottom(i) = props(i).BoundingBox(1,2)+props(i).BoundingBox(1,4)-0.5;
end
height = bottom - top + 1;
width = right - left + 1;

pair_vec = [];
for i = 1:num
    for j = i+1:num
        flag_position1 = height(i)<th_h&&height(j)<th_h;
        flag_position4 = abs(height(i) - height(j))/max(height(i),height(j))<0.4;
        flag_position5 = max(left(i) - right(j),left(j) - right(i))<1.5*max(height(i),height(j));
        flag_position6 = abs(bottom(i) - bottom(j))/max(height(i),height(j))<0.2||abs(top(i) - top(j))/max(height(i),height(j))<0.2;
        flag_position_second = flag_position1&&flag_position4&&flag_position5&&flag_position6;
        if (flag_position_second)
            pair_vec = [pair_vec;i j];
        end
    end
end

%% Éú³É×Ö·û´®
flag_chain = zeros(1,num);
k = 0;
character_pair_tmp = pair_vec;
while ~isempty(character_pair_tmp)
    k = k+1;
    value1 = character_pair_tmp(1,1);
    value2 = character_pair_tmp(1,2);
    character_pair_tmp = character_pair_tmp(2:end,:);
    flag_chain(value1) = k;
    flag_chain(value2) = k;
    vec = [value1 value2];
    while ~isempty(vec)
        index_x = [];
        for i = 1:length(vec)
            [index1_x, ~] = find(character_pair_tmp == vec(i));
            index_x = [index_x;index1_x];
        end
        vec_tmp = character_pair_tmp(index_x,:);
        vec = vec_tmp(:);
        vec = unique(vec);
        flag_chain(vec) = k;
        character_pair_tmp(index_x,:) = [];
    end
end
%% judge chain
num_chain1 = max(flag_chain);
num_chain2 = sum(flag_chain==0);
num_chain = num_chain1+num_chain2;
k = 0;
for i = 1:num_chain
    if i<=num_chain1
        index_chain = find(flag_chain == i);
        chain_img = zeros(h,w);
        for j = 1:length(index_chain)
            chain_img(bw_dilate == index_chain(j)) = 1;
        end
    else
        k = k+1;
        if k == 75
        end
        if ~flag_chain(k)
            chain_img = zeros(h,w);
            chain_img(bw_dilate == k) = 1;
        else
            continue
        end
    end
    [y_rotate, x_rotate] = find(chain_img);
    left_sub = min(x_rotate);
    top_sub = min(y_rotate);
    right_sub = max(x_rotate);
    bottom_sub = max(y_rotate);
    height_sub = bottom_sub - top_sub + 1;
    width_sub = right_sub - left_sub + 1;
    chain_img = chain_img(top_sub:bottom_sub,left_sub:right_sub);
    regionProp = regionprops(chain_img,'Orientation');
    rotateBwImage = imrotate(chain_img,-regionProp.Orientation);
    [y_rotate, x_rotate] = find(rotateBwImage);
    left_rotate = min(x_rotate);
    top_rotate = min(y_rotate);
    right_rotate = max(x_rotate);
    bottom_rotate = max(y_rotate);
    height_rotate = bottom_rotate - top_rotate + 1;
    width_rotate = right_rotate - left_rotate + 1;
%     flag_num = height_rotate*width_rotate>48*8||width_rotate/height_rotate>5&&occupy_value>0.5;
%     flag_position = height_rotate>th_h||width_rotate/height_rotate<2||height_rotate<8;
%     if ~flag_num||flag_position
%         continue
%     end
    flag_Overlap = IsOverlapped(left_sub,top_sub,right_sub,bottom_sub,position);
    if (width_sub/height_sub>2||width_sub/height_sub<1/2)&&~flag_Overlap
        sub_img = img(top_sub:bottom_sub,left_sub:right_sub,:);
        sub_img = imrotate(sub_img,-regionProp.Orientation);
        sub_img = sub_img(top_rotate:bottom_rotate,left_rotate:right_rotate,:);
%         figure;imshow(sub_img)
        feature = Compute_HogFeature(sub_img);
        feature_all = [feature_all;feature];
    end
    
    %     if ResultR>0&&flag_occupy&&width_sub/height_sub>2
    %         str = num2str(round(rand(1,1)*10000));
    %     end
end
end

function flag_Overlap = IsOverlapped(left,top,right,bottom,position)
num_rec = size(position,1);
flag_Overlap = 0;
for i = 1:num_rec
    flag11 = (left>position(i,1)&&left<position(i,3)) || (right>position(i,1)&&right<position(i,3));
    flag12 = (top<position(i,4)&&top>position(i,2))||(bottom>position(i,2)&&bottom<position(i,4));
    flag1 = flag11&&flag12;
    flag2 = left>=position(i,1)&&top>=position(i,2)&&right<=position(i,3)&&bottom<=position(i,4);
    flag3 = left<=position(i,1)&&top<=position(i,2)&&right>=position(i,3)&&bottom>=position(i,4);
    flag = flag1||flag2||flag3;
    flag_Overlap = flag_Overlap|flag;
end
end