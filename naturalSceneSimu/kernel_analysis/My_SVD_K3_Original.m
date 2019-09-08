function My_SVD_K3_Original(K3, R, varargin)

special_name = [];
savefig_flag = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

maxTau = size(K3, 1);
U = cpd(K3,R);
T = K3;
MakeFigure;
title_str = {'U \tau1', 'V \tau2', 'W \tau3'};
order = 3;
for ii = 1:1:R
    for jj = 1:1:order
        subplot(order, R, (jj - 1) * R + ii)
        u_this = U{jj}(:,ii);
        plot(u_this);
        title(title_str{jj});
        ylabel(sprintf('component %d',ii))
        set(gca, 'XTick', 1:size(T, 1), 'XTickLabel',strsplit(num2str(1:maxTau)));
        
    end
end
if savefig_flag
    MainName = sprintf( 'K3_Original_SVD_R_%d_Component', R);
    MySaveFig_Juyue(gcf,MainName, special_name, 'nFigSave',2,'fileType',{'png','fig'});
end

% visualize(U, 'original', K3);
% plot the slices...
tau3_bank = 4:8;
K3_recover = cpdgen(U);
K3_residual = K3 - K3_recover;

n_tau3 = length(tau3_bank );
numsubplot_bank = {1:n_tau3, n_tau3 + [1:n_tau3], 2 * n_tau3 + [1:n_tau3]};
clim = max(abs(K3(:)));
numsubplot_size = [3, n_tau3];
text_xpos =  -40;
tMax = floor(maxTau/2);

text_ypos = tMax/2;
MakeFigure;
K3_SVD_Utils(K3, tau3_bank, tMax,clim,  numsubplot_size, numsubplot_bank{1});
subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{1}(1));
text(text_xpos, text_ypos, 'original K3','FontSize', 15);
K3_SVD_Utils(K3_recover, tau3_bank, tMax,clim, numsubplot_size, numsubplot_bank{2});
subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{2}(1));
text(text_xpos, text_ypos, 'recovered K3','FontSize', 15);
K3_SVD_Utils(K3_residual, tau3_bank, tMax,clim, numsubplot_size, numsubplot_bank{3});
subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{3}(1));
text(text_xpos, text_ypos, 'residual K3','FontSize', 15);
if savefig_flag
    MainName = sprintf( 'K3_Original_SVD_R_%d_Kernel', R);
    MySaveFig_Juyue(gcf,MainName, special_name, 'nFigSave',2,'fileType',{'png','fig'});
end
end

function K3_SVD_Utils(K3, tau3_bank, tMax, clim, numsubplot_size, numsubplot)
for ii = 1:1:length(tau3_bank)
    subplot(numsubplot_size(1), numsubplot_size(2), numsubplot(ii))
    K3_one_slice = K3(1:tMax,1:tMax,tau3_bank(ii));
    quickViewOneKernel(K3_one_slice(:), 2, 'labelFlag', true, 'set_clim_flag', true, 'clim', clim);
    title(['\tau3 = ', sprintf('%d',tau3_bank(ii))]);
    % title, the middle line and the label.
end
end