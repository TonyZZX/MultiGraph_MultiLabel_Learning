function [ std_edges ] = ConvertEdges( edges, centralCoordinates )
% convert edges to standard edges data structure
count = 1;
for i = 1:length(edges)
    for j = 1:length(edges{i})
        nodeA = i;
        nodeB = edges{i}(j);
        % node must be greater than 0
        if nodeA ~= 0 && nodeB ~= 0
            % nodeA must be greater than nodeB, or switch them
            if nodeA > nodeB
                t = nodeA;
                nodeA = nodeB;
                nodeB = t;
            end
            std_edges(count, 1) = nodeA;
            std_edges(count, 2) = nodeB;
            % just set the label of edge to the distant between nodes
            std_edges(count, 3) = CalDistant(centralCoordinates{nodeA}, centralCoordinates{nodeB});
            count = count + 1;
        end
    end
end
std_edges = unique(std_edges,'rows');
end

