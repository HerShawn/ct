clear
clc
flag_merge_p = [0 3 2 2 0 4 0 9 0 9];
num_edge = length(flag_merge_p);
k = 0;
positive_vec = {};
flag_sub = 1:num_edge;
for i = 1:num_edge
    if flag_merge_p(i)
        k = k+1;
        vec = [i flag_merge_p(i)];
        flag_merge_p(i) = 0;
        index_v = [];
        for p = 1:length(vec)
            index_v = [index_v find(flag_merge_p == vec(p))];
        end
        index_v = [index_v vec(find(flag_merge_p(vec)))];
        while(~isempty(index_v))
            flag_merge_p(index_v) = 0;
            vec = [vec index_v];
            vec = unique(vec);
            index_v = [];
            for p = 1:length(vec)
                index_v = [index_v find(flag_merge_p == vec(p))];
            end
            index_v = [index_v vec(find(flag_merge_p(vec)))];
        end
        positive_vec{k} = vec;
    end
end