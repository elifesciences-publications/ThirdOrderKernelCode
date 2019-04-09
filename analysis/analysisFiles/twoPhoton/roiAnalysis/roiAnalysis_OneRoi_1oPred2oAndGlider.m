function roi = roiAnalysis_OneRoi_1oPred2oAndGlider(roi)
dt = [-8:1:8];
tMax = 20;
firstKernel = roi.filterInfo.firstKernel.Adjusted;
% store it somewhere..
% the predicted second order kernel will be much smaller...
[maxTau,nMultiBars] = size(firstKernel);
secondKernelPred = zeros(maxTau^2,nMultiBars,2);
gliderRespPred = zeros(length(dt),nMultiBars,2);

for dx = 1:1:2
    for qq = 1:1:nMultiBars
        f1 = firstKernel(:,qq);
        f2 = firstKernel(:,MyMode(qq + dx,nMultiBars));
        kernel2o = f1 * f2';
        secondKernelPred(:,qq,dx) = kernel2o(:);
        gliderRespPred(:,qq,dx) = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(kernel2o(:),'dt',dt,'tMax',tMax);

    end
end
pred2o.dx1.kernel = secondKernelPred(:,:,1);
pred2o.dx2.kernel = secondKernelPred(:,:,2);
pred2o.dx1.glider = gliderRespPred(:,:,1);
pred2o.dx2.glider = gliderRespPred(:,:,2);

roi.filterInfo.firstKernel.pred2o = pred2o;

end