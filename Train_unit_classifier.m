function Train_unit_classifier()
addpath(genpath(pwd));
dir = 'E:\2012 文字检测\实验结果\训练结果2011\';
positive_index = dlmread('positive.txt');
negative_index = dlmread('negative.txt');
positive_feature = [];
negative_feature = [];
for i = 1:229
    label_img = load([dir 'label' num2str(i) '.mat']);
    feature_img = load([dir 'feature' num2str(i) '.mat']);
    if sum(positive_index == i)
        positive_feature = [positive_feature feature_img.feature_vector(:,logical(label_img.flag_pn))];
    end
    if sum(negative_index == i)
        negative_feature = [negative_feature feature_img.feature_vector(:,~logical(label_img.flag_pn))];
    end
end
num_positive = 1000;
num_negative = 3000;
index_positive = train_data_index(size(positive_feature,2), num_positive);
index_negative = train_data_index(size(negative_feature,2), num_negative);
positive_feature_train = positive_feature([1 5:10],index_positive);
negative_feature_train = negative_feature([1 5:10],index_negative);
inputs = [positive_feature_train negative_feature_train];
outputs = [ones(1,size(positive_feature_train,2)) -ones(1,size(negative_feature_train,2))];
model = classRF_train(inputs',outputs',100);
train_vote = double(model.votes);
rmpath(genpath(pwd));

end


function index = train_data_index(num_all, num_target)
index = max(1,round(rand(1,num_target)*num_all));
index = unique(index);
num = length(index);
while num~=num_target
    index = [index round(rand(1,num_target-num)*num_all)];
    index = unique(index);
    num = length(index);
end
end