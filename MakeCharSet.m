clear
clc
dirSourGround = 'G:\数据\孟泉代码\代码\毕设文字检测\测试集\ICDAR 2013Text Segmentation Ground Truth Information';
dirSourImg = 'G:\数据\孟泉代码\代码\毕设文字检测\测试集\Text Segmentation_Training_Task12_Images';
imgDesDir = 'G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\';

for i = 1:62
    dirsub = rmdir([imgDesDir num2str(i) '\'],'s');
    %     for j = 1:length(dirsub)
    %         rmdir([imgDesDir num2str(i) '\' dirsub(j).name],'s');
    %     end
end
for i = 1:62
    dirname=[imgDesDir num2str(i) '\'];%新的文件夹名
    a=['mkdir ' dirname];%创建命令
    system(a) %创建文件夹
end
for i = 100:328
    gtTxtName = [dirSourGround '\' num2str(i) '_GT.txt'];
    imgName = [dirSourImg '\' num2str(i) '.jpg'];
    img = imread(imgName);
    fid = fopen(gtTxtName);
    txtData = textscan(fid,'%s');
    k = 1;
    while (k<length(txtData{1}))
        if (strcmp(txtData{1}{k},'"')&&strcmp(txtData{1}{k+1},'"'))
            txtData{1}(k) = [];
        else
            k=k+1;
        end
    end
    fclose(fid);
    num_gt = length(txtData{1})/10;
    for j = 1:num_gt
        disp([i j])
        charValue = txtData{1}(j*10);
        if length(charValue{1})<3
            continue;
        end
        charValue = charValue{1}(2);
        charValue = int8(charValue);
        left = str2double(txtData{1}((j-1)*10+6))+1;
        top = str2double(txtData{1}((j-1)*10+7))+1;
        right = str2double(txtData{1}((j-1)*10+8))+1;
        bottom = str2double(txtData{1}((j-1)*10+9))+1;
        subImg = img(top:bottom,left:right,:);
        
        if (charValue<=57&&charValue>=48)
            subNum = charValue-48+1;
            dirsub = dir([imgDesDir num2str(subNum) '\*.jpg']);
            subIndex = length(dirsub) + 1;
        elseif (charValue<=90&&charValue>=65)
            subNum = charValue-65+11;
            dirsub = dir([imgDesDir num2str(subNum) '\*.jpg']);
            subIndex = length(dirsub) + 1;
        elseif (charValue<=122&&charValue>=97)
            subNum = charValue-97+37;
            dirsub = dir([imgDesDir num2str(subNum) '\*.jpg']);
            subIndex = length(dirsub) + 1;
        else
            continue
        end
        subImgName = [imgDesDir num2str(subNum) '\' num2str(subIndex) '.jpg'];
        imwrite(subImg, subImgName);
    end
end