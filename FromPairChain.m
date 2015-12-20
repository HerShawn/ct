function flag_chain = FromPairChain(labelMerging, numCC)
flag_chain = zeros(1,numCC);
k = 0;
labelMergingTmp = labelMerging;
while ~isempty(labelMergingTmp)
    k = k+1;
    value1 = labelMergingTmp(1,1);
    value2 = labelMergingTmp(1,2);
    labelMergingTmp = labelMergingTmp(2:end,:);
    flag_chain(value1) = k;
    flag_chain(value2) = k;
    vec = [value1 value2];
    while ~isempty(vec)
        index_x = [];
        for i = 1:length(vec)
            [index1_x, ~] = find(labelMergingTmp == vec(i));
            if ~isempty(index1_x)
                index_x = [index_x;index1_x];
            end
        end
        vec_tmp = labelMergingTmp(index_x,:);
        vec = vec_tmp(:);
        vec = unique(vec);
        flag_chain(vec) = k;
        labelMergingTmp(index_x,:) = [];
    end
end
for i = 1:numCC
    if ~flag_chain(i)
        flag_chain(i) = k+1;
        k = k+1;
    end
end
end