function Ib=binarization2(grayimg,topn,bottomn,leftn,rightn)
h=bottomn-topn+1;
w=rightn-leftn+1;
Ib=zeros(h,w);
[hi,wi]=size(grayimg);
% [h w]=size(graytmp);
ww=round(h/2);
wh=round(h/2);
k=0.4;
% I=double(I);
% for i=topn:bottomn
%     for j=leftn:rightn
for i=136
    for j=953
        left=max(1,j-ww);
        right=min(wi,j+ww);
        top=max(1,i-wh);
        bottom=min(hi,i+wh);
        wI=grayimg(top:bottom,left:right);
        meanI=mean(wI(:));
        stdI=std(wI(:));
        if grayimg(i,j)<(meanI-k*stdI)
            Ib(i-topn+1,j-leftn+1)=0;
        elseif grayimg(i,j)>(meanI+k*stdI)
            Ib(i-topn+1,j-leftn+1)=255;
        else
            Ib(i-topn+1,j-leftn+1)=100;
        end
    end
end