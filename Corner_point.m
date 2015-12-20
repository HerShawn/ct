function corner_candidate = Corner_point(img_gray,edge_img)
[h,w] = size(img_gray);
sigma = sqrt(2);
filterLength = 8*ceil(sigma);
n = (filterLength - 1)/2;
x = -n:n;
c = 1/(sqrt(2*pi)*sigma);
gaussKernel = c * exp(-(x.^2)/(2*sigma^2));
gaussKernel = gaussKernel/sum(gaussKernel);
gaussKernel_matrix = gaussKernel'*gaussKernel;
img_gray = imfilter(img_gray, gaussKernel_matrix, 'conv', 'replicate');
%% 找拐点
% 0 0 1    0 1 0    0 1 0    0 0 1   4  0 1 0    1 0 1
% 0 1 0    1 1 0    1 1 0    1 1 0      1 1 1    0 1 0
% 1 0 1    0 0 1    0 1 0    0 0 1      0 1 0    1 0 1
edge_img_extend = wextend('2', 'zpd',edge_img,1);
cross_point = zeros(h+2,w+2);
conv_img = conv2(single(edge_img_extend),[1 1 1;1 1 1;1 1 1],'same');
[rx,cx] = find(conv_img>4 & edge_img_extend);
for i = 1:length(rx)
    if (sum(edge_img_extend(rx(i)-1,cx(i))+edge_img_extend(rx(i)+1,cx(i))+edge_img_extend(rx(i),cx(i)-1)+edge_img_extend(rx(i),cx(i)+1)) == 4)
        cross_point(rx(i),cx(i)) = 1;
        cross_point(rx(i)-1,cx(i)) = 1;
        cross_point(rx(i)+1,cx(i)) = 1;
    else
        cross_point(rx(i),cx(i)) = 1;
    end
end
[rx,cx] = find(conv_img==4 & edge_img_extend);
for i = 1:length(rx)
    if (sum(edge_img_extend(rx(i)-1,cx(i)-1)+edge_img_extend(rx(i)+1,cx(i)+1)+edge_img_extend(rx(i)+1,cx(i)-1)+edge_img_extend(rx(i)-1,cx(i)+1)) == 3)
        cross_point(rx(i),cx(i)) = 1;
    elseif (sum(edge_img_extend(rx(i)-1,cx(i))+edge_img_extend(rx(i)+1,cx(i))+edge_img_extend(rx(i),cx(i)-1)+edge_img_extend(rx(i),cx(i)+1)) == 3)
        cross_point(rx(i),cx(i)) = 1;
        if (~edge_img_extend(rx(i)-1,cx(i)))
            cross_point(rx(i)+1,cx(i)) = 1;
        elseif (~edge_img_extend(rx(i)+1,cx(i)))
            cross_point(rx(i)-1,cx(i)) = 1;
        elseif (~edge_img_extend(rx(i),cx(i)-1))
            cross_point(rx(i),cx(i)+1) = 1;
        else
            cross_point(rx(i),cx(i)-1) = 1;
        end
    elseif (edge_img_extend(rx(i)-1,cx(i))&&edge_img_extend(rx(i)+1,cx(i)-1)&&edge_img_extend(rx(i)+1,cx(i)+1)) ||....
        (edge_img_extend(rx(i)+1,cx(i))&&edge_img_extend(rx(i)-1,cx(i)-1)&&edge_img_extend(rx(i)-1,cx(i)+1)) ||....
        (edge_img_extend(rx(i),cx(i)-1)&&edge_img_extend(rx(i)+1,cx(i)+1)&&edge_img_extend(rx(i)-1,cx(i)+1)) ||....
        (edge_img_extend(rx(i),cx(i)+1)&&edge_img_extend(rx(i)+1,cx(i)-1)&&edge_img_extend(rx(i)-1,cx(i)-1))
        cross_point(rx(i),cx(i)) = 1;
    elseif (edge_img_extend(rx(i),cx(i)-1)&&edge_img_extend(rx(i)-1,cx(i))&&edge_img_extend(rx(i)+1,cx(i)+1)) 
        cross_point(rx(i),cx(i)) = 1;
        cross_point(rx(i),cx(i)-1) = 1;
    elseif (edge_img_extend(rx(i),cx(i)+1)&&edge_img_extend(rx(i)-1,cx(i))&&edge_img_extend(rx(i)+1,cx(i)-1)) 
        cross_point(rx(i),cx(i)) = 1;
        cross_point(rx(i),cx(i)+1) = 1;
    elseif (edge_img_extend(rx(i)-1,cx(i)-1)&&edge_img_extend(rx(i),cx(i)+1)&&edge_img_extend(rx(i)+1,cx(i))) 
        cross_point(rx(i),cx(i)) = 1;
        cross_point(rx(i),cx(i)+1) = 1;
    elseif (edge_img_extend(rx(i),cx(i)-1)&&edge_img_extend(rx(i)+1,cx(i))&&edge_img_extend(rx(i)-1,cx(i)+1)) 
        cross_point(rx(i),cx(i)) = 1;
        cross_point(rx(i),cx(i)-1) = 1;
    end
end
cross_point = cross_point(2:end-1,2:end-1);
%% 计算角点
c1 = cornermetric(img_gray);
corner_candidate = c1>1e-6 & edge_img;
corner_endpoint = bwmorph(edge_img,'endpoints');   %计算结束点
[rx,cx] = find(corner_endpoint);
[rx_cross,cx_cross] = find(cross_point);
rx = [rx;rx_cross];
cx = [cx;cx_cross];
bw_end = bwselect(corner_candidate,cx,rx,8);
corner_candidate(bw_end) = 0;
corner_candidate = bwmorph(corner_candidate,'shrink',Inf);
[bw_label,num] = bwlabel(corner_candidate,8);
num_point = zeros(1,num);
for i = 1:h
    for j = 1:w
        if bw_label(i,j)
            num_point(bw_label(i,j)) = num_point(bw_label(i,j))+1;
        end
    end
end
for i = 1:num
    if num_point(i)>1
        [x,y]= find(bw_label == i);
        corner_candidate(x+(y-1)*h) = 0;
    end
end
corner_candidate = corner_candidate|cross_point;
end