function PlotChain(cpoint_cell,flag_chain,img)
[h,w,~] = size(img);
show_img = ones(h,w,3);
num_chain1 = max(flag_chain);
num_chain2 = sum(flag_chain==0);
num_chain = num_chain1 + num_chain2;
num_character = length(flag_chain);
color = rand(num_chain,3);
k = num_chain1;
for i = 1:num_character
    if flag_chain(i)
        location_x = cpoint_cell{i}(:,2);
        location_y = cpoint_cell{i}(:,1);
        for j = 1:length(location_x)
            show_img(location_y(j),location_x(j),1) = color(flag_chain(i),1);
            show_img(location_y(j),location_x(j),2) = color(flag_chain(i),2);
            show_img(location_y(j),location_x(j),3) = color(flag_chain(i),3);
        end
    else
        k = k+1;
        location_x = cpoint_cell{i}(:,2);
        location_y = cpoint_cell{i}(:,1);
        for j = 1:length(location_x)
            show_img(location_y(j),location_x(j),1) = color(k,1);
            show_img(location_y(j),location_x(j),2) = color(k,2);
            show_img(location_y(j),location_x(j),3) = color(k,3);
        end
    end
end
figure;imshow(show_img)
end