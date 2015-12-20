function TrainRecogChar()
clear
clc
%% 计算特征
% for i = 1:62
%     dirName = dir(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(i) '\*.jpg']);
%     for j = 1:length(dirName)
%         imgName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(i) '\' dirName(j).name];
%         value = dirName(j).name;
%         img = imread(imgName);
%         [h,w,~] = size(img);
%         value = value(1:end - 4);
%         featureName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(i) '\' value '.mat'];
%         %         feature = ComputeFeature(img);
%         %% 2013-4-23 modified
%         img = imresize(img,[100 100]);
%         feature = hog(im2single(img));
%         feature = feature(:)';
%         feature = [double(feature) h/w];
%         save(featureName,'feature');
%     end
% end
% dirName = dir(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\*.jpg']);
% for j = 1:length(dirName)
%     imgName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\' dirName(j).name];
%     img = imread(imgName);
%     [h,w,~] = size(img);
%     value = dirName(j).name;
%     value = value(1:end - 4);
%     featureName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\' value '.mat'];
%     %     feature = ComputeFeature(img);
%     img = imresize(img,[100 100]);
%     feature = hog(im2single(img));
%     feature = feature(:)';
%     feature = [double(feature) h/w];
%     save(featureName,'feature');
% end
%%

for i = [28:62]
    disp(i)
    dirName = dir(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(i) '\*.mat']);
    featurePos = [];
    for j = 1:length(dirName)
        featureName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(i) '\' dirName(j).name];
        load(featureName,'feature');
        featurePos = [featurePos; feature];
    end
    numPos = length(dirName);
    numNegChar = numPos*3;
    numNegNonChar = numPos*2;
    featureNameAll = {};
    for j = [28:62]
        if (j~=i)
            dirName = dir(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(j) '\*.mat']);
            for k = 1:length(dirName)
                featureNameAll = [featureNameAll; ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(j) '\' dirName(k).name]];
            end
        end
    end
    numNegAll = length(featureNameAll);
    indexNeg = ceil(rand(1,numNegChar)*numNegAll);
    featureNeg = [];
    for j = 1:numNegChar
        load(featureNameAll{indexNeg(j)});
        featureNeg = [featureNeg; feature ];
    end
    dirName = dir ('G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\*.mat');
    numNegAll = length(dirName);
    indexNeg = ceil(rand(1,numNegNonChar)*numNegAll);
    for j = 1:numNegNonChar
        load(['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\neg\' num2str(indexNeg(j)) '.mat']);
        featureNeg = [featureNeg; feature ];
    end
    label = [ones(1,numPos) zeros(1,numNegChar + numNegNonChar)];
    model = classRF_train([featurePos; featureNeg],label);
    %      model = svmtrain([featurePos; featureNeg],label);
    fileName = ['G:\数据\孟泉代码\代码\毕设文字检测\测试集\char\' num2str(i) '.mat'];
    save(fileName, 'model')
end
end

function feature = ComputeFeature(img)
img = imresize(img, [130 130]);
img = im2double(img);
[~, magGrad, orientation] = Compute_edge(img);
feature = HogFeatureChar(magGrad,orientation);
end