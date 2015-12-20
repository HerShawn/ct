%% 从连通区域对生成连通区域文字串
%  2012-7-17
% for example
% pair_para = [1 2 0;2 3 3/4*pi;2 4 0.1;4 6 -0.1;4 5 pi/4;6 7 0.25];
% Aggregation_Chain(pair_para)
function chain_para = Aggregation_Chain(pair_para)
%  pair_para 第一列和第二列为连通区域的index，第三列为连通区域对的方向
%% 生成初始的连通区域对属性
w = 0.5;
num_cc = size(pair_para,1);  %连通区域对的个数
for ii = 1:num_cc
    pair.first = pair_para(ii,1);
    pair.second = pair_para(ii,2);
    pair.orientation = pair_para(ii,3);
    pair.neighbor = [];
    pair.neighborprop_own = [];
    pair.neighborprop_target = [];
    for j = 1:2
        [index_cc, index_position] = find(pair_para(1:ii-1,1:2) == pair_para(ii,j));
        [index_cc2, index_position2] = find(pair_para(ii+1:num_cc,1:2) == pair_para(ii,j));
        index_cc = [index_cc;index_cc2 + ii];
        index_position = [index_position;index_position2];
        %         ii
        %         j
        pair.neighbor = [pair.neighbor;index_cc];
        pair.neighborprop_own = [pair.neighborprop_own;ones(size(index_cc,1),1)*j];
        pair.neighborprop_target = [pair.neighborprop_target;index_position];
    end
    chain_para{ii} = pair;
end
%% 计算初始的相似度
similarity_chain = cell(num_cc,1);
for ii = 1:num_cc
    num_neig = size(chain_para{ii}.neighbor,1);
    for j = 1:num_neig
        index_neighbor = chain_para{ii}.neighbor(j);
        if chain_para{ii}.neighborprop_own(j) == chain_para{ii}.neighborprop_target(j)
            orientation_diff = mod(chain_para{ii}.orientation - chain_para{index_neighbor}.orientation - pi,2*pi);
        else
            orientation_diff = mod(chain_para{ii}.orientation - chain_para{index_neighbor}.orientation,2*pi);
        end
        orientation_diff = min(orientation_diff,2*pi-orientation_diff);
        if (orientation_diff <= pi/8)
            similarity_o = 1 - orientation_diff/pi*2;
            num_own = length(chain_para{ii}.first);
            num_des = length(chain_para{index_neighbor}.first);
            similarity_p = 1 - abs((num_own-num_des)/(num_own+num_des));
        else
            similarity_o = 0;
            similarity_p = 0;
        end
        similarity_chain{ii} = [similarity_chain{ii} w*similarity_o+(1-w)*similarity_p];
    end
end
while(1)
    [index_cc, index_neig, value] = Find_max_similarity(similarity_chain);
    if value<=0
        break
    end
    if length(similarity_chain) == 19
    end
    disp([length(chain_para{index_cc}.neighbor) length(similarity_chain{index_cc}) length(similarity_chain) length(chain_para) index_cc index_neig])
    index_neig = chain_para{index_cc}.neighbor(index_neig);
    [chain_para,similarity_chain] = Merge_chain(chain_para, similarity_chain, index_cc, index_neig, w);
end
end
%% 合并两个链
function [chain_para,similarity_chain] = Merge_chain(chain_para, similarity_chain, index_cc, index_neig, w)
if index_cc>index_neig
    tmp = index_neig;
    index_neig = index_cc;
    index_cc = tmp;
end
index_target_own = find(chain_para{index_cc}.neighbor == index_neig);  % 要合并的单元在它邻域的位置
index_target_own = index_target_own(1);                                 %此处需要修改
flag_own = chain_para{index_cc}.neighborprop_own(index_target_own);   
flag_target = chain_para{index_cc}.neighborprop_target(index_target_own);
% flag_change = 0;   % 是否进行了反转
if (flag_own == flag_target)
%     flag_change = 1;
    chain_para = Change_position(chain_para,index_neig);  % 可能需要修改
end
if flag_own == 2
    chain_para{index_cc}.first = [chain_para{index_cc}.first chain_para{index_neig}.first];
    chain_para{index_cc}.second = [chain_para{index_cc}.second chain_para{index_neig}.second];
    chain_para{index_cc}.orientation = [chain_para{index_cc}.orientation chain_para{index_neig}.orientation];
else
    chain_para{index_cc}.first = [chain_para{index_neig}.first chain_para{index_cc}.first];
    chain_para{index_cc}.second = [chain_para{index_neig}.second chain_para{index_cc}.second];
    chain_para{index_cc}.orientation = [chain_para{index_neig}.orientation chain_para{index_cc}.orientation];
end
%% 更新邻域关系
%  更新合并后的元素的邻域关系
index_own = find(chain_para{index_cc}.neighborprop_own == flag_own);
index_target = find(chain_para{index_neig}.neighborprop_own == (3-flag_own));
index_inner = [chain_para{index_cc}.neighbor(index_own);chain_para{index_neig}.neighbor(index_target)];
index_inner(index_inner == index_cc) = [];
index_inner(index_inner == index_neig) = [];
index_inner = unique(index_inner);
num_inner = length(index_inner);
%% 消除内部所影响的邻域
for i = 1:num_inner
    position_inner = (chain_para{index_inner(i)}.neighbor == index_cc)|(chain_para{index_inner(i)}.neighbor == index_neig);
    chain_para{index_inner(i)}.neighbor(position_inner) = [];
    chain_para{index_inner(i)}.neighborprop_own(position_inner) = [];
    chain_para{index_inner(i)}.neighborprop_target(position_inner) = [];
    similarity_chain{index_inner(i)}(position_inner) = [];
end
%% 消除自己和邻域的邻域
chain_para{index_cc}.neighbor(index_own) = [];
chain_para{index_cc}.neighborprop_own(index_own) = [];
chain_para{index_cc}.neighborprop_target(index_own) = [];
chain_para{index_neig}.neighbor(index_target) = [];
chain_para{index_neig}.neighborprop_own(index_target) = [];
chain_para{index_neig}.neighborprop_target(index_target) = [];
% similarity_chain{index_cc}(index_own == index_neig) = []; % 需要修改
% similarity_chain{index_neig}(index_target == index_neig) = []; % 需要修改
chain_para{index_cc}.neighbor = [chain_para{index_cc}.neighbor;chain_para{index_neig}.neighbor];
chain_para{index_cc}.neighborprop_own = [chain_para{index_cc}.neighborprop_own;chain_para{index_neig}.neighborprop_own];
chain_para{index_cc}.neighborprop_target = [chain_para{index_cc}.neighborprop_target;chain_para{index_neig}.neighborprop_target];
[chain_para{index_cc}.neighbor, m1, ~] = unique(chain_para{index_cc}.neighbor, 'first');
chain_para{index_cc}.neighborprop_own = chain_para{index_cc}.neighborprop_own(m1);
chain_para{index_cc}.neighborprop_target = chain_para{index_cc}.neighborprop_target(m1);

%  更新因target合并而变化的邻域关系
chain_para(index_neig) = [];
similarity_chain(index_neig) = [];
num_cc = size(chain_para,2);
for i = 1:num_cc
    num_neig = size(chain_para{i}.neighbor,1);
    for j = 1:num_neig
        if chain_para{i}.neighbor(j) == index_neig
            chain_para{i}.neighbor(j) = index_cc;
%             if flag_change == 1
%                 chain_para{i}.neighborprop_target(j) = 3-chain_para{i}.neighborprop_target(j);  % flag_change
%             end
        elseif chain_para{i}.neighbor(j) > index_neig
            chain_para{i}.neighbor(j) = chain_para{i}.neighbor(j)-1;
        end
    end
    [chain_para{i}.neighbor, m1, ~] = unique(chain_para{i}.neighbor, 'first');
    chain_para{i}.neighborprop_own = chain_para{i}.neighborprop_own(m1);
    chain_para{i}.neighborprop_target = chain_para{i}.neighborprop_target(m1);
end
%% 更新similarity表
% if index_neig<index_cc
% index_cc = index_cc - 1;
% end
num_neig = length(chain_para{index_cc}.neighbor);
similarity_chain{index_cc} = zeros(1,num_neig);
for i = 1:num_neig
    index_value_neig = chain_para{index_cc}.neighbor(i);
    if chain_para{index_cc}.neighborprop_own(i) == 1
        orientation1 = chain_para{index_cc}.orientation(1);
    else
        orientation1 = chain_para{index_cc}.orientation(end);
    end
    if chain_para{index_cc}.neighborprop_target(i) == 1
        orientation2 = chain_para{index_value_neig}.orientation(1);
    else
        orientation2 = chain_para{index_value_neig}.orientation(end);
    end
    if chain_para{index_cc}.neighborprop_own(i) == chain_para{index_cc}.neighborprop_target(i)
        orientation_diff = mod(orientation1-orientation2-pi,2*pi);
    else
        orientation_diff = mod(orientation1-orientation2,2*pi);
    end
    orientation_diff = min(orientation_diff,2*pi-orientation_diff);
    if (orientation_diff <= pi/8)
        similarity_o = 1 - orientation_diff/pi*2;
        num_own = length(chain_para{index_cc}.first);
        num_des = length(chain_para{index_value_neig}.first);
        similarity_p = 1 - abs((num_own-num_des)/(num_own+num_des));
    else
        similarity_o = 0;
        similarity_p = 0;
    end
    similarity_chain{index_cc}(i) = w*similarity_o+(1-w)*similarity_p;
    similarity_chain{index_value_neig}(chain_para{index_value_neig}.neighbor == index_cc) = similarity_chain{index_cc}(i);
    similarity_chain{index_value_neig}(chain_para{index_value_neig}.neighbor == index_neig) = similarity_chain{index_cc}(i);
end
end

%% 调换被合并的坐标顺序
function chain_para = Change_position(chain_para,index_cc)
% num_pair = length(pair.first);
% for ii = 1:num_pair
pair = chain_para{index_cc};
tmp_value = pair.first;
pair.first = pair.second;
pair.second = tmp_value;
pair.neighborprop_own = 3 - pair.neighborprop_own;
pair.orientation = pair.orientation - pi;
if pair.orientation<-pi
    pair.orientation = pair.orientation+2*pi;
end
chain_para{index_cc} = pair;
num_neighbor = length(chain_para{index_cc}.neighbor);
for i = 1:num_neighbor
    index_neig = pair.neighbor(i);
    j = find(chain_para{index_neig}.neighbor == index_cc);
    chain_para{index_neig}.neighborprop_target(j) = 3-chain_para{index_neig}.neighborprop_target(j);
%     disp([length(chain_para{index_neig}.neighborprop_target) length(chain_para{index_neig}.neighborprop_target) j])
end
% end
end

%% 找到最大的相似度链
function [index_cc, index_neig, value] = Find_max_similarity(similarity_chain)
num_cc = size(similarity_chain,1);
index_cc = 0;
index_neig = 0;
value = 0;
for ii = 1:num_cc
    num_neig = size(similarity_chain{ii},2);
    for j = 1:num_neig
        if similarity_chain{ii}(j)>value
            value = similarity_chain{ii}(j);
            index_cc = ii;
            index_neig = j;
        end
    end
end
end