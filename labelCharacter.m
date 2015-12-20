clear
clc
close all
img_dir = 'E:\2012 文字提取项目\代码仿真\测试集\自然场景\';
img_name = dir('E:\2012 文字提取项目\代码仿真\测试集\自然场景\*.jpg');
for i = 1:length(img_name)
    location = [];
    imgname = [img_dir img_name(i).name];
    resultname = [img_dir num2str(i) '.txt'];
    img = imread(imgname);
    figure;imshow(img)
    title(num2str(i))
    k = waitforbuttonpress;
    while(~k)
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions
        x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
        y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
        hold on
        plot(x,y)
        k = waitforbuttonpress;
        location = [location; i point1(1) point1(2) point2(1) point2(2)];
    end
    close
    dlmwrite(resultname,location);
end