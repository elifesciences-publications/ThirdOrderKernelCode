% this function is used to view the kernel for one roi...
% roi could be responsive to first order kernel, or second order kernel/

% if it only has first order kernel, plot first order, and
% all the second orders,

function quickViewKernelOneRoi(firstKernel,secondKernel,barUse,kernelType,varargin)
% outside function will tell me what is the bar to use..
nBars = length(barUse);
if nBars >= 3
    disp('there are a lot of rois being cared about....');
    return
end
if nBars == 0
    disp('no significant bars...');
    return
end
switch kernelType
    
    case 0
        subplot(2,2,1);
        quickViewOneKernel(firstKernel,1);
        title('was judged as no good kernels');
        set(gca,'xTick',barUse,'xTickLabel','+');
        colorbar
        
    case 1 % only first order filter existed...
        subplot(2,2,1);
        quickViewOneKernel(firstKernel,1);
        title('first order kernel only');
        set(gca,'xTick',barUse,'xTickLabel','+');
        colorbar
        
        subplot(2,2,2);
        quickViewOneKernel(secondKernel(:,barUse),2);
        colorbar
        title(['bar # :', num2str(barUse)]);
        
    case 2
        subplot(2,2,1);
        quickViewOneKernel(firstKernel,1);
        title('second order kernel only');
        set(gca,'xTick',barUse,'xTickLabel','+');
        colorbar
        
        subplot(2,2,2);
        quickViewOneKernel(secondKernel(:,barUse),2);
        colorbar
        title(['*bar # :', num2str(barUse)]);
        
        
    case 3
        subplot(2,2,1);
        quickViewOneKernel(firstKernel,1);
        title('1o and 2o are good');
        set(gca,'xTick',barUse,'xTickLabel','+');
        colorbar
        
         subplot(2,2,2);
        quickViewOneKernel(secondKernel(:,barUse),2);
        colorbar
        title(['*bar # :', num2str(barUse)]);
        
end

end