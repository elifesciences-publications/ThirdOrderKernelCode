close all
clear all

%% Test Data - different filters for each "fly"!

% testData_n
% nKernels('kernelOrder',3,'N',3,'maxTau',10,'testData',saveTestData)
% Z = masterKernels(3,'whichBehav','turn','which',[2 3 4 5 6],'whichNorm','internal')

for q = 1:4
    thisKernel = Z.cated.allVectors.k3_xxy(:,q);
    thisKernel = reshape(thisKernel,[10 10 10]);
    threeDvisualize_slices(10,9,thisKernel);
end

