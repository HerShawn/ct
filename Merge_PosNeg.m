function Merge_PosNeg(img_index)
dir1 = 'data_positive/';
dir2 = 'data_negative/';
bw_img1 = imread([dir1 'bw_result' num2str(img_index) '.tif']);
bw_img2 = imread([dir2 'bw_result' num2str(img_index) '.tif']);
color_img1 = imread([dir1 'rgb_result' num2str(img_index) '.tif']);
color_img2 = imread([dir2 'rgb_result' num2str(img_index) '.tif']);
bw_img = im2bw(bw_img1)|im2bw(bw_img2);
color_r = max(cat(3,color_img1(:,:,1),color_img2(:,:,1)),[],3);
color_g = max(cat(3,color_img1(:,:,2),color_img2(:,:,2)),[],3);
color_b = max(cat(3,color_img1(:,:,3),color_img2(:,:,3)),[],3);
color_img = cat(3,color_r,color_g,color_b);
dir = '';
imwrite(bw_img,[dir 'PosNeg/bw_result' num2str(img_index) '.tif']);
imwrite(color_img,[dir 'PosNeg/rgb_result' num2str(img_index) '.tif']);
end