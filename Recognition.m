function [rect,rectWord,char] = Recognition(cpoint_cell,flag_chain,colorEdge,img,Debug)
imgHSI = rgb2hsi(img);
num_character = length(cpoint_cell);
rect = [];
rectWord = [];
featureAll = [];
char = {};
p = 1;
[h,w,~] = size(img);
num_chain = max(flag_chain);
%% color chain
color_chain_min = ones(num_chain,6);
color_chain_max = zeros(num_chain,6);
for i = 1:num_character
    value_chain = flag_chain(i);
    if value_chain
        color_chain_min(value_chain,:) = min([colorEdge(i,:);color_chain_min(value_chain,:)],[],1);
        color_chain_max(value_chain,:) = max([colorEdge(i,:);color_chain_max(value_chain,:)],[],1);
    end
end
%%
for i = 1:num_chain
    index_chain = find(flag_chain == i);
    left = w; right = 0; top = h; bottom = 0;
    numCC = length(index_chain);
    %     colorTmp = zeros(numCC,6);
    %     bwSubImg = zeros(height_chain, width_chain);
    for j = 1:numCC
        location_x = cpoint_cell{index_chain(j)}(:,2);
        location_y = cpoint_cell{index_chain(j)}(:,1);
        %         colorTmp(j,:) = colorEdge(index_chain(j),:);
        left = min(left, min(location_x));
        right = max(right, max(location_x));
        top = min(top, min(location_y));
        bottom = max(bottom, max(location_y));
    end
    %     colorTmp = mean(colorTmp,1);
    subImg = img(top:bottom,left:right,:);
    subHsi = imgHSI(top:bottom,left:right,:);
    
    location = Get_ccEdge(subImg,subHsi,color_chain_min(i,:),color_chain_max(i,:));
    if isempty(location)
        continue
    end
    location(1,:) = location(1,:) + left - 1;
    location(2,:) = location(2,:) + top - 1;
    location(3,:) = location(3,:) + left - 1;
    location(4,:) = location(4,:) + top - 1;
    for j = 1:size(location,2)
        subImg = img(location(2,j):location(4,j),location(1,j):location(3,j),:);
        [subH,subW,~] = size(subImg);
        subImg = imresize(subImg,[100 100]);
        feature = hog(im2single(subImg),25,4);
        feature = feature(:)';
        feature = [double(feature) subH/subW];
        featureAll = [featureAll; feature location(1,j) location(2,j) location(3,j) location(4,j) i];
    end
end
load(['E:\2013±ÏÉèÎÄ×Ö¼ì²â\²âÊÔ¼¯\charÒ»ÆðÑµÁ·\model8.mat']);
[hat,y] = classRF_predict(featureAll(:,1:end-4),model);
% if 1
for i = 1:num_chain
    index = featureAll(:,end) == i;
    if (sum(hat(index)>0)/sum(index)>0.5)
        %% modified 2013-6-20
        ySelected = y(index,:);
        hatSelected = hat(index);
        for k = 1:sum(index)
            if ~hatSelected(k)
                [~,maxIndex] = max(ySelected(k,:));
                ySelected(k,maxIndex) = 0;
                [~,maxIndex] = max(ySelected(k,:));
                hatSelected(k) = maxIndex-1;
            end
        end
        locationRect = featureAll(index,end-4:end-1);
        [~,indexR] = sort(locationRect(:,1));
        locationRect = locationRect(indexR,:);
        hatSelected = hatSelected(indexR);
        rect = [rect;locationRect hatSelected];
%             rect = [rect; featureAll(index,end-4:end-1) hat(index)];

        %%
        flag = SeparateWordRecog(featureAll(index,end-4:end-1));
        left = featureAll(index,end-4);
        top = featureAll(index,end-3);
        right = featureAll(index,end-2);
        bottom = featureAll(index,end-1);
        for k = 1:max(flag)
            rectWord = [rectWord;min(left(flag == k)),min(top(flag == k)),max(right(flag == k)),max(bottom(flag == k))];
%             char{p} = num2strR(hatSelected(flag == k));
            p = p+1;
        end
    end
end
% else
%     for i = 1:num_chain
%         index = featureAll(:,end) == i;
%         flag = SeparateWordRecog(featureAll(index,end-4:end-1));
%         left = featureAll(index,end-4);
%         top = featureAll(index,end-3);
%         right = featureAll(index,end-2);
%         bottom = featureAll(index,end-1);
%         hatTmp = hat(index);
%         for k = 1:max(flag)
%             if (sum(hatTmp(flag == k)>0)/length(hatTmp(flag == k))>0.5)
%                 rectWord = [rectWord;min(left(flag == k)),min(top(flag == k)),max(right(flag == k)),max(bottom(flag == k))];
%             end
%         end
%      end
% end
if Debug
    figure;imshow(img)
    for i = 1:size(rect,1)
        rectangle('Position', [rect(i,1) rect(i,2) rect(i,3)-rect(i,1)+1 rect(i,4)-rect(i,2)+1],'EdgeColor','r');
        text(rect(i,1),rect(i,2),num2strR(rect(i,5)),'FontSize',18,'Color','b');
    end
end
end