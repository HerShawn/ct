for i = 12:249
    name_img1 = ['E:\2011 ÏÔÖøĞÔÎÄ×Ö¼ì²â\database\sw1\' num2str(i) '.txt'];
    a1 = dlmread(name_img1);
    figure;imshow(uint8(a1));
    name_img2 = ['E:\2011 ÏÔÖøĞÔÎÄ×Ö¼ì²â\database\sw2\' num2str(i) '.txt'];
    a2 = dlmread(name_img2);
    figure;imshow(uint8(a2));
    close all
end