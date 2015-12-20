%% 进行连通区域标定
function Connected = OnePass_gray(cluster_label,bw_img,grad_big,distance_label)
% num_label = max(bw_img(:));
% cluster_label(~grad_big) = 0;
% cluster_label = wextend('2', 'zpd',cluster_label,1);
% bw_img = wextend('2', 'zpd',bw_img,1);
% [M, N]=size(cluster_label);
% Connected = zeros(M,N);
% Offsets = [-1; M; 1; -M];
% for i = 2:M-1
%     for j = 2:N-1
%         if(bw_img(i,j))
%             value = cluster_label(i,j);
%             Index = (j-1)*M + i;
%             Connected(Index) = value;
%             while ~isempty(Index)
%                 cluster_label(Index) = 0;
%                 bw_img(Index) = 0;
%                 Neighbors = bsxfun(@plus, Index, Offsets');
%                 Neighbors = unique(Neighbors(:));
% %                 if sum(Neighbors<1)
% %                 end
%                 Index = Neighbors(cluster_label(Neighbors)==value);
%                 Connected(Index) = value;
%             end
%         end
%     end
% end
% Connected = Connected(2:end-1,2:end-1);
[Connected,num_label] = Bwlabel_onepass(cluster_label,bw_img,double(grad_big));
Index_all = Find_Index_of_each_value(Connected,num_label);
for i = 1:num_label
    Index_d = Index_all{i};
    distance_v = distance_label(Index_d);
    median_d = median(distance_v);
    Index_big = distance_v>median_d;
    Connected(Index_d(Index_big)) = 0;
end
% for i = 1:num_label
%     Index_d = find(Connected == i);
%     distance_v = distance_label(Index_d);
%     median_d = median(distance_v);
%     Index_big = distance_v>1.6*median_d;
%     Connected(Index_d(Index_big)) = 0;
% end
end