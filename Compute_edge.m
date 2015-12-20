function [edge_img, magGrad, orientation, lowThresh, highThresh] = Compute_edge(img,sigma,locationSmall)
if nargin == 1
    sigma = sqrt(2);
    [magGrad,orientation,dx,dy] = GradientImg(img,sigma);
    magGrad = magGrad/max(magGrad(:));
elseif nargin == 2
    [magGrad,orientation,dx,dy] = GradientImg(img,sigma);
    magGrad = magGrad/max(magGrad(:));
    % % % % % %     [h,w,~] = size(img);
    % % % % % % %     sizeScale = ceil(h*w/1280*960);
    % % % % % %     h_inter = 960;
    % % % % % %     w_inter = 1200;
    % % % % % %     h_seg = ceil(h/h_inter);
    % % % % % %     w_seg = ceil(w/w_inter);
    % % % % % %     magGrad = zeros(h,w);
    % % % % % %     orientation = zeros(h,w);
    % % % % % %     dx = zeros(h,w);
    % % % % % %     dy = zeros(h,w);
    % % % % % %     for i = 1:h_seg
    % % % % % %         for j = 1:w_seg
    % % % % % %             left = max(1,(j-1)*w_inter-20);
    % % % % % %             top = max(1,(i-1)*h_inter-20);
    % % % % % %             right = min(w,j*w_inter+20);
    % % % % % %             bottom = min(h,i*h_inter+20);
    % % % % % %             img_sub = img(top:bottom,left:right,:);
    % % % % % %             [magGrad(top:bottom,left:right),orientation(top:bottom,left:right),dx(top:bottom,left:right),dy(top:bottom,left:right)] = GradientImg(img_sub,sigma);
    % % % % % %         end
    % % % % % %     end
    % % % % % %     magGrad = magGrad/max(magGrad(:));
else
    %     [h,w,~] = size(img);
    [magGrad,orientation,dx,dy] = GradientImg(img,sigma);
    numSmall = size(locationSmall,1);
    for i = 1:numSmall
        left = locationSmall(i,1);
        top = locationSmall(i,2);
        right = locationSmall(i,3);
        bottom = locationSmall(i,4);
        magGrad(top:bottom,left:right) = 0;
    end
    magGrad = magGrad/max(magGrad(:));
end
%% ¼ÆËããÐÖµ
lowThresh = graythresh(magGrad)*0.4;
highThresh = lowThresh/0.4;
edge_img = edge_canny(magGrad,dx,dy,lowThresh, highThresh);
edge_img = bwmorph(edge_img,'thin',Inf);
end

function [magGrad,orientation,dx,dy] = GradientImg(img,sigma)
[h,w,~] = size(img);
color = 1;
% sigma = sqrt(2);
if color
    magGrad = zeros(h,w);
    dx = zeros(h,w);
    dy = zeros(h,w);
    for j = 1:3
        [dx_t, dy_t] = smoothGradient(img(:,:,j), sigma);
        dx = dx+dx_t;
        dy = dy+dy_t;
        magGrad_t = hypot(dx_t, dy_t);
        %         magGrad = max(magGrad , magGrad_t);
        magGrad = magGrad + magGrad_t;
    end
    orientation = atan2(dy,dx);
else
    img_gray = rgb2gray(img);
    [dx, dy] = smoothGradient(img_gray, sqrt(2));
    magGrad = hypot(dx, dy);
    orientation = atan2(dy,dx);
end
end