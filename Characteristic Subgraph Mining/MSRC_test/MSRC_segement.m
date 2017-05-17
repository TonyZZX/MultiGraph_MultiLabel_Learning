function [gBagsTrain,gBagsTest,train_target,test_target,trainY,testY] = MSRC_segement(MSRC_gBags,targets,inx_train,inx_test)

for i=1:length(inx_train)
    gBagsTrain{i}=MSRC_gBags{inx_train(i)};
    train_target(i,:)=targets(inx_train(i),:);
end
for j=1:length(inx_test)
    gBagsTest{j}=MSRC_gBags{inx_test(j)};
    test_target(j,:)=targets(inx_test(j),:);
end

train_target=train_target';
test_target=test_target';
trainY=graphedY(train_target);
testY=graphedY(test_target);