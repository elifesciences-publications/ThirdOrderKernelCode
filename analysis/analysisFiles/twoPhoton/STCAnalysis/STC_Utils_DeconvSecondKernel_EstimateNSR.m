function  est_nsr = STC_Utils_DeconvSecondKernel_EstimateNSR(covMatrix,varargin)
plotFigFlag = false;
saveFigFlag = false;
typeStr = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% you need a center. let us  the dignal line will be perfect.
nMultiBars = 20;
maxTau = size(covMatrix,1)/nMultiBars; % you might want to change it in the future.
tMax = maxTau/2; % tMax has to be an even number
diagOffSet = [- (maxTau/2):1: (maxTau/2)]';

cov_fft_cell = cell(nMultiBars, nMultiBars);
for ii = 1:1:nMultiBars
    for jj = 1:1:nMultiBars
        indi = (ii - 1) * maxTau + 1: ii * maxTau;
        indj = (jj - 1) * maxTau + 1: jj * maxTau;
        
        kernel = covMatrix(indi, indj);
        
        kernel_fft = zeros(tMax/2, length(diagOffSet));
        for dd = 1:1:length(diagOffSet)
            diag_ind = find(triu(true(maxTau,maxTau),diagOffSet(dd)) & tril(true(maxTau,maxTau),diagOffSet(dd)));
            diag_val = kernel(diag_ind(1:tMax));
            
            % get the abosolute value of the fft of the kernel
            diag_val_fft = fft(diag_val);
            diag_val_fft_half_abs = abs(diag_val_fft(1:tMax/2));
            diag_val_fft_half_abs(2:end) = 2 * diag_val_fft_half_abs(2:end);
            kernel_fft(:,dd) = diag_val_fft_half_abs;
        end
        
        cov_fft_cell{ii,jj} = kernel_fft;
        
        % do a fourier transform on it.
    end
    % this would be a second order kernel.
end


% plot the whole thing. and label it properly...
% signal will be estimated using
% 1. center of the covMatrix.
% 2. first several frequencies
% 3. dt -2 2.
% estimation of the signal.

% they should share some signal to noise?
 dt_for_sig = -1:1:1;
df_for_sig = 2; % first two low frequencies
x_for_sig = [10,11]; % might 10/10, 10/11, 11/10,11/11
sig_estimation_val = zeros(length(x_for_sig), length(x_for_sig), length(df_for_sig), length(dt_for_sig));
for xx_1 = 1:1:length(x_for_sig)
    for xx_2 = 1:1:length(x_for_sig)
        for dff = 1:1:length(df_for_sig)
            for dtt = 1:1:length(dt_for_sig)
                sig_estimation_val(xx_1, xx_2, dff, dtt) = cov_fft_cell{x_for_sig(xx_1), x_for_sig(xx_2)}(df_for_sig(dff),diagOffSet == dt_for_sig(dtt));
            end
        end
    end
end

sig_est = mean(sig_estimation_val(:));
% look at the value, you underestimate the value?


% noise estimation.
dt_for_noise = [-(maxTau/2):1:-1/2 * (maxTau/2),  1/2 * (maxTau/2):1:(maxTau/2)]';
df_for_noise = 10:tMax/2; % first two low frequencies
x_for_noise = [1:6]; %

noise_estimation_val = zeros(length(x_for_noise), length(x_for_noise), length(df_for_noise), length(dt_for_noise));
for xx_1 = 1:1:length(x_for_noise)
    for xx_2 = 1:1:length(x_for_noise)
        for dff = 1:1:length(df_for_noise)
            for dtt = 1:1:length(dt_for_noise)
                noise_estimation_val(xx_1, xx_2, dff, dtt) = cov_fft_cell{xx_1, xx_2}(df_for_noise(dff),diagOffSet == dt_for_noise(dtt));
            end
        end
    end
end
noise_est = mean(noise_estimation_val(:));

est_nsr = (noise_est./sig_est).^2;

if plotFigFlag
    % Visualize the Fourier Transform.
    MakeFigure;
    quickViewOneKernel(cell2mat(cov_fft_cell),1,'labelFlag',false);
    for ii = 1:1:nMultiBars
        hold on
        plot([0,nMultiBars * length(diagOffSet)],[ii * tMax/2, ii * tMax/2],'k--');
    end
    for ii = 1:1:nMultiBars
        hold on
        plot([ii * length(diagOffSet), ii * length(diagOffSet)],[0,nMultiBars * tMax],'k--');
    end
    set(gca, 'XTick' ,(1:nMultiBars) *  length(diagOffSet) - length(diagOffSet)/2, 'XTickLabel',strsplit(num2str([1:nMultiBars])));
    set(gca, 'YTick' ,(1:nMultiBars) *  tMax/2 - tMax/4, 'YTickLabel',strsplit(num2str([1:nMultiBars])));
    xlabel('bar #','FontSize',18);
    ylabel('bar #','FontSize',18);
    % get a better label.
    
    ax = gca;
    ax.YLabel.FontSize = 20;
    ax.XLabel.FontSize = 20;
    set(gca,'FontSize',20,'box','off','FontName','Arial');
    if saveFigFlag
        MySaveFig_Juyue(gcf,'SecondKernel_FFT',typeStr,'nFigSave',2,'fileType',{'fig','png'})
    end
    
    MakeFigure; % plot the one you used to estimate Signal.
    quickViewOneKernel(cell2mat(cov_fft_cell(x_for_sig,x_for_sig)),1,'labelFlag',false);
    for ii = 1:1:length(x_for_sig)
        hold on
        plot([0,length(x_for_sig) * length(diagOffSet)],[ii * tMax/2, ii * tMax/2],'k--');
    end
    for ii = 1:1:length(x_for_sig)
        hold on
        plot([ii * length(diagOffSet), ii * length(diagOffSet)],[0,length(x_for_sig) * tMax],'k--');
    end
    for ii = 1:1:length(x_for_sig)
        hold on
        plot([(ii - 1) * length(diagOffSet) + find(diagOffSet == 0), (ii - 1) * length(diagOffSet) + find(diagOffSet == 0)],[0,length(x_for_sig) * tMax],'k--');
    end
    % add a one more line on the dt 0
    set(gca, 'XTick' ,(1:length(x_for_sig)) *  length(diagOffSet) - length(diagOffSet)/2, 'XTickLabel',strsplit(num2str(x_for_sig)));
    set(gca, 'YTick' ,(1:length(x_for_sig)) *  tMax/2 - tMax/4, 'YTickLabel',strsplit(num2str(x_for_sig)));
    xlabel('bar #','FontSize',18);
    ylabel('bar #','FontSize',18);
    % get a better label.
    
    ax = gca;
    ax.YLabel.FontSize = 20;
    ax.XLabel.FontSize = 20;
    set(gca,'FontSize',20,'box','off','FontName','Arial');
    if saveFigFlag
        MySaveFig_Juyue(gcf,'SecondKernel_FFT_ForSig',typeStr,'nFigSave',2,'fileType',{'fig','png'})
    end
    
    
end

