%  BW1 = imread('text.png');
%  c = [126 187 11];
%  r = [34 172 20];
%  BW2 = bwselect(BW1,c,r,4);
%  figure, imshow(BW1)
%  figure, imshow(BW2)
 
 diff = zeros(1,length(neighbor_img));
 for i = 1:length(neighbor_img)
     diff(i) = sum(neighbor_img{i} ==  neighbor_img2{i}');
 end
 sum(diff)