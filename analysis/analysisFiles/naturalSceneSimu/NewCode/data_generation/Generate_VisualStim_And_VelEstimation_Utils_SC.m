function  x_syn = Generate_VisualStim_And_VelEstimation_Utils_SC(x, type, varargin)
%%
NFFT = length(x);
%ramdomize phase %% where do you do the rng for this?
phase_Y_half = rand(1,(NFFT - 1)/2 ) * 2 * pi;
mean_power_spectrum = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

mag_Y = abs(fft(x));
mag_Y(1) = 0; % mean is set to zero
individual_power_spectrum = mag_Y.^2;

% only maintain the spatial correlation between each other.
% not covariance, but correlation.
switch type
    case 'scramble_phase'
        fft_x = fft(x); % mean value is maintained.
        mag_Y_normalized = zeros(1,length(fft_x));
        mag_Y_normalized(1) = fft_x(1);
        mag_Y_normalized(2:end) = abs(fft_x(2:end));
    case 'individual_spatial_corr_mean_variance'
        mean_power_spectrum(1) = 0; 
        individual_power_spectrum_normalized = individual_power_spectrum/sum(individual_power_spectrum) * sum(mean_power_spectrum);   
        mag_Y_normalized = sqrt(individual_power_spectrum_normalized);
    case 'individual_spatial_corr_individual_variance'
        mag_Y_normalized = mag_Y;
        mag_Y_normalized(1) = 0;
    case 'maintain_spatial_corr_and_power'
        mag_Y_normalized = mag_Y; 
        
    case 'mean_spatial_corr_individual_variance'
        mean_power_spectrum(1) = 0;
        mean_spatial_corr_with_individual_variance = mean_power_spectrum/sum(mean_power_spectrum) * sum(individual_power_spectrum);
        mag_Y_normalized = sqrt(mean_spatial_corr_with_individual_variance);
   
    case 'mean_spatial_corr_mean_variance'
        mean_power_spectrum(1) = 0;
        % in energy unit. you have that function. cool!!
        mag_Y_normalized = sqrt(mean_power_spectrum);
end
%% ramdomize phase
% for negative frequency, the phase is set to the negative of that of
% positive side.
phase_Y = [0,phase_Y_half,  -phase_Y_half(end:-1:1)];

%%
Y = mag_Y_normalized .* exp(phase_Y  * sqrt(-1));
x_syn = ifft(Y, 'symmetric');
end



