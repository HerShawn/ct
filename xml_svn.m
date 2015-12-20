clear
clc
xDoc = xmlread('E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\svt1\test.xml');
allListItems = xDoc.getElementsByTagName('image');
imgprop=cell(1,allListItems.getLength);
for k = 0:allListItems.getLength-1
    thisListItem = allListItems.item(k);
    childNode = thisListItem.getFirstChild;
    
    
    while ~isempty(childNode)
        %Filter out text, comments, and processing instructions.
        if childNode.getNodeType == childNode.ELEMENT_NODE
            switch char(childNode.getTagName)
                case 'imageName';
                    childText = char(childNode.getFirstChild.getData);
                    pp.name=childText;
                    img_name = ['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\svt1\' pp.name];
                    img = imread(img_name);
                    [h,w,dim] = size(img);
                    %                 case 'Resolution ' ;
                    %                     location.x = str2double(char(childNode.getAttributes.item(0).getValue));
                    %                     location.y = str2double(char(childNode.getAttributes.item(1).getValue));
                case 'taggedRectangles';
                    taggedRectanglesItem = childNode;
                    taggedRectangleschildNode = taggedRectanglesItem.getFirstChild;
                    loword=[];
                    loword2 = [];
                    while ~isempty(taggedRectangleschildNode)
                        if taggedRectangleschildNode.getNodeType == taggedRectangleschildNode.ELEMENT_NODE
                            re.h = str2double(char(taggedRectangleschildNode.getAttributes.item(0).getValue));
                            re.w = str2double(char(taggedRectangleschildNode.getAttributes.item(1).getValue));
                            re.x = str2double(char(taggedRectangleschildNode.getAttributes.item(2).getValue));
                            re.y = str2double(char(taggedRectangleschildNode.getAttributes.item(3).getValue));
                            loword=[loword re];
                            loword2 = [loword2;max(re.x,1) max(re.y,1) min(re.x+re.w,w) min(re.y+re.h,h)];
                        end
                        taggedRectangleschildNode = taggedRectangleschildNode.getNextSibling;
                    end
            end
        end
        childNode = childNode.getNextSibling;
    end
    
    
    result_img = zeros(h,w,3);
    num_rect = size(loword2,1);
    for m = 1:num_rect
        result_img(loword2(m,2):loword2(m,4),loword2(m,1):loword2(m,3),1) = img(loword2(m,2):loword2(m,4),loword2(m,1):loword2(m,3),1);
        result_img(loword2(m,2):loword2(m,4),loword2(m,1):loword2(m,3),2) = img(loword2(m,2):loword2(m,4),loword2(m,1):loword2(m,3),2);
        result_img(loword2(m,2):loword2(m,4),loword2(m,1):loword2(m,3),3) = img(loword2(m,2):loword2(m,4),loword2(m,1):loword2(m,3),3);
    end
    imwrite(uint8(result_img),['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\svt1\gt\' pp.name])
    %     pp.loc=location;
    pp.word=loword;
    imgprop{k+1}=pp;
    dlmname = [childText(5:end-4) '.txt'];
    %     dlmwrite(dlmname,loword2);
end