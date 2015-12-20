function feature = Compute_HogFeature(img)
% if dim == 3
%     img = rgb2gray(img);
% end
img = imresize(img,[24 24*3]);
[h,w,~] = size(img);
img_gray = rgb2gray(img);
img_gray = im2double(img_gray);
% h_inter = 960;
% w_inter = 1200;
% h_seg = ceil(h/h_inter);
% w_seg = ceil(w/w_inter);
% magGrad = zeros(h,w);
% orientation = zeros(h,w);
% dx = zeros(h,w);
% dy = zeros(h,w);
% for i = 1:h_seg
%     for j = 1:w_seg
%         left = max(1,(j-1)*w_inter-20);
%         top = max(1,(i-1)*h_inter-20);
%         right = min(w,j*w_inter+20);
%         bottom = min(h,i*h_inter+20);
%         img_sub = img(top:bottom,left:right,:);
%         [magGrad(top:bottom,left:right),orientation(top:bottom,left:right),dx(top:bottom,left:right),dy(top:bottom,left:right)] = GradientImg(img_sub);
%     end
% end
[magGrad,orientation,~,~] = GradientImg(img_gray);
% magGrad = magGrad/max(magGrad(:));
% magGrad = magGrad/3;
feature = HogFeature(magGrad,img_gray,orientation);
end

function [magGrad,orientation,dx,dy] = GradientImg(img)
[h,w,~] = size(img);
color = 0;
op = fspecial('sobel')/8; % Sobel approximation to derivative
x_mask = op'; % gradient in the X direction
y_mask = op;
if color
    magGrad = zeros(h,w);
    dx = zeros(h,w);
    dy = zeros(h,w);
    for j = 1:3
        dx_t = imfilter(img(:,:,j),x_mask,'replicate');
        dy_t = imfilter(img(:,:,j),y_mask,'replicate');
        dx = dx+dx_t;
        dy = dy+dy_t;
        magGrad_t = hypot(dx_t, dy_t);
        magGrad = magGrad + magGrad_t;
    end
    orientation = atan2(dy,dx);
else
%     img_gray = rgb2gray(img);
    dx = imfilter(img,x_mask,'replicate');
    dy = imfilter(img,y_mask,'replicate');
    magGrad = hypot(dx, dy);
    orientation = atan2(dy,dx);
end
end