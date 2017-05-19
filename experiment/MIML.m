function [  ] = MIML( file_name, out_file_name )
    % prepare
    load(file_name);
    dataset_name = file_name(strfind(file_name, '/') + 1 : strfind(file_name, '_fre') - 1);
    fre = file_name(strfind(file_name, '_fre') + 4 : strfind(file_name, '_time') - 1);
    time = file_name(strfind(file_name, '_time') + 5 : strfind(file_name, '_subg') - 1);
    subg = file_name(strfind(file_name, '_subg') + 5 : strfind(file_name, 'fs') - 1);
    fs = file_name(strfind(file_name, 'fs') + 2 : strfind(file_name, '_instance') - 1);
    
    fun_str = ['instance_train = ', dataset_name, '_instance_train;'];
    eval(fun_str);
    fun_str = ['instance_test = ', dataset_name, '_instance_test;'];
    eval(fun_str);
    fun_str = ['label_train = ', dataset_name, '_label_train;'];
    eval(fun_str);
    fun_str = ['label_test = ', dataset_name, '_label_test;'];
    eval(fun_str);
    
    ratio = [0.2, 0.4, 0.6, 0.8];
    hn = [100, 150, 200];
    
    fileID = fopen(out_file_name, 'a');
    %fprintf(fileID, 'name\tfre\ttime\tsubg\tfs\tMIML\tratio\thn\tHammingLoss\tRankingLoss\tOneError\tCoverage\tAverage_Precision\ttr_time\tte_time\n');
    
    % ELM
    addpath('../MIML/MIMLELM_LiChenGuang');
    for i = 1 : length(ratio)
        for j = 1 : length(hn)
            fprintf('Processing: %d/%d, %d/%d\n', i, length(ratio), j, length(hn));
            [HammingLoss, RankingLoss, OneError, Coverage, Average_Precision, tr_time, te_time] = MIMLSVM(instance_train, label_train, instance_test, label_test, ratio(i), hn(j));
            fprintf(fileID, '%s\t%s\t%s\t%s\t%s\tELM\t%f\t%d\tNULL\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', dataset_name, fre, time, subg, fs, ratio(i), hn(j), HammingLoss, RankingLoss, OneError, Coverage, Average_Precision, tr_time, te_time);
        end
    end
    rmpath('../MIML/MIMLELM_LiChenGuang');
    
    % SVM
    svm.type = 'RBF';
    svm.para = 0.2;
    cost = [1, 3, 5];
    
    addpath('../MIML/MIMLSVM_ZhouZhiHua');
    for i = 1 : length(ratio)
        for j = 1 : length(hn)
            for k = 1 : length(cost)
                fprintf('Processing: %d/%d, %d/%d, %d/%d\n', i, length(ratio), j, length(hn), k, length(cost));
                [HammingLoss, RankingLoss, OneError, Coverage, Average_Precision, ~, ~, tr_time, te_time] = MIMLSVM(instance_train, label_train, instance_test, label_test, ratio(i), svm, cost(k));
                fprintf(fileID, '%s\t%s\t%s\t%s\t%s\tSVM\t%f\tNULL\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', dataset_name, fre, time, subg, fs, ratio(i), cost(k), HammingLoss, RankingLoss, OneError, Coverage, Average_Precision, tr_time, te_time);
            end
        end
    end
    rmpath('../MIML/MIMLSVM_ZhouZhiHua');
    delete train_data*;
    delete test_data*;
end