function show_img = Kmeans_seg(cpoint_cell_p,img)
img_r = img(:,:,1);
img_g = img(:,:,2);
img_b = img(:,:,3);
for i = 416
    x_location = cpoint_cell_p{i}(:,2);
    y_location = cpoint_cell_p{i}(:,1);
    top_cc = min(y_location);
    bottom_cc = max(y_location);
    left_cc = min(x_location);
    right_cc = max(x_location);
    height_cc = bottom_cc - top_cc +1;
    width_cc = right_cc - left_cc +1;
    color_vec = zeros(height_cc*width_cc,3);
    img_cc_r = img_r(top_cc:bottom_cc,left_cc:right_cc);
    img_cc_g = img_g(top_cc:bottom_cc,left_cc:right_cc);
    img_cc_b = img_b(top_cc:bottom_cc,left_cc:right_cc);
    color_vec(:,1) = img_cc_r(:);
    color_vec(:,2) = img_cc_g(:);
    color_vec(:,3) = img_cc_b(:);
    [idx,ctrs] = kmeans(color_vec,2,'emptyaction','singleton');
    show_img = zeros(height_cc,width_cc);
    show_img(idx == 1) = 1;
end

end