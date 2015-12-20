function bw_img = Get_cc(cpoint_cell_p,cpoint_cell_n,color_edge,img,h,w)
num_edge = size(cpoint_cell_n,1);
bw_img = zeros(h,w);
img_r = img(:,:,1);
img_g = img(:,:,2);
img_b = img(:,:,3);
for i = 1:num_edge
    if i == 30
    end
    x_location = cpoint_cell_p{i}(:,2);
    y_location = cpoint_cell_p{i}(:,1);
    %% 连通区域坐标
    top_cc = min(y_location);
    bottom_cc = max(y_location);
    left_cc = min(x_location);
    right_cc = max(x_location);
    %%
    [~, ~, ~, v_p] = Stroke_attribute(cpoint_cell_p,i);
    [~, ~, ~, v_n] = Stroke_attribute(cpoint_cell_n,i);

    img_cc_r = img_r(top_cc:bottom_cc,left_cc:right_cc);
    img_cc_g = img_g(top_cc:bottom_cc,left_cc:right_cc);
    img_cc_b = img_b(top_cc:bottom_cc,left_cc:right_cc);
    
    std_r = std(img_cc_r(:));
    std_g = std(img_cc_g(:));
    std_b = std(img_cc_b(:));
    k = 1;
    if v_p>v_n
        img_cc_r = abs(img_cc_r-color_edge(i,1))<k*std_r;
        img_cc_g = abs(img_cc_g-color_edge(i,2))<k*std_g;
        img_cc_b = abs(img_cc_b-color_edge(i,3))<k*std_b;
    else
        img_cc_r = abs(img_cc_r-color_edge(i,4))<k*std_r;
        img_cc_g = abs(img_cc_g-color_edge(i,5))<k*std_g;
        img_cc_b = abs(img_cc_b-color_edge(i,6))<k*std_b;
    end
    
    bw_img(top_cc:bottom_cc,left_cc:right_cc) = bw_img(top_cc:bottom_cc,left_cc:right_cc)+(img_cc_r&img_cc_g&img_cc_b)*i;
end
end