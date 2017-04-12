function [ std_nodes ] = ConvertNodes( meanColors )
for i = 1:length(meanColors)
    color = meanColors(1, i);
    % R G B
%     nodeLabel = int32(color{1}(1)) * 1000000 + int32(color{1}(2)) * 1000 + int32(color{1}(3));
    nodeLabel = 0;
    for j = 1:3
        oneColor = fix(color{1}(1, j) / 16);
        nodeLabel = nodeLabel * 100;
        nodeLabel = nodeLabel + oneColor;
    end
    std_nodes(i, 1) = nodeLabel;
end
end

