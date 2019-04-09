function I_syn = Generate_VisualStim_Synthetic_Spatial_Corr(fft_mag)
% first, get rid of 0 frequency power.
fft_mag(1) = 0;

NFFT = length(fft_mag);
if mod(NFFT, 2) == 1
    % power is scaled to 1.
    mag_Y = fft_mag./std(fft_mag);
%     mag_Y = fft_mag;
    phase_Y_half = rand(1,(NFFT - 1)/2 ) * 2 * pi;
    
    % for negative frequency, the phase is set to the negative of that of
    % positive side.
    phase_Y = [0, phase_Y_half,  -phase_Y_half(end:-1:1)];
    Y_random_phase = mag_Y .* exp(phase_Y  * sqrt(-1));
    
    %
    y_random = ifft(Y_random_phase, 'symmetric');
    I_syn = y_random * 8; % d
%     I_syn = y_random;
else
    warning('the length of fft is not correct');
    keyboard;
end
end

% MakeFigure;
% subplot(2,1,1)
% plot(fft_mag(2:(NFFT + 1)/2)); hold on; plot(fft_mag( end:-1:(NFFT + 1)/2 + 1));
% subplot(2,1,2);
% plot(phase_Y (2:(NFFT + 1)/2)); hold on; plot(phase_Y (end:-1:(NFFT + 1)/2 + 1 ));
%
% MakeFigure;
% subplot(2,1,1)
% plot(abs( Y_random_phase(2:(NFFT + 1)/2))); hold on; plot( abs(Y_random_phase( end:-1:(NFFT + 1)/2 + 1)));
% subplot(2,1,2);
% plot( angle(Y_random_phase(2:(NFFT + 1)/2))); hold on; plot( angle(Y_random_phase(end:-1:(NFFT + 1)/2 + 1 )));
