function neighbor_img = regionneigbour_new(bw_img,corner_candidate)
num_label = max(bw_img(:));
neighbor_img = cell(num_label,1);

corner_candidate = wextend('2', 'zpd',corner_candidate,1);
bw_img = wextend('2', 'zpd',bw_img,1);
[h,w] = size(bw_img);

[bw_corner,num_corner] = bwlabel(corner_candidate,8);
offset = [-1,1,h,-h,-h-1,-h+1,h-1,h+1];
indexCell = cell(1,num_corner);
for j = 1:w
    for i = 1:h
        index = bw_corner(i,j);
        if (index)
            indexCell{index} = [indexCell{index} i+(j-1)*h];
            %             a{1} = [a{1}, 2]
        end
    end
end
for i = 1:num_corner
    index = indexCell{i};
    neighbors = bsxfun(@plus, index, offset');
    neighbors = unique(neighbors(:))';
    neighbors = neighbors(corner_candidate(neighbors) == 0);
    neighbors_value = bw_img(neighbors);
    neighbors_value = unique(neighbors_value);
    neighbors_value = neighbors_value(neighbors_value>0);
    num_neig = length(neighbors_value);
    for j = 1:num_neig
        neighbor_img{neighbors_value(j)} = [neighbor_img{neighbors_value(j)} neighbors_value(neighbors_value~=neighbors_value(j))];
    end
end

end_point = endpoints(bw_img);
window_end = 4;
offset_x = -window_end:window_end;
offset_y = -window_end:window_end;
window_line = 2;
offset_xline = -window_line:window_line;
offset_yline = -window_line:window_line;
for i = 1:h
    for j = 1:w
        if (end_point(i,j))
            %             if (i == 608&& j == 378)
            %             end
            x_location = j + offset_x;
            y_location = i + offset_y;
            flag_delete_x = x_location>w|x_location<1;
            x_location(flag_delete_x) = [];
            flag_delete_y = y_location>h|y_location<1;
            y_location(flag_delete_y) = [];
            index = repmat((x_location-1)'*h,1,length(y_location)) + repmat(y_location,length(x_location),1);
            index = index(:)';
            end_point_local = find(end_point(index) == 1);
            y_point = rem(index(end_point_local)-1, h)+1;
            x_point = floor((index(end_point_local)-1)/h)+1;
            %             distance_local = (x_point-j)^2+(y_point-i)^2;
            %             [value,pos]=min(distance_local);
            for k = 1:length(x_point)
                index_point = bw_img((x_point(k)-1)*h+y_point(k));
                neighbor_img{index_point} = [neighbor_img{index_point} bw_img(i,j)];
            end
            neighbor_img{bw_img(i,j)} = [neighbor_img{bw_img(i,j)} bw_img((x_point-1)*h+y_point)];
            %% 如果没有对应的结束点
            if length(end_point_local) == 1
                x_location = j + offset_xline;
                y_location = i + offset_yline;
                flag_delete_x = x_location>w|x_location<1;
                x_location(flag_delete_x) = [];
                flag_delete_y = y_location>h|y_location<1;
                y_location(flag_delete_y) = [];
                index = repmat((x_location-1)'*h,1,length(y_location)) + repmat(y_location,length(x_location),1);
                index = index(:)';
                end_point_local = find(bw_img(index) ~= 0&bw_img(index) ~= bw_img(i,j));
                y_point = rem(index(end_point_local)-1, h)+1;
                x_point = floor((index(end_point_local)-1)/h)+1;
                distance_local = (x_point-j).^2+(y_point-i).^2;
                [~,pos]=min(distance_local);
                index_dest = bw_img((x_point(pos)-1)*h+y_point(pos));
                neighbor_img{bw_img(i,j)} = [neighbor_img{bw_img(i,j)} index_dest];
                if ~isempty(index_dest)
                    neighbor_img{index_dest} = [neighbor_img{index_dest} bw_img(i,j)];
                end
            end
        end
    end
end

for i = 1:num_label
    neighbor_img{i} = unique(neighbor_img{i});
    neighbor_img{i} = neighbor_img{i}(neighbor_img{i}~=i);
end
end