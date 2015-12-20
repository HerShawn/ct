nameList = {};
k = 1;
for i = 1:62
    dirName = dir(['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\*.jpg']);
    for j = 1:length(dirName)
        imgName = ['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\' dirName(j).name];
        nameList{k} = imgName;
        k = k+1;
    end
end
index = ceil(rand(5,10)*length(nameList));
imgAll = zeros(500,1000,3);
for i = 1:5
    for j = 1:10
        img = imread(nameList{index(i,j)});
        img = imresize(img,[100 100]);
        imgAll((i-1)*100+1:i*100,(j-1)*100+1:j*100,:) = img;
    end
end
figure;imshow(uint8(imgAll))

nameList = dir(['E:\2013毕设文字检测\测试集\char一起训练\neg\*.jpg']);

index = ceil(rand(5,10)*length(nameList));
imgAll = zeros(500,1000,3);
for i = 1:5
    for j = 1:10
        img = imread(['E:\2013毕设文字检测\测试集\char一起训练\neg\'  nameList(index(i,j)).name]);
        img = imresize(img,[100 100]);
        imgAll((i-1)*100+1:i*100,(j-1)*100+1:j*100,:) = img;
    end
end
figure;imshow(uint8(imgAll))