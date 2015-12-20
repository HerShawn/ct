function See_sw()
dir = 'E:\2011 ÏÔÖøĞÔÎÄ×Ö¼ì²â\database\sw2\';
for i = 7:249
    name = [dir num2str(i) '.txt'];
    data = dlmread(name);
    figure;imshow(data,[])
    close all
end
end