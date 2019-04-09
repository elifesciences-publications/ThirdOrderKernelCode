function Analysis_Function_Simulation_STC(filepath, kernel_identifier,varargin)
saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


% this is for one fly
barUse = [8:13];
maxTau_Use = 32;

first_order_kerenl =  Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','first');
second_order_kernel = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','second');
flickSave = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data', 'flick');
% arranged into
second_order_kernel_noise =  Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','second_noise');
roiSelected = {[1,2,3,4]};
% plot for the signal to noise. could be used for individual rois.
Analyze_Function_Individual_Fly_PlotSinalToNoise_Draft(filepath, kernel_identifier,'roiSelected', roiSelected{1},'saveFigFlag',saveFigFlag);
close all
% how about the visualization.
% where is you visulization function?
% where did you plot that?
roiUse = find(roiSelected{1});
% remember fly id ...
filepath_parts = strsplit(filepath,'\');
fileID_name = filepath_parts{end};
for rr = 1:1:length(roiUse)
    roi_this = roiUse(rr);
    %% get data
    cov_mat = squeeze(second_order_kernel{1}(:,:,rr));
    n_noise = length(second_order_kernel_noise);
    cov_mat_noise = cell(n_noise, 1);
    for nn = 1:1:n_noise
        cov_mat_noise{nn} = squeeze(second_order_kernel_noise{nn}(:,:,rr));
    end
    first_kernel = squeeze(first_order_kerenl{1}(:,:,rr));
    
    % these are every import... try this on real data.
    MakeFigure;
    quickViewCovMat_SelectBars(cov_mat, barUse, 32, maxTau_Use ,'plotFlag', true);
    if saveFigFlag
        MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['cov_mat'],'nFigSave',2,'fileType',{'png','fig'});
    end
    % STC analysis starts
    % full covmat
    cov_mat_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat,'upper_half');
    STC_Utils_EigenVectorAnalysisForCovMat(cov_mat_sym ,  first_kernel,'plotFlag',true);
    if saveFigFlag
        MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_full'],'nFigSave',2,'fileType',{'png','fig'});
    end
    % half covmat
    
    cov_mat_sym_small = quickViewCovMat_SelectBars(cov_mat_sym, barUse, 32, maxTau_Use ,'plotFlag', false);
    cov_mat_noise_sym_small = cell(n_noise, 1);
    for nn = 1:1:n_noise
        cov_mat_noise_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat_noise{nn},'upper_half');
        cov_mat_noise_sym_small{nn} = quickViewCovMat_SelectBars(cov_mat_noise_sym, barUse, 32, maxTau_Use ,'plotFlag', false);
    end
    
    % significant test.
    STC_Utils_EigenVectorAnalysisForCovMat( cov_mat_sym_small ,  first_kernel(1: maxTau_Use ,  barUse ),'plotFlag',true, 'nMultiBars', length(barUse));
    if saveFigFlag
        MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_short'],'nFigSave',2,'fileType',{'png','fig'});
    end
    %
    %     STC_Utils_EigenVectorAnalysisForCovMat_CompareEigenWithFirst( cov_mat_sym_small ,  first_kernel(1: maxTau_Use ,  barUse ),'plotFlag',true, 'nMultiBars', length(barUse));
    %     if saveFigFlag
    %         MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_short_compare_with_first'],'nFigSave',2,'fileType',{'png','fig'});
    %     end
    
%     STC_Utils_SigTest_Utils_NestedSigTest(cov_mat_sym_small,cov_mat_noise_sym_small, 'n_nested_max',1); % within the noise.
%     if saveFigFlag
%         MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_short_sigtest'],'nFigSave',2,'fileType',{'png','fig'});
%     end
    % LN fitting.
    
    [cov_mat_eigenvector_all,D] = eig(cov_mat_sym_small); cov_mat_eigenvector = zeros(maxTau_Use , length(barUse),2);
    for ii = 1:1:2
        cov_mat_eigenvector(:,:,ii) = reshape(cov_mat_eigenvector_all(:,end - ii + 1),[maxTau_Use , length(barUse)]);
    end
    STC_Utils_PredResp_ARMA(flickSave.respData(rr),flickSave.stimData, flickSave.stimIndexed(rr), cov_mat_eigenvector, ...
        'nMultiBars', length(barUse), 'barUse',barUse,'edge_distribution', 'histeq','nOneBin',30,'nBin', [10,10]);
    if saveFigFlag
        MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_ln'],'nFigSave',2,'fileType',{'png','fig'});
    end
    close all
end