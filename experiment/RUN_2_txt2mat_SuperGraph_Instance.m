clear;
addpath('matlab-txt');
addpath('SuperGraph_Instance');
data = importdata('RUN_2_list.txt');
for i = 1 : length(data)
    fprintf('Processing: %d/%d\n', i, length(data));
    % txt 2 mat
    graph = txt2graph(data{i});
    % feature
    feature = saveSuperGraph1(graph);
    % instance
    feature_num = length(feature);
    instance_train = instanced(graph_train, feature);
    instance_test = instanced(graph_test, feature);
    instance_train_name = [data{i}(strfind(data{i}, '/') + 1 : length(data{i})), 'fs', feature_num, '_instance_train'];
    instance_test_name = [data{i}(strfind(data{i}, '/') + 1 : length(data{i})), 'fs', feature_num, '_instance_test'];
    eval(strcat(instance_train_name, ' = instance_train'));
    eval(strcat(instance_test_name, ' = instance_test'));
    file_name = [data{i}, 'fs', feature_num, '_instance_train_test.mat'];
    save(file_name, instance_train_name, instance_test_name);
    clear graph feature instance;
end
disp('Done!');