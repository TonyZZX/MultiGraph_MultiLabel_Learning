clear;
addpath('matlab-txt');
addpath('SuperGraph_Instance');
data = importdata('RUN_2_list.txt');

current_time = datestr(clock, 'yy_mm_dd_HH_MM');
out_file_name = ['experiment_result_', current_time, '.txt'];
fileID = fopen(out_file_name, 'w');
fprintf(fileID, 'name\tfre\ttime\tsubg\tfs\tMIML\tratio\thn\tHammingLoss\tRankingLoss\tOneError\tCoverage\tAverage_Precision\ttr_time\tte_time\n');

for i = 1 : length(data)
    fprintf('Processing: %d/%d\n', i, length(data));
    % txt 2 mat
    graph = txt2graph(data{i});
    % feature
    feature = saveSuperGraph1(graph);
    
    dataset_name = data{i}(1 : strfind(data{i}, '_CSM') - 1);
    load(strcat(dataset_name, '_graph_label_train_test.mat'));
    graph_train_fun = ['graph_train = ', dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_graph_train;'];
    graph_test_fun = ['graph_test = ', dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_graph_test;'];
    eval(graph_train_fun);
    eval(graph_test_fun);
    
    % instance
    feature_num = int2str(length(feature));
    instance_train = instanced(graph_train, feature);
    instance_test = instanced(graph_test, feature);
%     instance_train_name = [data{i}(strfind(data{i}, '/') + 1 : length(data{i})), 'fs', feature_num, '_tr'];
%     instance_test_name = [data{i}(strfind(data{i}, '/') + 1 : length(data{i})), 'fs', feature_num, '_te'];
    instance_train_name = strcat(dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_CSM_instance_train');
    instance_test_name = strcat(dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_CSM_instance_test');
    eval(strcat(instance_train_name, ' = instance_train;'));
    eval(strcat(instance_test_name, ' = instance_test;'));
    
    label_train_name = strcat(dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_CSM_label_train');
    label_test_name = strcat(dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_CSM_label_test');
    eval(strcat(label_train_name, strcat(' = ', strcat(dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_label_train;'))));
    eval(strcat(label_test_name, strcat(' = ', strcat(dataset_name(strfind(dataset_name, '/') + 1 : length(dataset_name)), '_label_test;'))));
    
    % load label
    load(strcat(dataset_name, '_graph_label_train_test.mat'));
    % output instance and label
    file_name = [data{i}, 'fs', feature_num, '_instance_label_train_test.mat'];
    save(file_name, instance_train_name, instance_test_name, label_train_name, label_test_name);
    clearvars -except data current_time i file_name
    
    % MIML
    out_file_name = ['experiment_result_', current_time, '.txt'];
    MIML(file_name, out_file_name);
    clearvars -except data current_time i
end
disp('Done!');