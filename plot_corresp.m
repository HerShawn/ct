function plot_corresp(magGrad,cpoint_cell,k)
figure;imshow(1-magGrad)
hold on
plot(cpoint_cell{k}(:,2),cpoint_cell{k}(:,1),'r*')
hold on
plot(cpoint_cell{k}(:,4),cpoint_cell{k}(:,3),'g*')
hold on
for j = 1:size(cpoint_cell{k},1)
    if (cpoint_cell{k}(j,7))
        continue
    end
    plot([cpoint_cell{k}(j,2) cpoint_cell{k}(j,4)],[cpoint_cell{k}(j,1) cpoint_cell{k}(j,3)]);
    hold on
end
end