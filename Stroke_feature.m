function [Gangle occupy_p] = Stroke_feature(cpoint_cell)
zeros_index_v = cpoint_cell(:,7);
orientation_v = cpoint_cell(:,6);
index_stroke = orientation_v<pi/3&~zeros_index_v;
occupy_p = sum(index_stroke)/length(zeros_index_v);
Gangle = sum(orientation_v(~zeros_index_v))/sum(~zeros_index_v);
end