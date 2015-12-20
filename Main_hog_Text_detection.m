function Main_hog_Text_detection()
load train_hog2011.mat
dir_file = 'E:\2012 ÎÄ×Ö¼ì²â\²âÊÔ¼¯\ICDAR 2011\train-textloc\';
dir_img = dir([dir_file '*.jpg']);
num_img = length(dir_img);
for i = 1:num_img
    disp(['start compute ' num2str(i)])
    img_name = [dir_file dir_img(i).name];
    img = imread(img_name);
    [h,w,~] = size(img);
    CfImg = Compute_Confidence(img, RLearners, RWeights);
    level = floor(min([log2(h/24),log2(w/72)]));
    for i = 1:level
        img = impyramid(img,'reduce');
        confidenceImg = Compute_Confidence(img, RLearners, RWeights);
        confidenceImg = imresize(confidenceImg,[h,w]);
        CfImg = CfImg+confidenceImg;
    end
end
end
function confidenceImg = Compute_Confidence(img, RLearners, RWeights)
[h,w,~] = size(img);
confidenceImg = zeros(h,w);
for i = 1:h-23
    for j = 1:w-24*3-1
        left = j;
        right = j+24*3-1;
        top = i;
        bottom = i+24-1;
        sub_img = img(top:bottom,left:right,:);
        feature = Compute_HogFeature(sub_img);
        ResultR = Classify(RLearners, RWeights, feature');
        confidenceImg(top:bottom,left:right) = confidenceImg(top:bottom,left:right) + ResultR;
    end
end
end