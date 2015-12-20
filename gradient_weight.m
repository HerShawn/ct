function gradient_weight()
clear
clc
close all
dir = 'E:\文字检测2012\测试集\ICADR 2003\testimg\';

for i = 108
    % 计算梯度
    imgname = [dir num2str(i) '.jpg'];
    %     imgname = ['036' '.jpg'];
    img = imread(imgname);
    figure; imshow(img)
    img = im2single(img);
    sigma = sqrt(2);
    [h,w,~] = size(img);
    weight_map = zeros(h,w);
    img_gray = rgb2gray(img);
    [dx, dy] = smoothGradient(img_gray, sigma);
    magGrad = hypot(dx, dy);
    magGrad = magGrad/max(magGrad(:));
    % 计算阈值
    lowThresh = graythresh(magGrad);
    highThresh = lowThresh/0.4;
    figure;imshow(magGrad)
    %     figure;imshow(img)
    orientation = atan2(dy,dx);
    max_swidth = min(h,w)/6;
    E = magGrad > lowThresh;
    [cstrong,rstrong] = find(magGrad>highThresh);
    H = bwselect(E, rstrong, cstrong, 8);
    direction_a = ones(h,w)*(-1);
    direction_a = direction_a + double((orientation<=1/4*pi&&orientation>-pi/4));
    direction_a = direction_a + 2*double((orientation_p<=3/4*pi&&orientation_p>pi/4));
    direction_a = direction_a + 3*double((orientation_p>3/4*pi)||(orientation_p<=-3/4*pi));
    direction_a = direction_a + 4*double((orientation_p<=-1/4*pi&&orientation_p>-3/4*pi));
    for m = 1:h
        for n = 1:w
            if H(m,n)
                orientation_p = orientation(m,n);
                %                 if(orientation_p<=1/4*pi&&orientation_p>-pi/4)
                %                     direction = 0;
                %                 elseif(orientation_p<=3/4*pi&&orientation_p>pi/4)
                %                     direction= 1;
                %                 elseif(orientation_p>3/4*pi)||(orientation_p<=-3/4*pi)
                %                     direction= 2;
                %                 elseif(orientation_p<=-1/4*pi&&orientation_p>-3/4*pi)
                %                     direction= 3;
                %                 end
                direction = direction_a(m,n);
                for d_direction = 1:2
                    direction = mod(direction+(d_direction-1)*2,4);
                    orientation_p = orientation_p+pi*(d_direction-1);
                    switch direction
                        case 0
                            x_d  = round(cos(orientation_p)*max_swidth);
                            x_location = n:min(n+x_d,w);
                            y_location = round(tan(orientation_p)*(x_location-n)+m);
                            idx_location = find(y_location<h&y_location>1);
                            x_location = x_location(idx_location);
                            y_location = y_location(idx_location);
                        case 1
                            y_d  = round(sin(orientation_p)*max_swidth);
                            y_location = m:min(m+y_d,h);
                            x_location = round((y_location-m)/tan(orientation_p)+n);
                            idx_location = find(x_location<w&x_location>1);
                            x_location = x_location(idx_location);
                            y_location = y_location(idx_location);
                        case 2
                            x_d  = round(cos(orientation_p)*max_swidth);
                            x_location = fliplr(max(n+x_d,1):n);
                            y_location = round(tan(orientation_p)*(x_location-n)+m);
                            idx_location = find(y_location<h&y_location>1);
                            x_location = x_location(idx_location);
                            y_location = y_location(idx_location);
                        case 3
                            y_d  = round(sin(orientation_p)*max_swidth);
                            y_location = fliplr(max(m+y_d,1):m);
                            x_location = round((y_location-m)/tan(orientation_p)+n);
                            idx_location = find(x_location<w & x_location>1);
                            x_location = x_location(idx_location);
                            y_location = y_location(idx_location);
                    end
                    orientation_p = orientation_p-pi*(d_direction-1);
                    % 走过路径的梯度值
                    grad_path = magGrad((x_location-1)*h+y_location);
                    grad_path_max = grad_path>(highThresh+lowThresh)/2;
                    grad_path_diff = cumsum(abs(diff(grad_path_max)));
                    grad_path_diff = grad_path_diff-2;
                    grad_path_diff(grad_path_diff<0) = 15;
                    grad_path_diff = [15 grad_path_diff];
                    % 走过路径的方向值
                    orientation_path = orientation((x_location-1)*h+y_location);
                    orientation_diff = mod(abs(orientation_path-orientation_p-pi),2*pi);
                    orientation_diff = min(orientation_diff,2*pi-orientation_diff);
                    dissimilarity = exp(-orientation_diff).*exp(-grad_path_diff).*exp((magGrad(m,n)-grad_path).^2);
                    if ~isempty(grad_path)
                        weight_map(m,n) = max(double(max(dissimilarity)),weight_map(m,n));
                    end
                    if( m == 776 && n == 123)
                    end
                end
            end
        end
    end
    idx_weight = find(weight_map>0);
    neighbour = zeros(length(idx_weight),4);
    for m = 1:length(idx_weight)
        orientation_point = orientation(idx_weight(m));
        v = mod(idx_weight,h);
        extIdx = (v==1 | v==0 | idx<=h | (idx>(w-1)*h));
        if ~extIdx
            if direction(m) == 0
                neighbour(m,1)= direction(m);
                neighbour(m,2)= ;
                neighbour(m,3)= ;
                neighbour(m,4)= ;
            elseif direction(m) == 1
                neighbour(m,1)= direction(m);
                neighbour(m,2)= ;
                neighbour(m,3)= ;
                neighbour(m,4)= ;
            elseif direction(m) == 2
                neighbour(m,1)= direction(m);
                neighbour(m,2)= ;
                neighbour(m,3)= ;
                neighbour(m,4)= ;
            elseif direction(m) == 3
                neighbour(m,1)= direction(m);
                neighbour(m,2)= ;
                neighbour(m,3)= ;
                neighbour(m,4)= ;
            end
        end
    end
    figure;imshow(weight_map)
    figure;imshow(weight_map.*magGrad)
end
end

function [lowThresh, highThresh] = selectThresholds(magGrad)

PercentOfPixelsNotEdges = .9; % Used for selecting thresholds
ThresholdRatio = .4;          % Low thresh is this fraction of the high.
[m,n] = size(magGrad);
counts=imhist(magGrad, 64);
highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
    1,'first') / 64;
lowThresh = ThresholdRatio*highThresh;
end