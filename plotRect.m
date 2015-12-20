function plotRect(cpoint_cell,img)
figure;imshow(img)
num_character = length(cpoint_cell);
for i = 1:num_character
     location_x = cpoint_cell{i}(:,2);
     location_y = cpoint_cell{i}(:,1);
     left = min(location_x);
     right = max(location_x);
     top = min(location_y);
     bottom = max(location_y);
     rectangle('Position',[left,top,right - left + 1,bottom - top + 1],'edgecolor','b');
end
end