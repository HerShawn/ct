clc
clear
% dir_img = dir('G:\数据\icdar2011\test-textloc\*.jpg');
% num_img = length(dir_img);
% for indexImg = 1:num_img
%      img_value = dir_img(indexImg).name;
%     img_value = img_value(1:end-4);
%     
%     txt_name = ['G:\数据\icdar2011\test-textloc\' img_value '.txt'];
%     fid = fopen(txt_name);
%     txt_data = textscan(fid,'%d,%d,%d,%d,%s');
%     fclose(fid);
% end
txtName = 'G:\数据\icdar2011\test-textloc\gt_101.txt';
fid = fopen(txtName);
txt_data = textscan(fid,'%d,%d,%d,%d,%s');
groundtruth.left=txt_data{:,1};
groundtruth.top =txt_data{:,2};
groundtruth.right=txt_data{:,3};
groundtruth.down=txt_data{:,4};
save('G:\数据\icdar2011\test-textloc\gt_101.mat','groundtruth');
% imwrite(img,[save_dir 'detection\' img_value '.mat']);
fclose(fid);