function [bwResultImg, resultImg, location] = MergeTopBottom(img, language)
if nargin == 1
    language = 1;
end
[h,w] = size(img);
[bwLabel,numCC] = bwlabel(img);
stats = regionprops(bwLabel, 'BoundingBox');
Rect = zeros(numCC,4);
for i = 1:numCC
    Rect(i,1) = stats(i).BoundingBox(1)+0.5;  % left
    Rect(i,2) = stats(i).BoundingBox(2)+0.5;  % top
    Rect(i,3) = stats(i).BoundingBox(1) + stats(i).BoundingBox(3)-0.5; % right
    Rect(i,4) = stats(i).BoundingBox(2) + stats(i).BoundingBox(4)-0.5; % bottom
end
mergePair = [];
%% 2013-5-1
for i = 1:numCC
    for j = i+1:numCC
        if Overlaprect(Rect(i,:), Rect(j,:), h, language)
            mergePair = [mergePair; i j];
        end
    end
end
flag_chain = FromPairChain(mergePair, numCC);
%% ÏÔÊ¾½á¹û
resultImg = zeros(h,w,3);
bwResultImg = zeros(h,w);
numChain = max(flag_chain);
colorShow = rand(3,numChain);
location = zeros(4,numChain); % left top right bottom
location(1,:) = w*ones(1,numChain);
location(2,:) = h*ones(1,numChain);
for i = 1:h
    for j = 1:w
        if (bwLabel(i,j))
            indexChain = flag_chain(bwLabel(i,j));
            bwResultImg(i,j) = indexChain;
            resultImg(i,j,1) = colorShow(1,indexChain);
            resultImg(i,j,2) = colorShow(2,indexChain);
            resultImg(i,j,3) = colorShow(3,indexChain);
            
            location(1,indexChain) = min(j,location(1,indexChain));
            location(2,indexChain) = min(i,location(2,indexChain));
            location(3,indexChain) = max(j,location(3,indexChain));
            location(4,indexChain) = max(i,location(4,indexChain));
        end
    end
end
end

function IsOverlaped = Overlaprect(rect1, rect2, h, language)
width1=rect1(3)-rect1(1)+1;
width2=rect2(3)-rect2(1)+1;
height1 = rect1(4) - rect1(2) + 1;
height2 = rect2(4) - rect2(2) + 1;
if height1 < 0.3*h||height2<0.3*h
    factor = 0.2;
else
    factor = 0.2;
end
if language == 1
    factor = 0.5;
end
intersect = min(rect1(3),rect2(3)) - max(rect1(1),rect2(1));
IsOverlaped = intersect>min(width1,width2)*factor;
%
% IsOverlaped = (rect1(1)<=rect2(1)&&(rect1(3)-rect2(1)+1)>=th*min(width1,width2)) || (rect1(1)>=rect2(1)&&rect1(3)<=rect2(3))...
%     || (rect1(3)>=rect2(3)&&(rect2(3)-rect1(1)+1)>=th*min(width1,width2));
end

