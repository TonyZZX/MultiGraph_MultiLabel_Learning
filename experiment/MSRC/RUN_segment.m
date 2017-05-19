% ???§Ý???????????????????????????????
clear;
data = importdata('list.txt');
load('MSRC_label.mat');
load('MSRC_idx_train_test.mat');
for i = 1 : length(data)
%     clearvars -except data i
    load(strcat(data{i}, '.mat'));
    % ??? string ?????????
    MSRC_graph = eval(data{i});
    [MSRC_graph_train, MSRC_graph_test, MSRC_label_train, MSRC_label_test] = MSRC_segment(MSRC_graph, MSRC_label, idx_train, idx_test);
    MSRC_graph_train_name = strcat(data{i}, '_train');
    MSRC_graph_test_name = strcat(data{i}, '_test');
    MSRC_label_train_name = strcat(strrep(data{i}, 'graph', 'label'), '_train');
    MSRC_label_test_name = strcat(strrep(data{i}, 'graph', 'label'), '_test');
    eval(strcat(MSRC_graph_train_name, ' = MSRC_graph_train'));
    eval(strcat(MSRC_graph_test_name, ' = MSRC_graph_test'));
    eval(strcat(MSRC_label_train_name, ' = MSRC_label_train'));
    eval(strcat(MSRC_label_test_name, ' = MSRC_label_test'));
    clear MSRC_graph MSRC_graph_train MSRC_graph_test MSRC_label_train MSRC_label_test;
    save(strcat(data{i}, '_label_train_test.mat'), MSRC_graph_train_name, MSRC_graph_test_name, MSRC_label_train_name, MSRC_label_test_name)
end
