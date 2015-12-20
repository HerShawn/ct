function Show_two_character(img_value,img,model,direction)
save_dir = 'E:\2012 ÎÄ×Ö¼ì²â\´úÂë2011\Test_Data\';
if direction == 1
    load([save_dir 'Merge_P\',img_value '.mat'])
    load([save_dir 'Feature_P\' img_value '.mat'])
    load([save_dir 'Chain_P\' img_value '.mat'])
else
    load([save_dir 'Merge_N\',img_value '.mat'])
    load([save_dir 'Feature_N\' img_value '.mat'])
    load([save_dir 'Chain_N\' img_value '.mat'])
end
[h,w,~] = size(img);
[location flag_character] = show_two_chain(cpoint_cell, feature_vector, flag_chain, model);

num_chain = size(location,1);
if ~num_chain
    return
end
bw_result = zeros(h,w);
rgb_result = zeros(h,w,3);
for i = 1:num_chain
    left = location(i,1);
    top = location(i,2);
    right = location(i,3);
    bottom = location(i,4);
    bw_result(top:bottom,left:right) = 1;
    rgb_result(top:bottom,left:right,:) = img(top:bottom,left:right,:);
end
show_img = show_result(cpoint_cell,h,w,flag_character);
if direction == 1
    imwrite(bw_result,[save_dir 'Two_character_P\bw',img_value '.tif']);
    imwrite(rgb_result,[save_dir 'Two_character_P\rgb',img_value '.tif']);
    imwrite(show_img,[save_dir 'Two_character_P\edge',img_value '.tif']);
else
    imwrite(bw_result,[save_dir 'Two_character_N\bw',img_value '.tif']);
    imwrite(rgb_result,[save_dir 'Two_character_N\rgb',img_value '.tif']);
    imwrite(show_img,[save_dir 'Two_character_N\edge',img_value '.tif']);
end
end