svm.type = 'RBF'
svm.para = 0.2

location = '/home/tony/Downloads/MIML/MIMLSVM_ZhouZhiHua/';
svm_lib = [location 'svm.cpp'];
svm_model_lib = [location 'svm_model_matlab.c'];
mex('-v', '-largeArrayDims', 'svmtrain_.c', svm_lib, svm_model_lib);