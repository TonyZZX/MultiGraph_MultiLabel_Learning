% This script is used to extract labels of MSRC v2 into one file.
% We consider the cleaned-up version by Malisiewicz and Efros as our annotations.
clear;
list = importdata('./list.txt');
label_file = fopen('MSRC_v2_label', 'w');
list_len = length(list);
for i = 1 : list_len
    load(['./newsegmentations_mats/', list{i}]);
    pos_labels = unique(newlabels);
    % There are 23 labels in total.
    labels(1:23) = -1;
    for j = 1 : length(pos_labels)
        labels(pos_labels(j)) = 1;
    end
    % Write to file
    fprintf(label_file, 't # %d\n', i - 1);
    for j = 1 : 23
        fprintf(label_file, 'l %d %d\n', j - 1, labels(j));
    end
end
fclose(label_file);