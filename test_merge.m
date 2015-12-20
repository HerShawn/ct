function test_merge()
%% 查找需要合并的边缘
new_corresp = 1:num_bw;   % 原边缘和新边缘的对应关系
while (~isempty(index_edge))
    index_point = index_edge(1);  % 处理的边缘索引
    index_edge = index_edge(2:end);
    neighbor_v = neighbor_img{index_point};
    neighbor_v = unique(new_corresp(neighbor_v));
    flag_merge = index_point;
    flag_path_edge = index_point;    % 处理过的邻域
    while (~isempty(neighbor_v))
        num_neighbor = length(neighbor_v);
        for k = 1:num_neighbor
            %% 判断两个边缘是否合并
            index_neighbor = neighbor_v(k);
            
            if (1)
                merge_flag = 1;
            else
                merge_flag = 0;
            end
            %% 如果合并
            if (merge_flag)
                index_edge(index_edge == index_neighbor) = [];
                new_corresp(index_neighbor) = index_point;
            end
        end
    end
end
end