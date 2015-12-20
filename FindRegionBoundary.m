function neighbor_img = FindRegionBoundary(label)
num_label = max(label(:));
boundary_map = cell(num_label,1);
[h,w] = size(label);
label_extend = wextend('2','zpd',label,1);
for i = 2:h+1
    for j = 2:w+1
        if label_extend(i,j)
            if label_extend(i,j)~=label_extend(i,j-1)
                boundary_map{label_extend(i,j)} = [boundary_map{label_extend(i,j)};i j-1];
            end
            if label_extend(i,j)~=label_extend(i,j+1)
                boundary_map{label_extend(i,j)} = [boundary_map{label_extend(i,j)};i j+1];
            end
            if label_extend(i,j)~=label_extend(i-1,j)
                boundary_map{label_extend(i,j)} = [boundary_map{label_extend(i,j)};i-1 j];
            end
            if label_extend(i,j)~=label_extend(i+1,j)
                boundary_map{label_extend(i,j)} = [boundary_map{label_extend(i,j)};i+1 j];
            end
        end
    end
end

neighbor_img = cell(num_label,1);
for j = 1:num_label
    index_boundary = boundary_map{j}(:,1) + (boundary_map{j}(:,2)-1)*(h+2);
    neighbor_bw = unique(label_extend(index_boundary));
    neighbor_bw = neighbor_bw(neighbor_bw>0&neighbor_bw~=j);
    neighbor_img{j} = neighbor_bw;
end

end