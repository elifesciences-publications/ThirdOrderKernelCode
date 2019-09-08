function Generate_VisualStim_And_VelEstimation_Main(kernel_extraction_method, kernel_mode_process_stim, FWHM_bank, distribution_bank, vel_range_bank, temporal_filter_tau_bank, varargin)
contrast_form = 'static';
synthetic_flag = false;
synthetic_type = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

image_process_info.contrast = contrast_form;
image_process_info.he = 0;
velocity_estimation.space_range = 54;
n_samplepoints = 2000;
nSps = 500; %

%% parameters.
% This duration needs to be changed.
if strcmp(kernel_extraction_method,'Holly_OLS')
    duration = 1/60 * (50 - 1);
else
    duration = 1/60 * (64 - 1);
end
image = ParameterFile_ImageMetaInfo();
time = ParameterFile_TimeInfomation(duration);
stim = ParameterFile_SimuSample(n_samplepoints, nSps);


%  set a large computation. several kinds.
process_stim_flag = false;
for ii = 1:1:length(distribution_bank)
    for jj = 1:1:length(vel_range_bank)
        velocity.distribution = distribution_bank{ii};
        velocity.range = vel_range_bank(jj);
        switch image_process_info.contrast
            case 'dynamic'
                parfor kk = 1:1:length(temporal_filter_tau_bank)
                    image_process_info_this = image_process_info;
                    image_process_info_this.FWHM = [];
                    image_process_info_this.tf_tau = temporal_filter_tau_bank(kk);
                    kernel = Load_Kernel_For_NS(0 , [], kernel_extraction_method);
                    tic
                    Generate_VisualStim_And_VelEstimation(image_process_info_this, image, stim, velocity, time, kernel,'synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
                    toc
                    
                end
            case 'dynamic_both_future_and_past'
                 parfor kk = 1:1:length(temporal_filter_tau_bank)
                    image_process_info_this = image_process_info;
                    image_process_info_this.FWHM = [];
                    image_process_info_this.tf_tau = temporal_filter_tau_bank(kk);
                    kernel = Load_Kernel_For_NS(0 , [], kernel_extraction_method);
                    tic
                    Generate_VisualStim_And_VelEstimation(image_process_info_this, image, stim, velocity, time, kernel,'synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
                    toc
                    
                end
            case 'static'
                parfor kk = 1:1:length(FWHM_bank)
                    image_process_info_this = image_process_info;
                    image_process_info_this.FWHM = FWHM_bank(kk);
                    process_stim_FWHM = FWHM_bank(kk);
                    image_process_info_this.tf_tau = [];
                    if kernel_mode_process_stim
                        kernel = Load_Kernel_For_NS(process_stim_flag , process_stim_FWHM, kernel_extraction_method);
                    else
                        kernel = Load_Kernel_For_NS(0 , [], kernel_extraction_method);
                    end
                    
                    tic
                    Generate_VisualStim_And_VelEstimation_NS_SynNS_Together(image_process_info_this, image, stim, velocity, time, kernel,'synthetic_flag',synthetic_flag, 'synthetic_type',synthetic_type);
                    toc
                end
        end
    end
end
end