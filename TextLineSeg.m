function TextLineSeg(img)
numLine = max(img(:));
for i = 1:numLine
    subImg = img == i;
    [locationY, locationX] = find(subImg);
    top = min(locationY);
    bottom = max(locationY);
    left = min(locationX);
    right = max(locationX);
    subImg = subImg(top:bottom,left:right);
    subImg = ImgRotate(subImg);
    % Ðý×ª
    flagLanguage = LanguageDet(subImg);
    if flagLanguage
        ChineseSeg();
    else
        EnglishSeg();
    end
end
end

function img = ImgRotate(img)
index_chain = find(flag_chain == i);

left_chain = min(left(index_chain));
right_chain = max(right(index_chain));
top_chain = min(top(index_chain));
bottom_chain = max(bottom(index_chain));
height_chain = bottom_chain - top_chain + 1;
width_chain = right_chain - left_chain + 1;
regionProp = regionprops(bwSubImg,'Orientation');
rotateBwImage = imrotate(bwSubImg,-regionProp.Orientation);
[y_rotate, x_rotate] = find(rotateBwImage);
left_rotate = min(x_rotate);
top_rotate = min(y_rotate);
right_rotate = max(x_rotate);
bottom_rotate = max(y_rotate);
sub_img = img(top_chain:bottom_chain,left_chain:right_chain,:);
sub_img = imrotate(sub_img,-regionProp.Orientation);
sub_img = sub_img(top_rotate:bottom_rotate,left_rotate:right_rotate,:);
end