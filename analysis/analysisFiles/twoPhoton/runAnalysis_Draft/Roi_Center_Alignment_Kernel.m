function kernel_aligned = Roi_Center_Alignment_Kernel(roi,kernel,mode)
if strfind(mode, 'second') % mode could be: second, second_noise
    mode = 'cov_mat';
elseif strfind(mode, 'first') % mode could be: first, first_noise
    mode = 'first'; 
elseif strfind(mode, 'third')
    mode = 'third';
end

switch mode
    case 'cov_mat' 
        second_kernel_full = STC_Utils_CovMatToSecondKernel(kernel);
        second_kernel_full_aligned_flipped = Roi_Center_Alignment_SecondKernel_Full_Draft(roi,second_kernel_full);
        kernel_aligned = STC_Utils_SecondKernelToCovMat(second_kernel_full_aligned_flipped,'correctSelfTermFlag', false);
    case 'first'
        kernel_aligned = Roi_Center_Alignment_FirstOrderKernel(roi,kernel);
    case 'third'
        
end