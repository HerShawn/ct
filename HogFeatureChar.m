function feature = HogFeatureChar(magGrad,orientation)
% magGrad = imresize(magGrad,[24 24*3]);
% orientation = imresize(orientation,[24 24*3]);
orientation = mod(orientation , pi);

feature = zeros(4,16);

left = ones(1,16);
right = ones(1,16);
top = ones(1,16);
bottom = ones(1,16);
left(1:4:13) = 1;
left(2:4:14) = 31;
left(3:4:15) = 61;
left(4:4:16) = 91;

right(1:4:13) = 40;
right(2:4:14) = 70;
right(3:4:15) = 100;
right(4:4:16) = 130;

top(1:4) = 1;
top(5:8) = 31;
top(9:12) = 61;
top(13:16) = 91;

bottom(1:4) = 40;
bottom(5:8) = 70;
bottom(9:12) = 100;
bottom(13:16) = 130;


bin = 4;
for i = 1:bin
    flag_orientation = ((orientation>(i-1)*pi/4) & (orientation<pi/4*i) );
    magGradSub = magGrad.*flag_orientation;
    integralGrad = integralImage(magGradSub);
    for j = 1:16
        sumGrad = integralGrad(bottom(j),right(j)) + integralGrad(top(j),left(j)) - integralGrad(top(j),right(j)) - integralGrad(bottom(j),left(j));
        feature(i,j) = sumGrad;
    end
end
feature = feature(:)';
end