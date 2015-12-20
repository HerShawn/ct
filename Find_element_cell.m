function index = Find_element_cell(data,value)
num_vec = length(data);
for i = 1:num_vec
    num_data = length(data{i});
    for j = 1:num_data
        if value == data{i}(j)
            index = i;
            return
        end
    end
end
end