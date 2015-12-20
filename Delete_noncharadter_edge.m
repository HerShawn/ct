function [cpoint_cell_p,cpoint_cell_n,flag_edge,feature_vector] = Compute_feature(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,h)
num_edge = length(cpoint_cell_p);
flag_edge = zeros(1,num_edge);
num_feature = 10;
feature_vector = zeros(num_feature,num_edge);
for i = 1:num_edge
    x_location = cpoint_cell_p{i}(:,2);
    y_location = cpoint_cell_p{i}(:,1);
    top_cc = min(y_location);
    bottom_cc = max(y_location);
    left_cc = min(x_location);
    right_cc = max(x_location);
    height_cc = bottom_cc-top_cc+1;
    width_cc = right_cc-left_cc+1;
    [stroke_width_p, ~, occupy_p, v_p,Gangle_p, occupy_own_p]= Stroke_attribute(cpoint_cell_p{i},cluster_label,corresp_new{i},h);
    if i == 33
    end
    [stroke_width_n, ~, occupy_n, v_n, Gangle_n, occupy_own_n]= Stroke_attribute(cpoint_cell_n{i},cluster_label,corresp_new{i},h);
    if v_p>v_n
        stroke_width = stroke_width_p;
        stroke_prop = v_p;
        Gangle = Gangle_p;
        occupy = occupy_p;
        occupy_own = occupy_own_p;
    else
        stroke_width = stroke_width_n;
        stroke_prop = v_n;
        Gangle = Gangle_n;
        occupy = occupy_n;
        occupy_own = occupy_own_n;
    end
    num_point = size(cpoint_cell_p{i},1);

    
    
    width_stroke = width_cc/stroke_width;
    height_stroke = height_cc/stroke_width;
    width_height = max(width_cc/height_cc,height_cc/width_cc);
    feature_vector(1,i) = stroke_prop;
    feature_vector(2,i) = height_cc;
    feature_vector(3,i) = width_cc;
    feature_vector(4,i) = num_point;
    feature_vector(5,i) = width_stroke;
    feature_vector(6,i) = height_stroke;
    feature_vector(7,i) = width_height;
    feature_vector(8,i) = Gangle;
    feature_vector(9,i) = occupy;
    feature_vector(10,i) = occupy_own;
%     feature_vector(10,i) = ;
%     if stroke_prop>0.8&&((width_stroke<10&&width_stroke>5)||(height_stroke<10&&height_stroke>5))
%         flag_edge(i) = 1;
%     end
end
end