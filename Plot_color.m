function Plot_color(img)
dim = ndims(img);
if dim == 2
    [h,w] = size(img);
    num_value = max(max(img));
    color_v = rand(num_value,3);
    %     show_img_r = zeros(h,w);
    %     show_img_g = zeros(h,w);
    %     show_img_b = zeros(h,w);
%     show_img = zeros(h,w,3);
    show_img = ones(h,w,3)*255;
    for i = 1:h
        for j = 1:w
            index = img(i,j);
            if index == 0
%                 show_img(i,j,1) = 0;
%                 show_img(i,j,2) = 0;
%                 show_img(i,j,3) = 0;
            else
                %             show_img(i,j,:) = reshape(color_v(index,:),[1 1 3]);
                show_img(i,j,1) = color_v(index,1);
                show_img(i,j,2) = color_v(index,2);
                show_img(i,j,3) = color_v(index,3);
            end
        end
    end
    %     for i = 1:num_value
    %             show_img_r(img == i) = color_v(1);
    %             show_img_g(img == i) = color_v(2);
    %             show_img_b(img == i) = color_v(3);
    %     end
    %     show_img = cat(3,show_img_r,show_img_g,show_img_b);
    figure;imshow(show_img)
end
end