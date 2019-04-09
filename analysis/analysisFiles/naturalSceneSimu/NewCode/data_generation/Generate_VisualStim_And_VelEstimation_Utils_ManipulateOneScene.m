function [x_manipulation_all, solved_flag_all] = Generate_VisualStim_And_VelEstimation_Utils_ManipulateOneScene(x, type_bank,varargin)
med = [];
med_predetermined_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

x_manipulation_all = cell(length(type_bank), 1);
solved_flag_all = zeros(length(type_bank), 1);

NFFT = length(x);
phase_Y_half = rand(1,(NFFT - 1)/2 ) * 2 * pi;
for ii = 1:1:length(x_manipulation_all)
    [x_manipulation_all{ii},solved_flag_all(ii)] = ManipulateOneScene_With_One_Condition(x, type_bank{ii}, 'phase_Y_half', phase_Y_half,varargin{:});
end

% MakeFigure;
% for ii = 1:1:length(x_manipulation_all)
%     subplot(length(x_manipulation_all), 1, ii);
%     plot( x_manipulation_all{ii})
% end
end

function [x_manipulation, solved_flag] = ManipulateOneScene_With_One_Condition(x, type, varargin)
phase_Y_half = rand(1,(length(x) + 1)/2 ) * 2 * pi;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if isempty(type)
    x_manipulation  =  x;
    solved_flag = true;
else
    switch type
        case 'maintain_spatial_corr' % maintain_spatial_corr is calculated together with scramble the phase.
            x_manipulation = Generate_VisualStim_And_VelEstimation_Utils_SC(x, type, 'phase_Y_half', phase_Y_half);
            solved_flag = true;
        case 'maintain_power'
            % mean spatial correlation...
        case 'scramble_phase'
            x_manipulation = Generate_VisualStim_And_VelEstimation_Utils_SC(x, type, 'phase_Y_half', phase_Y_half);
            solved_flag = true;
        case 'maintain_spatial_corr_and_power'
            x_manipulation = Generate_VisualStim_And_VelEstimation_Utils_SC(x, type, 'phase_Y_half', phase_Y_half);
            solved_flag = true;
        case 'med_sc_cd'
            if med_predetermined_flag
                x_manipulation  = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling_OneScene(med.x_solved_scale, med.gray_value_mean_subtracted_scale, med.gray_value, med.N, med.K, med.resolution_n_pixel);
                solved_flag = med.solved_flag;
            else
                [x_manipulation,solved_flag] = MaxEndDis_Utils_FromNS_To_SynS(x);
            end
        case 'med_mean_sc_cd'
            x_manipulation  = MaxEntDist_AllMar_TwoCov_Utils_GibbsSampling_OneScene(med.x_solved_scale, med.gray_value_mean_subtracted_scale, med.gray_value, med.N, med.K, med.resolution_n_pixel);
            
        otherwise
            keyboard;
    end
end
end