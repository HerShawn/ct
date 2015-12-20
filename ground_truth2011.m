clear
clc
% dir_img = dir('\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\*.jpg');
% dir_txt = dir('\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\*.txt');
dir_img = dir('E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\*.jpg');
dir_txt = dir('E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\*.txt');
num_img = length(dir_img);
for i = 24:num_img
%     img_name = ['\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\' dir_img(i).name];
%     txt_name = ['\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\' dir_txt(i).name];
    img_name = ['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\' dir_img(i).name];
    txt_name = ['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\test-textloc-gt\' dir_txt(i).name];
    img = imread(img_name);
    [h,w,~] = size(img);
    bw_img = zeros(h,w);
    color_img = zeros(h,w,3);
    fid = fopen(txt_name);
    txt_data = textscan(fid,'%d,%d,%d,%d,%s');
    num_word = length(txt_data{2});
    loword = [];
    for j = 1:num_word
        left = txt_data{1}(j);
        top = txt_data{2}(j);
        right = txt_data{3}(j);
        bottom = txt_data{4}(j);
        bw_img(top:bottom,left:right) = 1;
        color_img(top:bottom,left:right,:) = img(top:bottom,left:right,:);
    end
    imwrite(bw_img,['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\gt\bw' dir_img(i).name]);
    imwrite(uint8(color_img),['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\gt\color' dir_img(i).name]);
    fclose(fid);
end
