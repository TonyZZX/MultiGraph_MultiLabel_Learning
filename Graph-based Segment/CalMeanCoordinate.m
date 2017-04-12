function [ coordinateMean ] = CalMeanCoordinate( L, rowNum, colNum, curSegNum )
% the central point will be the mean of all coordinates
xTotal = 0;
yTotal = 0;
count = 0;
% the leftest and toppest point will be [1,1]
for i = 1:rowNum
    for j = 1:colNum
        if curSegNum == L(i, j)
            % x will be the horizental direction, so it is the column
            % y is the row
            xTotal = xTotal + j;
            yTotal = yTotal + i;
            count = count + 1;
        end
    end
end
xMean = xTotal / count / colNum;
yMean = yTotal / count / rowNum;
coordinateMean = [xMean, yMean];
end

