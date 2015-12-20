% cpoint_cell_p,cpoint_cell_n
num_bw = size(cpoint_cell_p);
newCpointP = cell(num_bw,1);
newCpointN = cell(num_bw,1);
for i = 1:num_bw
    for j = 1:size(cpoint_cell_p{i})
        newCpointP{i} = [newCpointP{i}; cpoint_cell_p{i}{j}];
        newCpointN{i} = [newCpointN{i}; cpoint_cell_n{i}{j}];
    end
end
cpoint_cell_p = newCpointP;
cpoint_cell_n = newCpointN;