clear;

image = imread('sea.jpeg');
% [L, N] = superpixels(image, num)
% L: segment result
% N: the number of segments you get
% num: the number of segments you want
[L, N] = superpixels(image, 50);
rowNum = size(image, 1);
colNum = size(image, 2);
% get lineal array of L
idx = label2idx(L);

% cal central coordinates and mean colors, and find adjoining edges
centralCoordinates = cell(1, N);
edges = cell(1, N);
meanColors = cell(1, N);
for num = 1:N
    centralCoordinates{num} = CalMeanCoordinate(L, rowNum, colNum, num);
    edges{num} = FindEdges(L, rowNum, colNum, num);
    meanColors{num} = CalMeanColor(L, rowNum, colNum, num, idx, image);
end
std_nodes = ConvertNodes(meanColors);
std_edges = ConvertEdges(edges, centralCoordinates);

% ShowOutputImage(L, rowNum, colNum, idx, image, N, 1, 1)
clear image L idx num N edges rowNum colNum meanColors;

graphs = Prim(centralCoordinates, std_nodes, std_edges, 5);
clear centralCoordinates std_nodes std_edges;