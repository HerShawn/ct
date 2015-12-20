function bw_img = Niblack(img)
[h,w,~] = size(img);
ww = round(h/3);
gray_img = double(rgb2gray(img));
integ_img = integralImage(gray_img);
gray_img_sqrt = gray_img.^2;
integ_img_sqrt = integralImage(gray_img_sqrt);
bw_img = zeros(h,w);
k = 0.4;
for i = 1:h
    for j = 1:w
        if i == 200&&j == 200
        end
        left = max(j-ww,1);
        right = min(j+ww,w);
        top = max(i-ww,1);
        bottom = min(i+ww,h);
        N = (bottom-top+1)*(right-left+1);
        mean_v = (integ_img(bottom+1,right+1) - integ_img(bottom+1,left) - integ_img(top,right+1) + integ_img(top,left))/N;
        sqrt_v = integ_img_sqrt(bottom+1,right+1) - integ_img_sqrt(bottom+1,left) - integ_img_sqrt(top,right+1) + integ_img_sqrt(top,left);
        std_v = sqrt(sqrt_v/N - mean_v^2);
        th_high = mean_v + k*std_v;
        th_low = mean_v - k*std_v;
        if gray_img(i,j)>th_high
            bw_img(i,j) = 255;
        elseif gray_img(i,j)<th_low
            bw_img(i,j) = 0;
        else
            bw_img(i,j) = 100;
        end
    end
end
end