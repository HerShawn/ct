function img=plot_rectangle(img,rectangle,width,color)
[h,w,~] = size(img);
left = max(rectangle(:,1),1);
right = min(rectangle(:,3),w);
top = max(rectangle(:,2),1);
bottom = min(rectangle(:,4),h);
if nargin==3
    color=[255 0 0];
end
for k = 1:size(rectangle,1)
    img(max(top(k)-width,1):min(top(k)+width,h),left(k):right(k),1)=color(1);
    img(max(bottom(k)-width,1):min(bottom(k)+width,h),left(k):right(k),1)=color(1);
    img(top(k):bottom(k),max(left(k)-width,1):min(left(k)+width,w),1)=color(1);
    img(top(k):bottom(k),max(right(k)-width,1):min(right(k)+width,w),1)=color(1);
    
    img(max(top(k)-width,1):min(top(k)+width,h),left(k):right(k),2)=color(2);
    img(max(bottom(k)-width,1):min(bottom(k)+width,h),left(k):right(k),2)=color(2);
    img(top(k):bottom(k),max(left(k)-width,1):min(left(k)+width,w),2)=color(2);
    img(top(k):bottom(k),max(right(k)-width,1):min(right(k)+width,w),2)=color(2);
    
    img(max(top(k)-width,1):min(top(k)+width,h),left(k):right(k),3)=color(3);
    img(max(bottom(k)-width,1):min(bottom(k)+width,h),left(k):right(k),3)=color(3);
    img(top(k):bottom(k),max(left(k)-width,1):min(left(k)+width,w),3)=color(3);
    img(top(k):bottom(k),max(right(k)-width,1):min(right(k)+width,w),3)=color(3);
end
end