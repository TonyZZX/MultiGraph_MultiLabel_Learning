function [graphformY] = graphedY (instanceformY);

[m,n]=size(instanceformY);
for i=1:m
    for j=1:n
        if instanceformY(i,j)==-1
            graphformY(j,i)=0;
        else
            graphformY(j,i)=1;
        end
    end
end
