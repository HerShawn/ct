% function [ r,d ] = tongji2()
%  tfname1='E:\result4_matlab_feature4\';
clear
clc
tfname1='E:\2012 ÎÄ×Ö¼ì²â\´úÂë_ĞŞ¸Ä\PosNeg\bw_result';
tfname2='E:\2011 ÏÔÖøĞÔÎÄ×Ö¼ì²â\database\testgt\';
sumarea=0;
sumground=0;
sumdetection=0;
r1=[];
d1=[];
for i=1:249
    disp(i)
%     if sum(i==[206 217 222 226])
%         continue
%     end
       bzname1=[tfname1 int2str(i) '.tif'];
       bzname2=[tfname2 int2str(i) '.jpg'];
       im1=imread(bzname1);
       im1=im2bw(im1);
       im2=imread(bzname2);
       im2=im2bw(im2);
       im2=imresize(im2,size(im1));
       im=im1&im2;
       im=double(im);
       area=sum(sum(im));
       r1=[r1 area/sum(sum(im2))];
       if sum(sum(im1))==0
            d1=[d1 1];
       else   
            d1=[d1 area/sum(sum(im1))];
       end
       sumarea=sumarea+area;
       sumground=sumground+sum(sum(im2));
       sumdetection=sumdetection+sum(sum(im1));
%    end
end
r=sumarea/sumground
d=sumarea/sumdetection
rp=mean(r1)
dp=mean(d1)
f=2/(1/rp+1/dp)
% end