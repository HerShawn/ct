clear
clc
xDoc = xmlread('locations.xml');
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
                case 'resolution' ;
                    locationa.x = str2double(char(childNode.getAttributes.item(0).getValue));
                    locationa.y = str2double(char(childNode.getAttributes.item(1).getValue));
                case 'taggedRectangles';
                    taggedRectanglesItem = childNode;
                    taggedRectangleschildNode = taggedRectanglesItem.getFirstChild;
                    loword=[];
                    while ~isempty(taggedRectangleschildNode)
                        if taggedRectangleschildNode.getNodeType == taggedRectangleschildNode.ELEMENT_NODE
                            re.h = str2double(char(taggedRectangleschildNode.getAttributes.item(0).getValue));
                            re.w = str2double(char(taggedRectangleschildNode.getAttributes.item(4).getValue));
                            re.x = str2double(char(taggedRectangleschildNode.getAttributes.item(5).getValue));
                            re.y = str2double(char(taggedRectangleschildNode.getAttributes.item(6).getValue));
                            loword=[loword re];
                        end
                        taggedRectangleschildNode = taggedRectangleschildNode.getNextSibling;
                    end
            end  
        end
        childNode = childNode.getNextSibling;
    end
    pp.name=childText;
    pp.loc=locationa;
    pp.word=loword;
    imgprop{k+1}=pp;
end