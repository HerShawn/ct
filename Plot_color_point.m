function Plot_color_point(path,index_point,magGrad,th_d)
figure;imshow(magGrad)
hold on
path_edge_v1 = path{index_point};
num_point = size(path_edge_v1,1);
for p = 1:num_point
    path_py_v = path_edge_v1{p,1};
    path_px_v = path_edge_v1{p,2};
    if (~isempty(path_py_v))
        distance_v = sqrt((path_py_v-path_py_v(1)).^2+(path_px_v-path_px_v(1)).^2);
        path_py_v = path_edge_v1{p,1};
        path_px_v = path_edge_v1{p,2};
               
        index_v = distance_v<th_d;
        path_py_v_1 = path_py_v(index_v);
        path_px_v_1 = path_px_v(index_v);
        path_py_v_2 = path_py_v(~index_v);
        path_px_v_2 = path_px_v(~index_v);
        
        plot(path_px_v_1,path_py_v_1,'b*')
        hold on
        plot(path_px_v_2,path_py_v_2,'r*')
        hold on
    end
end
end