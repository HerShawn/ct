clear
clc
close all
dir = 'E:\���ּ��2012\���Լ�\ICADR 2003\testimg\�Լ��궨\';
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