function [flag_chain] = Character_Pair(cpoint_cell, color_edge,cluster_label,corresp_new,IsSave,ChainName)
if nargin == 4
    IsSave = 0;
end
num_character = size(cpoint_cell,1);
[h,~] = size(cluster_label);
% direction = 1;
% th_stroke_attr_high = 0.8;
% th_stroke_attr_low = 0.4;
% flag_label = zeros(1,num_character);
% characterprop = struct{num_character,1};
for i = 1:num_character
    location_x = cpoint_cell{i}(:,2);
    location_y = cpoint_cell{i}(:,1);
    characterprop(i).top = min(location_y);
    characterprop(i).bottom = max(location_y);
    characterprop(i).left = min(location_x);
    characterprop(i).right = max(location_x);
    characterprop(i).height = characterprop(i).bottom-characterprop(i).top+1;
    characterprop(i).width = characterprop(i).right-characterprop(i).left+1;
    characterprop(i).color_h = color_edge(i,1);
    characterprop(i).color_s = color_edge(i,2);
    characterprop(i).color_i = color_edge(i,3);
    characterprop(i).color_r = color_edge(i,4);
    characterprop(i).color_g = color_edge(i,5);
    characterprop(i).color_b = color_edge(i,6);
    [characterprop(i).stroke_width, ~, ~, ~,~, characterprop(i).occupy_own]= Stroke_attribute(cpoint_cell{i},cluster_label,corresp_new{i},h);
end
%% 生成字符对
character_pair = [];
th_color = 35/255;
th_stroke = 0.5;
for i = 1:num_character
%     if i == 161
%     end
    for j = i+1:num_character
        dis1 = sqrt((characterprop(i).top+characterprop(i).bottom-characterprop(j).top-characterprop(j).bottom)^2+(characterprop(i).left+characterprop(i).right-characterprop(j).left-characterprop(j).right)^2)/2;
        th1 = 3.5*min(max(characterprop(i).width,characterprop(i).height),max(characterprop(j).width,characterprop(j).height));
        dis2 = abs(characterprop(i).top+characterprop(i).bottom-characterprop(j).top-characterprop(j).bottom)/2;
        th2 = max(characterprop(i).height,characterprop(i).height)/2;
        dis3 = max(characterprop(i).left,characterprop(j).left)-min(characterprop(i).right,characterprop(j).right);
        th3 = -1/10*min(characterprop(i).width,characterprop(i).width);
        flag_position = dis1<th1&&dis2<th2&&dis3>th3;
        flag_size = (characterprop(i).height/characterprop(j).height>1/2&&characterprop(i).height/characterprop(j).height<2)...
            ||((characterprop(i).height/characterprop(j).height>1/3&&characterprop(i).height/characterprop(j).height<3)&&...
            ((characterprop(i).width/characterprop(j).width>1/1.5&&characterprop(i).width/characterprop(j).width<1.5)));
        flag_color1 = abs(characterprop(i).color_r-characterprop(j).color_r)<th_color&&abs(characterprop(i).color_g-characterprop(j).color_g)<th_color&&abs(characterprop(i).color_b-characterprop(j).color_b)<th_color;
        flag_color2 = abs(characterprop(i).color_h-characterprop(j).color_h)<th_color&&abs(characterprop(i).color_s-characterprop(j).color_s)<th_color;
        flag_color = flag_color1||flag_color2;
        flag_sw1 = (characterprop(i).stroke_width/characterprop(j).stroke_width)<2&&(characterprop(i).stroke_width/characterprop(j).stroke_width)>1/2;
        flag_sw2 = characterprop(i).occupy_own>th_stroke&&characterprop(j).occupy_own>th_stroke;
        flag_sw = flag_sw1&&flag_sw2;
        if (flag_position&&flag_color&&flag_sw&&flag_size)
            dx = (characterprop(i).left+characterprop(i).right-characterprop(j).left-characterprop(j).right)/2;
            dy = (characterprop(i).top+characterprop(i).bottom-characterprop(j).top-characterprop(j).bottom)/2;
            character_pair = [character_pair; i j atan2(dy,dx)];
        end
    end
end
flag_alone = zeros(1,num_character);
if isempty(character_pair)
    flag_chain = zeros(1,num_character);
    if IsSave
        save(ChainName,'flag_chain');
    end
    return
end
character_pair_index = character_pair(:,1:2);
for i = 1:num_character
    if sum(sum(character_pair_index == i))
        flag_alone(i) = 1;
    end
end
%% 生成字符串
flag_chain = zeros(1,num_character);
k = 0;
character_pair_tmp = character_pair(:,1:2);
while ~isempty(character_pair_tmp)
    k = k+1;
    value1 = character_pair_tmp(1,1);
    value2 = character_pair_tmp(1,2);
    character_pair_tmp = character_pair_tmp(2:end,:);
    flag_chain(value1) = k;
    flag_chain(value2) = k;
    vec = [value1 value2];
    while ~isempty(vec)
        index_x = [];
        for i = 1:length(vec)
            [index1_x, ~] = find(character_pair_tmp == vec(i));
            index_x = [index_x;index1_x];
        end
        vec_tmp = character_pair_tmp(index_x,:);
        vec = vec_tmp(:);
        vec = unique(vec);
        flag_chain(vec) = k;
        character_pair_tmp(index_x,:) = [];
    end
end
%% 对文字行进行划分
% flag_chain = SeparateWord(characterprop, flag_chain);
if IsSave
    save(ChainName,'character_pair','flag_alone','flag_chain');
end
end