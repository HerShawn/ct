function plot_aggregation_line(chain_para,bw,center_l)
figure;imshow(bw)
hold on
num_line = size(chain_para,2);
for ii = 1:num_line
    num_cc = size(chain_para{ii}.first,2);
    for jj = 1:num_cc
        first_cc = chain_para{ii}.first(jj);
        second_cc = chain_para{ii}.second(jj);
        line([center_l(first_cc,1) center_l(second_cc,1)],[center_l(first_cc,2) center_l(second_cc,2)],[1 1],'Marker','.','LineStyle','-','Color','r')
        hold on
    end
end
end