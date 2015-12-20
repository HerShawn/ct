function max_label_dis = test_xx(label_path,edge_path,grad_path)
index_zero = label_path == 0;
norm_label = [0 diff(label_path)~=0];
norm_label(index_zero) = 0;
num_each_label = find(norm_label);    %每一个类出现的位置
norm_label = cumsum(norm_label);
norm_label(index_zero) = 0;
% num_label = length(num_each_label);
extr_point = edge_path;
extr_point(1) = 0;
index_edge = find(extr_point~=0);
for i = 1:length(index_edge)
    value_edge = norm_label(index_edge(i));
    norm_label(norm_label == value_edge) = 0;
end
data_point = unique(norm_label);
data_point = data_point(data_point~=0);
for i = 1:length(data_point)
    [~,index_max]= max(grad_path(norm_label == data_point(i)));
    extr_point(index_max+num_each_label(data_point(i))-1) = 1;
end
max_label_dis = find(extr_point);        
[~,max_label_dis] = sort(max_label_dis);
end