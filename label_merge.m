clear
clc
close all
dir = 'E:\文字检测2012\测试集\ICADR 2003\testimg\自己标定\';
location = [];
for i =1:249
    resultname = [dir num2str(i) '.txt'];
    %     location_img = dlmread(resultname);
    txtdata = importdata(resultname);
    if ~isempty(txtdata)
        location_img = txtdata;
        location = [location; location_img];
    end
end
dlmwrite('location.txt',location);