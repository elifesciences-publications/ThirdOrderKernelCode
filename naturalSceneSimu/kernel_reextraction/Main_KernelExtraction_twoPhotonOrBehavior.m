function data = Main_KernelExtraction_twoPhotonOrBehavior(respData, stimData, stimIndexes, order, noise, maxTau, arma_flag, kr, dx, process_stim_flag, data_source, varargin)
maxTau_r = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if process_stim_flag && strcmp(data_source, 'behavior')
    barWidth = 5;
    behavior_kernel_all_phase = cell(5,1);  
    for ii = 1:1:barWidth
        stim_one_phase = stimData(:,ii:barWidth:end);
        kernel_one_phase =  Main_KernelExtraction_ReverseCorr(respData, stim_one_phase , stimIndexes, ...
            'order', order, 'donoise', noise , 'maxTau', maxTau, 'arma_flag', arma_flag,'kr',kr,'dx',dx,'maxTau_r', maxTau_r);
        behavior_kernel_all_phase{ii} = kernel_one_phase{1};
    end
    behavior_kernel_all = cat(4, behavior_kernel_all_phase{:});
    behavior_kernel_mean = mean(behavior_kernel_all, 4);
    data =  {behavior_kernel_mean};
else
    data = Main_KernelExtraction_ReverseCorr(respData, stimData, stimIndexes, ...
    'order', order, 'donoise', noise, 'maxTau', maxTau, 'arma_flag', arma_flag,'kr',kr,'dx', dx,'maxTau_r', maxTau_r);
end
end
