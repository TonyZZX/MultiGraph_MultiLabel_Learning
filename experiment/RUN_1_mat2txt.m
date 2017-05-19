clear;
addpath('matlab-txt');
data = importdata('RUN_1_list.txt');
for i = 1 : length(data)
    fprintf('Processing: %d/%d\n', i, length(data));
    load(strcat(data{i}, '.mat'));
    dataset_name = data{i};
    dataset_name = dataset_name(strfind(data{i}, '/') + 1 : strfind(data{i}, '_graph') - 1);
    graph_name = strcat(dataset_name, '_graph_train');
    label_name = strcat(dataset_name, '_label_train');
    out_graph_name = ['''', strrep(data{i}, '_graph_label_train_test', '_graph_train'), ''''];
    out_label_name = ['''', strrep(data{i}, '_graph_label_train_test', '_label_train'), ''''];
    graph_fun = ['graph2txt(', graph_name, ', ', out_graph_name, ');'];
    label_fun = ['label2txt(', label_name, ', ', graph_name, ', ', out_label_name, ');'];
    eval(graph_fun);
    eval(label_fun);
    %eval(strcat(strcat(strcat('graph2txt(', dataset_name), '_graph_train, '''), strrep(data{i}, '_graph_label_train_test', '_graph_train'')')));
end
disp('Done!');