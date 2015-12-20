function OnePass(Image)
[M, N]=size(Image);
Connected = zeros(M,N);
Mark = 1;
Difference = 1;
Offsets = [-1; M; 1; -M];
No_of_Objects = 0;
for i = 1:M
    for j = 1:N
        if(Image(i,j)==1)
            No_of_Objects = No_of_Objects +1;
            Index = (j-1)*M + i;
            Connected(Index)=Mark;
            while ~isempty(Index)
                Image(Index)=0;
                Neighbors = bsxfun(@plus, Index, Offsets');
                Neighbors = unique(Neighbors(:));
                Index = Neighbors(Image(Neighbors));
                Connected(Index)=Mark;
            end
            Mark = Mark + Difference;
        end
    end
end
end