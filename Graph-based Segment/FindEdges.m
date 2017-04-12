function [ edge_vertexNums ] = FindEdges( L, rowNum, colNum, curSegNum )
edge_vertexNums = 0;
% first, run it horizontally
for i = 1:rowNum
    % whether meet the current segment number
    isFindCurSegNum = 0;
    % the last num met, which is not equal to the current number
    lastNum = 0;
    for j = 1:colNum
        % if L(i, j) euqals to the segemtn number
        if L(i,j) == curSegNum
            isFindCurSegNum = 1;
            % if the last num is not equal to 0, it means we have met
            % another num, then set it to the edge array
            if lastNum ~= 0
                edge_vertexNums(length(edge_vertexNums) + 1) = lastNum;
            end
        else
            % if L(i, j) is not euqal to the segemtn number and we already
            % met the segment number, then set it to the edge array and set
            % the isFindCurSegNum to 0
            if isFindCurSegNum == 1
                edge_vertexNums(length(edge_vertexNums) + 1) = L(i,j);
                isFindCurSegNum = 0;
            % if not, it means we have not met the seg number, then
            % coutinue finding and set the last number
            else
                lastNum = L(i,j);
            end
        end
    end
    % just in case that we found the seg number and another number but not
    % set it
    if isFindCurSegNum == 1 && lastNum ~= 0
        edge_vertexNums(length(edge_vertexNums) + 1) = lastNum;
    end
end

% then run it vertically
for j = 1:colNum
    isFindCurSegNum = 0;
    lastNum = 0;
    for i = 1:rowNum
        if L(i,j) == curSegNum
            isFindCurSegNum = 1;
            if lastNum ~= 0
                edge_vertexNums(length(edge_vertexNums) + 1) = lastNum;
            end
        else
            if isFindCurSegNum == 1
                edge_vertexNums(length(edge_vertexNums) + 1) = L(i,j);
                isFindCurSegNum = 0;
            else
                lastNum = L(i,j);
            end
        end
    end
    if isFindCurSegNum == 1 && lastNum ~= 0
        edge_vertexNums(length(edge_vertexNums) + 1) = lastNum;
    end
end
edge_vertexNums = unique(edge_vertexNums);
end
