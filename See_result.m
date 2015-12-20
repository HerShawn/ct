close all
for img_index = 1:249
    if ~sum(img_index == [206 217 222 226])
        img = imread(['E:\2012 文字检测\测试集\ICADR 2003\testimg\' num2str(img_index) '.jpg']);
        result_img = imread(['E:\2012 文字检测\实验结果\测试结果\rgb_result' num2str(img_index) '.jpg']);
        subplot(1,2,1); imshow(img)
        subplot(1,2,2);imshow(result_img)
    end
    close
end