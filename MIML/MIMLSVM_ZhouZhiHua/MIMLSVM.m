function [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,tr_time,te_time]=MIMLSVM(train_bags,train_target,test_bags,test_target,ratio,svm,cost)
%MIMLSVM implements the MIMLSVM algorithm as shown in [1].
%
%N.B.: MIMLSVM employs the Matlab version of Libsvm [2] (available at http://sourceforge.net/projects/svm/) to implement the ML-SVM [3] algorithm as shown in [1]
%
%    Syntax
%
%       [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,tr_time,te_time]=MIMLSVM(train_bags,train_target,test_bags,test_target,ratio,svm,cost)
%
%    Description
%
%       MIML_TO_MLL takes,
%           train_bags       - An M1x1 cell, the jth instance of the ith training bag is stored in train_bags{i,1}(j,:)
%           train_target     - A QxM1 array, if the ith training bag belongs to the jth class, then train_target(j,i) equals +1, otherwise train_target(j,i) equals -1
%           test_bags        - An M2x1 cell, the jth instance of the ith test bag is stored in test_bags{i,1}(j,:)
%           test_target      - A QxM2 array, if the ith test bag belongs to the jth class, test_target(j,i) equals +1, otherwise test_target(j,i) equals -1
%           ratio            - The number of clusters used by MIMLSVM (as shown in [1]) is set to be ratio*M1
%           svm              - svm.type gives the type of svm used in training, which can take the value of 'RBF', 'Poly' or 'Linear'; svm.para gives the corresponding parameters used for the svm:
%                              1) if svm.type is 'RBF', then svm.para gives the value of gamma, where the kernel is exp(-Gamma*|x1-x2|^2) for two vectors x1 and x2
%                              2) if svm.type is 'Poly', then svm.para(1:3) gives the value of gamma, coefficient, and degree respectively, where the kernel is (gamma*<x1,x2>+coefficient)^degree.
%                              3) if svm.type is 'Linear', then svm.para is [].
%           cost             - The cost parameter used for the base svm classifier
%      and returns,
%           HammingLoss      - The hamming loss on testing data as described in [4]
%           RankingLoss      - The ranking loss on testing data as described in [4]
%           OneError         - The one-error on testing data as described in [4]
%           Coverage         - The coverage on testing data as described in [4]
%           Average_Precision- The average precision on testing data as described in [4]
%           Outputs          - A QxM array, the output of the ith testing instance on the jth class is stored in Outputs(j,i)
%           Pre_Labels       - A QxM array, if the ith testing instance belongs to the jth class, then Pre_Labels(j,i) is +1, otherwise Pre_Labels(j,i) is -1
%           tr_time          - The training time
%           te_time          - The testing time
%
% [1] Z.-H. Zhou and M.-L. Zhang. Multi-instance multi-label learning with application to scene classification. In: Advances in Neural Information Processing Systems 19 (NIPS'06) (Vancouver, Canada), B. Sch??lkopf, J. Platt, and T. Hofmann, eds. Cambridge, MA: MIT Press, 2007. 
% [2] C.-C. Chang and C.-J. Lin. Libsvm: a library for support vector machines, Department of Computer Science and Information Engineering, National Taiwan University, Taipei, Taiwan, Technical Report, 2001.
% [3] M. R. Boutell, J. Luo, X. Shen, and C. M. Brown. Learning multi-label scene classification. Pattern Recognition, 37(9): 1757-1771, 2004.
% [4] Schapire R. E., Singer Y. BoosTexter: a boosting based system for text categorization. Machine Learning, 39(2/3): 135-168, 2000.
     
     %Preparing data
     tr_time=0;
     te_time=0;
     
     time_stamp=cputime;
     
     [num_class,num_train]=size(train_target);
     [num_class,num_test]=size(test_target);
     num_cluster=floor(ratio*num_train);
     
     
     %clustering
     disp('Performing k-medoids clustering on training bags...');
     distance_matrix=zeros(num_train,num_train);
     for bags1=1:(num_train-1)
         for bags2=(bags1+1):num_train
             distance_matrix(bags1,bags2)=maxHausdorff(train_bags{bags1,1},train_bags{bags2,1});
         end
     end
     distance_matrix=distance_matrix+distance_matrix';
     [clustering,matrix_fai,num_iter]=MIML_cluster(num_cluster,distance_matrix);      
     
     %transform MIML problem to multi-label problem
     disp('Transforming multi-instance multi-label problem into multi-label problem...');
     
     train_data=matrix_fai;     
     
     time_interval=cputime-time_stamp;
     tr_time=tr_time+time_interval;
     
     time_stamp=cputime;
     
     test_data=zeros(num_test,num_cluster);
     for bags1=1:num_test
         for bags2=1:num_cluster
             test_data(bags1,bags2)=maxHausdorff(test_bags{bags1,1},train_bags{clustering{bags2,1},1});
         end
     end
     
     time_interval=cputime-time_stamp;
     te_time=te_time+time_interval;
     
     
     %Solving the transformed multi-label problem
     disp('Solving the transformed multi-label problem...');
     
     Outputs=zeros(num_class,num_test);
     Pre_Labels=-ones(num_class,num_test);

     for i=1:num_class         
         time_stamp=cputime;
         
         if(strcmp(svm.type,'RBF'))
             t=2;
             gamma=svm.para;
             str=['-t ',num2str(t),' -g ',num2str(gamma),' -c ',num2str(cost)];
         else
             if(strcmp(svm.type,'Poly'))
                 t=1;
                 gamma=svm.para(1);
                 coefficient=svm.para(2);
                 degree=svm.para(3);
                 str=['-t ',num2str(t),' -d ',num2str(degree),' -g ',num2str(gamma),' -r ',num2str(coefficient),' -c ',num2str(cost)];
             else
                 t=0;                 
                 str=['-t ',num2str(t),' -c ',num2str(cost)];
             end
         end
         model=svmtrain_(train_target(i,:)',train_data,str);
         
         time_interval=cputime-time_stamp;
         tr_time=tr_time+time_interval;
         
         time_stamp=cputime;
         
         [predict_label, accuracy, dec_values] = svmpredict(test_target(i,:)', test_data, model);
         if(model.Label(1)==1)
             Outputs(i,:)=dec_values';
         else
             Outputs(i,:)=-dec_values';
         end
         
         time_interval=cputime-time_stamp;
         te_time=te_time+time_interval;
     end

     time_stamp=cputime;
     
     for i=1:num_test
         temp=Outputs(:,i);
         if(sum(temp<=0)==num_class)
             [maximum,index]=max(temp);
             Pre_Labels(index,i)=1;
         else
             for j=1:num_class
                 if(temp(j)>0)
                     Pre_Labels(j,i)=1;
                 end
             end
         end
     end

     HammingLoss=Hamming_loss(Pre_Labels,test_target);
    
     RankingLoss=Ranking_loss(Outputs,test_target);
     OneError=One_error(Outputs,test_target);
     Coverage=coverage(Outputs,test_target);
     Average_Precision=Average_precision(Outputs,test_target);
     
     time_interval=cputime-time_stamp;
     te_time=te_time+time_interval;
     
     disp(HammingLoss);
     disp(RankingLoss);
     disp(OneError);
     disp(Coverage);
     disp(Average_Precision);
    %disp(Outputs);
    disp(tr_time);
    disp(te_time);