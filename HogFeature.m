function feature = HogFeature(magGrad,img_gray,orientation)
% magGrad = imresize(magGrad,[24 24*3]);
% orientation = imresize(orientation,[24 24*3]);
orientation = mod(orientation , pi);
[h,w] = size(magGrad);
feature = zeros(4,14);
integral_Img = integralImage(img_gray);
integral_ImgSqrt = integralImage(img_gray.^2);

left = ones(1,14);
right = ones(1,14)*w;
top = ones(1,14);
bottom = ones(1,14)*h;
left(7) = 37;
left(9) = 25;
left(10) = 49;

right(6) = 36;
right(8) = 24;
right(9) = 48;

top(2) = 5;
top(3) = 11;
top(4) = 15;
top(5) = 21;
top(11) = 5;
top(12) = 11;
top(13) = 5;

bottom(1) = 4;
bottom(2) = 10;
bottom(3) = 14;
bottom(4) = 20;
bottom(11) = 14;
bottom(12) = 20;
bottom(13) = 20;
bottom = bottom + 1;
right = right + 1;

bin = 4;
for i = 1:bin
    flag_orientation = ((orientation>(i-1)*pi/4) & (orientation<pi/4*i) );
    magGradSub = magGrad.*flag_orientation;
    integralGrad = integralImage(magGradSub);
    for j = 1:14
        num = (bottom(j) - top(j))*(right(j) - left(j));
        sumGrad = integralGrad(bottom(j),right(j)) + integralGrad(top(j),left(j)) - integralGrad(top(j),right(j)) - integralGrad(bottom(j),left(j));
        meanInt = (integral_Img(bottom(j),right(j)) + integral_Img(top(j),left(j)) - integral_Img(top(j),right(j)) - integral_Img(bottom(j),left(j)))/num;
        square_value = integral_ImgSqrt(bottom(j),right(j)) + integral_ImgSqrt(top(j),left(j)) - integral_ImgSqrt(top(j),right(j)) - integral_ImgSqrt(bottom(j),left(j));
        std_value = sqrt(square_value/num - (meanInt)^2);
        feature(i,j) = sumGrad/(std_value+eps);
    end
end
feature = feature(:)';
end