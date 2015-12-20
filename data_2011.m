clear
clc
% dir_img = dir('\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\*.jpg');
% dir_txt = dir('\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\*.txt');
dir_img = dir('E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\*.jpg');
dir_txt = dir('E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\*.txt');
num_img = length(dir_img);
for i = 1:num_img
%     img_name = ['\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\' dir_img(i).name];
%     txt_name = ['\\tsclient\E\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\' dir_txt(i).name];
    img_name = ['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\' dir_img(i).name];
    txt_name = ['E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\' dir_txt(i).name];
    fid = fopen(txt_name);
    txt_data = textscan(fid,'%d,%d,%d,%d,%s');
    num_word = length(txt_data{1});
    loword = [];
    for j = 1:num_word
        re.left = txt_data{1}(j);
        re.top = txt_data{2}(j);
        re.right = txt_data{3}(j);
        re.bottom = txt_data{4}(j);
        re.w = re.right - re.left + 1;
        re.h = re.bottom - re.top + 1;
        loword=[loword re];
    end
    pp.name = img_name;
    pp.location = loword;
    imgprop{i}=pp;
    fclose(fid);
end
save imgprop2011_train.mat imgprop