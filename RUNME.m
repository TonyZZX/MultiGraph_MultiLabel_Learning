clear;
data = importdata('./Corel5k/corel5k_test_list.txt');
dataLength = length(data);
path = './Corel5k/';
gBagsTest_new = cell(1, dataLength);
for i = 1:dataLength
    img_path = strcat(path, data{i}, '.jpeg');
    image = imread(img_path);
    graphs = PrimSegment( image, 400, 10 );
    gBagsTest_new{i} = graphs;
    fprintf('processed: %d / %d\n', i, dataLength);
end
clear i data dataLength path img_path image graphs;