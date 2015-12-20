function TrainRecogCharTogether()
%% 62个字母合在一起训练
clear
clc
%% 计算特征
% % % % for i = 1:62
% % % %     dirName = dir(['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\*.jpg']);
% % % %     for j = 1:length(dirName)
% % % %         imgName = ['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\' dirName(j).name];
% % % %         value = dirName(j).name;
% % % %         img = imread(imgName);
% % % %         [h,w,~] = size(img);
% % % %         value = value(1:end - 4);
% % % %         featureName = ['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\' value '.mat'];
% % % %         %         feature = ComputeFeature(img);
% % % %         %% 2013-4-23 modified
% % % %         img = imresize(img,[100 100]);
% % % %         feature = hog(im2single(img),25,4);
% % % %         feature = feature(:)';
% % % %         feature = [double(feature) h/w];
% % % %         save(featureName,'feature');
% % % %     end
% % % % end
% % % % % % dirName = dir(['E:\2013毕设文字检测\测试集\char一起训练\selected2\*.jpg']);
% % % % % % for j = 1:length(dirName)
% % % % % %     imgName = ['E:\2013毕设文字检测\测试集\char一起训练\selected2\' dirName(j).name];
% % % % % %     img = imread(imgName);
% % % % % %     [h,w,~] = size(img);
% % % % % %     value = dirName(j).name;
% % % % % %     value = value(1:end - 4);
% % % % % %     featureName = ['E:\2013毕设文字检测\测试集\char一起训练\selected2\' value '.mat'];
% % % % % %     %     feature = ComputeFeature(img);
% % % % % %     img = imresize(img,[100 100]);
% % % % % %     feature = hog(im2single(img),25,4);
% % % % % %     feature = feature(:)';
% % % % % %     feature = [double(feature) h/w];
% % % % % %     save(featureName,'feature');
% % % % % % end
%%
featureAll = [];
label = [];
for i = 1:62
    disp(i)
    dirName = dir(['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\*.mat']);
    for j = 1:length(dirName)
        featureName = ['E:\2013毕设文字检测\测试集\char一起训练\' num2str(i) '\' dirName(j).name];
        load(featureName,'feature');
        featureAll = [featureAll; feature];
        label = [label;i];
    end
end

dirName = dir ('E:\2013毕设文字检测\测试集\char一起训练\selected\*.mat');
numNegAll = length(dirName);
indexImg = ceil(rand(1,750)*numNegAll);
% indexImg = unique(indexImg);
for i = 1:length(indexImg)
% for i = 1:numNegAll
     load(['E:\2013毕设文字检测\测试集\char一起训练\selected\' dirName(indexImg(i)).name]);
%      load(['E:\2013毕设文字检测\测试集\char一起训练\selected2\' dirName(i).name]);
    featureAll = [featureAll; feature];
    label = [label;0];
end
model = classRF_train(featureAll,label);
%      model = svmtrain([featurePos; featureNeg],label);
fileName = ['E:\2013毕设文字检测\测试集\char一起训练\model13.mat'];
save(fileName, 'model')
end

function feature = ComputeFeature(img)
img = imresize(img, [130 130]);
img = im2double(img);
[~, magGrad, orientation] = Compute_edge(img);
feature = HogFeatureChar(magGrad,orientation);
end