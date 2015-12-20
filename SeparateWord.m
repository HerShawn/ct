function new_flag_chain = SeparateWord(characterprop, flag_chain)
num_character = length(flag_chain);
num_chain = max(flag_chain);
pchain = 0;
new_flag_chain = zeros(1,num_character);
for i = 1:num_chain
    [~ ,index_chain] = find(flag_chain == i);
    num_cc = length(index_chain);
    right = zeros(1,num_cc);
    left = zeros(1,num_cc);
    for j=1:num_cc
        right(j)= characterprop(index_chain(j)).right;
        left(j)= characterprop(index_chain(j)).left;
    end
    [left,position] = sort(left);
    right = right(position);
    disv=left(2:end)-right(1:end-1);
    disv(disv<0) = 0;
    meand = mean(disv);
    stdd = std(disv);
    p = 1.6;
    T = meand+p*stdd;
    stdd = std(disv(disv<T));
    T = meand+p*stdd;
    point_seg = find(disv>T);
    num_patch = length(point_seg)+1;
    point_seg = [0 point_seg num_cc];
    for j = 1:num_patch
        pchain = pchain + 1;
        
        flag_point = position(point_seg(j)+1:point_seg(j+1));
        new_flag_chain(index_chain(flag_point)) = pchain;
    end
end
end