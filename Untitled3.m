show_img = zeros(300,600,3);
show_img(:,1:200,1) = 0.4;
show_img(:,1:200,2) = 0.2;
show_img(:,1:200,3) = 0.3;
show_img(:,201:400,1) = 0.4;
show_img(:,201:400,2) = 0.2;
show_img(:,201:400,3) = 0.5;
show_img(:,401:600,1) = 0.4;
show_img(:,401:600,2) = 0.2;
show_img(:,401:600,3) = 0.8;
show_img = hsi2rgb(show_img);
figure;imshow(show_img)