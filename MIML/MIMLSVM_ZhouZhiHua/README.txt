svm.type = 'RBF'
svm.para = 0.2

location = '/home/tony/Downloads/MIML/MIMLSVM_ZhouZhiHua/';
lapacklib = [location 'svm.cpp'];
blaslib = [location 'svm_model_matlab.c'];
mex('-v', '-largeArrayDims', 'svmtrain_.c', blaslib, lapacklib)