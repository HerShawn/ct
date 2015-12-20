clear
clc
load imgprop.mat
es_location=dlmread('result.txt');
num_es=size(es_location,1);
num_gt=0;
v_p=0;
v_r=0;
precision_s = ones(1,249);
recall_s = zeros(1,249);
for i = 1:249
    imgword = imgprop{i}.word;
    w = imgprop{i}.loc.x;
    h = imgprop{i}.loc.y;
    k = length(imgword);
    num_gt = num_gt+k;
    location_es_img = es_location(es_location(:,1) == i,2:5);
    num_es_img = size(location_es_img,1);
    %     disp([num2str(i) ' : '  num2str(num_es_img) ])
    location_gt = zeros(k,4);
    for j = 1:k
        location_gt(j,:) = [max(imgword(j).x,1) max(imgword(j).y,1) min((imgword(j).x+imgword(j).w),w) min((imgword(j).y+imgword(j).h),h)];
    end
    tmpr = [];
    for ri = 1:k
        mp_v = zeros(1,num_es_img);
        for qi = 1:num_es_img
            intersection_left = max(location_es_img(qi,1),location_gt(ri,1));
            intersection_top = max(location_es_img(qi,2),location_gt(ri,2));
            intersection_right = min(location_es_img(qi,3),location_gt(ri,3));
            intersection_bottom = min(location_es_img(qi,4),location_gt(ri,4));
            num_intersection = max(intersection_right-intersection_left+1,0)*max(intersection_bottom-intersection_top+1,0);
            bounding_left = min(location_es_img(qi,1),location_gt(ri,1));
            bounding_top = min(location_es_img(qi,2),location_gt(ri,2));
            bounding_right = max(location_es_img(qi,3),location_gt(ri,3));
            bounding_bottom = max(location_es_img(qi,4),location_gt(ri,4));
            num_bounding = (bounding_right-bounding_left+1)*(bounding_bottom-bounding_top+1);
            mp = num_intersection/num_bounding;
            num_gt = (location_gt(ri,4)-location_gt(ri,2))*(location_gt(ri,3)-location_gt(ri,1));
            %             mp = num_intersection/num_gt;
            mp_v(qi) = mp;
        end
        m = max(mp_v);
        if m>= 0.8
            m = 1;
        end
        if ~isempty(m)
            tmpr = [tmpr m];
            v_r = v_r+m;
        end
    end
    if ~isempty(tmpr)
        recall_s(i) = mean(tmpr);
    end
    if num_es_img==0
        v_p = v_p+1;
        continue
    end
    tmpr = [];
    for pi = 1:num_es_img
        mp_v = zeros(1,k);
        for qi = 1:k
            intersection_left = max(location_es_img(pi,1),location_gt(qi,1));
            intersection_top = max(location_es_img(pi,2),location_gt(qi,2));
            intersection_right = min(location_es_img(pi,3),location_gt(qi,3));
            intersection_bottom = min(location_es_img(pi,4),location_gt(qi,4));
            num_intersection = max(intersection_right-intersection_left+1,0)*max(intersection_bottom-intersection_top+1,0);
            bounding_left = min(location_es_img(pi,1),location_gt(qi,1));
            bounding_top = min(location_es_img(pi,2),location_gt(qi,2));
            bounding_right = max(location_es_img(pi,3),location_gt(qi,3));
            bounding_bottom = max(location_es_img(pi,4),location_gt(qi,4));
            num_bounding = (bounding_right-bounding_left+1)*(bounding_bottom-bounding_top+1);
            num_es = (location_es_img(pi,4)-location_es_img(pi,2))*(location_es_img(pi,3)-location_es_img(pi,1));
            mp = num_intersection/num_bounding;
            mp_v(qi) = mp;
        end
        m = max(mp_v);
        if m>=0.8
            m = 1;
        end
        tmpr =[tmpr m];
        v_p = v_p+m;
    end
    precision_s(i) = mean(tmpr);
end
precision = mean(precision_s)
recall = mean(recall_s)
F = 2/(1/precision+1/recall)