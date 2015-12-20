function [mean_d, distribution, occupy_p, v, Gangle,occupy_own]= Stroke_attribute(cpoint_cell,cluster_label,corresp_new,h)
if nargin == 1
    zeros_index_v = cpoint_cell(:,7);
    orientation_v = cpoint_cell(:,6);
    distance_v = cpoint_cell(:,5);
    index_stroke = orientation_v<pi/3&~zeros_index_v;
    if sum(index_stroke)
        distance_v = distance_v(index_stroke);
        mean_d = median(distance_v);
        sigm = 1/5*mean_d;
        weight_w = exp(-1/2/sigm^2*(distance_v-mean_d).^2);
        weight_w = weight_w/sum(weight_w);
        distribution = sum(weight_w.*(distance_v - mean_d).^2)/mean_d;
        occupy_p = sum(index_stroke)/length(zeros_index_v);
        Gangle = sum(orientation_v(~zeros_index_v))/sum(~zeros_index_v);
        v = exp(-distribution/2)*(1-(occupy_p-1)^2);
    else
        mean_d = 0;
        distribution = inf;
        occupy_p = 0;
        v = 0;
        Gangle = inf;
    end
else
    y_location_p = cpoint_cell(:,3);
    x_location_p = cpoint_cell(:,4);
    index_point = y_location_p+(x_location_p-1)*h;
    index_corresp = find(index_point>0);
    index_point = index_point(index_corresp);
    label_point = cluster_label(index_point);
    num_corresp = length(corresp_new);
    flag = zeros(length(label_point),1);
    if ~isempty(flag)
        for i = 1:num_corresp
            flag = flag|(label_point == corresp_new(i));
        end
    end
    flag_own = zeros(length(y_location_p),1);
    flag_own(index_corresp) = flag;
    zeros_index_v = cpoint_cell(:,7);
    orientation_v = cpoint_cell(:,6);
    distance_v = cpoint_cell(:,5);
    index_stroke = orientation_v<pi/3&flag_own;
    if sum(index_stroke)
        distance_v = distance_v(index_stroke);
        mean_d = median(distance_v);
        sigm = 1/5*mean_d;
        weight_w = exp(-1/2/sigm^2*(distance_v-mean_d).^2);
        weight_w = weight_w/sum(weight_w);
        distribution = sum(weight_w.*(distance_v - mean_d).^2)/mean_d;
        occupy_p = sum(index_stroke)/length(zeros_index_v);
        occupy_own = sum(flag_own)/length(zeros_index_v);
        Gangle = sum(orientation_v(logical(flag_own)))/sum(~zeros_index_v);
        v = exp(-distribution/2)*(1-(occupy_p-1)^2);
    else
        mean_d = 0;
        distribution = inf;
        occupy_p = 0;
        occupy_own = 0;
        v = 0;
        Gangle = inf;
    end
end
end