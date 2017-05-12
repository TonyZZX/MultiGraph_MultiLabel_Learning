clear;
% data = importdata('./Corel5k/corel5k_test_list.txt');
% data = importdata('./Corel5k/corel5k_train_list.txt');
% data = importdata('./MSRC_ObjCategImageDatabase_v2/GroundTruth_List.txt');
% data = importdata('./MSRC_ObjCategImageDatabase_v2/Images_List.txt');
data = importdata('./original/original_List.txt');
dataLength = length(data);
% path = './Corel5k/';
% path = './MSRC_ObjCategImageDatabase_v2/GroundTruth/';
% path = './MSRC_ObjCategImageDatabase_v2/Images/';
path = './original/';
% gBagsTest_new = cell(1, dataLength);
% MSRCGroundTruth_new = cell(1, dataLength);
% MSRCImages_new = cell(1, dataLength);
original_new = cell(1, dataLength);
for i = 1:dataLength
%     img_path = strcat(path, data{i}, '.jpeg');
    img_path = strcat(path, data{i}, '');
    image = imread(img_path);
    graphs = PrimSegment( image, 200, 6 );
%     gBagsTest_new{i} = graphs;
%     MSRCGroundTruth_new{i} = graphs;
%     MSRCImages_new{i} = graphs;
    original_new{i} = graphs;
    fprintf('processed: %d / %d\n', i, dataLength);
end
clear i data dataLength path img_path image graphs;