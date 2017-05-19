%For MIMLBOOST:
%Set training bags ("train_bags") and testing bags ("test_bags") according to the experimental data
%Set training target values ("train_target") and testing target values ("test_target") accordingly
%Set training rounds ("rounds") accordingly

%Suppose Gaussian kernel SVM with default parameters are used:

svm.type='RBF';
svm.para=1;%the value of "gamma"
cost=1;% the value of "C"

%call MIMLBoost_train and MIMLBoost_test

[classifiers,c_values,Iter]=MIMLBoost_train(train_bags,train_target,rounds,svm,cost);
[HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels]=MIMLBoost_test(test_bags,test_target,classifiers,c_values,Iter);


%**************************************************************************
%For MIMLSVM

%Set training bags ("train_bags") and testing bags ("test_bags") according to the experimental data
%Set training target values ("train_target") and testing target values ("test_target") accordingly

ratio=0.2;%parameter "k" is set to be 20% of the number of training bags

%Suppose Gaussian kernel SVM are used:

svm.type='RBF';
svm.para=0.2;%the value of "gamma"
cost=1;% the value of "C"

%call MLMLSVM
[HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels]=MIMLSVM(train_bags,train_target,test_bags,test_target,ratio,svm,cost);