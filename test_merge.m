function test_merge()
%% ������Ҫ�ϲ��ı�Ե
new_corresp = 1:num_bw;   % ԭ��Ե���±�Ե�Ķ�Ӧ��ϵ
while (~isempty(index_edge))
    index_point = index_edge(1);  % ����ı�Ե����
    index_edge = index_edge(2:end);
    neighbor_v = neighbor_img{index_point};
    neighbor_v = unique(new_corresp(neighbor_v));
    flag_merge = index_point;
    flag_path_edge = index_point;    % �����������
    while (~isempty(neighbor_v))
        num_neighbor = length(neighbor_v);
        for k = 1:num_neighbor
            %% �ж�������Ե�Ƿ�ϲ�
            index_neighbor = neighbor_v(k);
            
            if (1)
                merge_flag = 1;
            else
                merge_flag = 0;
            end
            %% ����ϲ�
            if (merge_flag)
                index_edge(index_edge == index_neighbor) = [];
                new_corresp(index_neighbor) = index_point;
            end
        end
    end
end
end