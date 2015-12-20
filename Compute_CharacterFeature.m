function Compute_CharacterFeature()
neighbor_img = regionneigbour_new(bw_img,corner_candidate);
[cpoint_cell_p,cpoint_cell_n,corresp_new,color_edge] = Edge_merge(img_hsi,img,bw_img,neighbor_img,cpoint_cell_p,cpoint_cell_n,magGrad,lowThresh,cluster_label,flag_point,cluster_label_big,direction);
if(Debug)
    bw_img = show_result(cpoint_cell_p,h,w);
    figure;imshow(bw_img)
end
[character_pair flag_alone flag_chain] = Character_Pair(cpoint_cell_p,cpoint_cell_n, color_edge,cluster_label,corresp_new,direction);
if direction == 1
    [cpoint_cell_p,cpoint_cell_n,flag_edge,feature_vector] = Compute_feature(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,ones(1,length(cpoint_cell_p)));
else
    [cpoint_cell_p,cpoint_cell_n,flag_edge,feature_vector] = Compute_feature(cpoint_cell_p,cpoint_cell_n,cluster_label,corresp_new,zeros(1,length(cpoint_cell_p)));
end

%% save result
if direction == 1
    dirresult = 'data_positive/';
else
    dirresult = 'data_negative/';
end
if IsSave
    resultname1 = [dirresult 'feature/feature' num2str(i) '.mat'];
    resultname2 = [dirresult 'position/position' num2str(i) '.mat'];
    resultname3 = [dirresult 'chain/chain' num2str(i) '.mat'];
    resultname4 = [dirresult 'color_edge/color_edge' num2str(i) '.mat'];
    resultname5 = [dirresult 'cluster_label/cluster_label' num2str(i) '.mat'];
    resultname6 = [dirresult 'corresp_new/corresp_new' num2str(i) '.mat'];
    resultname7 = [dirresult 'character_pair/character_pair' num2str(i) '.mat'];
    save(resultname1,'feature_vector');
    save(resultname2,'cpoint_cell_p','cpoint_cell_n');
    save(resultname3,'flag_chain');
    save(resultname4,'color_edge');
    save(resultname5,'cluster_label');
    save(resultname6,'corresp_new');
    save(resultname7,'character_pair');
end
end