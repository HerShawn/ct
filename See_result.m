close all
for img_index = 1:249
    if ~sum(img_index == [206 217 222 226])
        img = imread(['E:\2012 ���ּ��\���Լ�\ICADR 2003\testimg\' num2str(img_index) '.jpg']);
        result_img = imread(['E:\2012 ���ּ��\ʵ����\���Խ��\rgb_result' num2str(img_index) '.jpg']);
        subplot(1,2,1); imshow(img)
        subplot(1,2,2);imshow(result_img)
    end
    close
end