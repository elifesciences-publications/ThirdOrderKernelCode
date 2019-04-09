function My_SVD_K3_Flattened(K3, R, varargin)
%%
special_name = [];
savefig_flag = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

dtxx_bank = 1:1:4;
dtxy_bank = -6:1:6;
tMax = 56;

maxTau = 64;
K3_Visualization = zeros(tMax, length(dtxy_bank),length(dtxx_bank));
for ii = 1:1:length(dtxx_bank)
    for jj = 1:1:length(dtxy_bank)
        dtxx = dtxx_bank(ii);
        dtxy = dtxy_bank(jj);
        [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);
        K3_Visualization(1:sum(~isnan(ind)),jj, ii) = K3(wind(:) == 1);
        
    end
end


% first, plot three components...
MakeFigure;
title_str = {'U \tau1', 'V \tau3 - \tau1', 'W \tau2 - \tau1'};
order = 3;
T = K3_Visualization;
U = cpd(T,R);
for ii = 1:1:R
    for jj = 1:1:order
        subplot(order, R, (jj - 1) * R + ii)
        u_this = U{jj}(:,ii);
        plot(u_this);
        title(title_str{jj});
        % different coordinates
        switch jj
            case 1
                ylabel(sprintf('component %d',ii))
                set(gca, 'XTick', 1:size(T, 1), 'XTickLabel',strsplit(num2str(1:tMax)));
            case 2
                ylabel(sprintf('component %d',ii))
                set(gca, 'XTick', 1:size(T, 2), 'XTickLabel', strsplit(num2str(dtxy_bank)));
            case 3
                ylabel(sprintf('component %d',ii))
                set(gca, 'XTick', 1:size(T, 3), 'XTickLabel', strsplit(num2str(dtxx_bank)));
        end
        
    end
end
if savefig_flag
    MainName = sprintf( 'K3_Flattened_SVD_R_%d_Component', R);
    MySaveFig_Juyue(gcf,MainName, special_name, 'nFigSave',2,'fileType',{'png','fig'});
end
% second, plot the kernel. and the recovered from three component.
K3_recover = cpdgen(U);
K3_residual = K3_Visualization - K3_recover;
n_dtxx_bank = length(dtxx_bank);
numsubplot_bank = {1:n_dtxx_bank, n_dtxx_bank + [1:n_dtxx_bank], 2 * n_dtxx_bank + [1:n_dtxx_bank]};
clim = max(abs(K3_Visualization(:)));
numsubplot_size = [3, n_dtxx_bank];
text_xpos =  - n_dtxx_bank - 6;
text_ypos = tMax/2;
MakeFigure;
K3_SVD_Utils(K3_Visualization, tMax, dtxx_bank, dtxy_bank, clim,  numsubplot_size, numsubplot_bank{1});
subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{1}(1));
text(text_xpos, text_ypos, 'original K3','FontSize', 15);
K3_SVD_Utils(K3_recover, tMax, dtxx_bank, dtxy_bank, clim, numsubplot_size, numsubplot_bank{2});
subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{2}(1));
text(text_xpos, text_ypos, 'recovered K3','FontSize', 15);
K3_SVD_Utils(K3_residual, tMax, dtxx_bank, dtxy_bank, clim, numsubplot_size, numsubplot_bank{3});
subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{3}(1));
text(text_xpos, text_ypos, 'residual K3','FontSize', 15);
if savefig_flag
    MainName = sprintf( 'K3_Flattened_SVD_R_%d_Kernel', R);
    MySaveFig_Juyue(gcf,MainName, special_name, 'nFigSave',2,'fileType',{'png','fig'});
end
end


function K3_SVD_Utils(K3_Visualization,tMax,  dtxx_bank, dtxy_bank, clim, numsubplot_size, numsubplot)
% MakeFigure;
% maxValue = max(abs(K3_Visualization(:)));
for ii = 1:1:length(dtxx_bank)
    subplot(numsubplot_size(1), numsubplot_size(2), numsubplot(ii))
    quickViewOneKernel(K3_Visualization(:,:,ii), 1, 'labelFlag', false, 'set_clim_flag', true, 'clim', clim);
    %     if ii == 3
    %         xlabel('\tau3 - \tau1');
    %     end
    set(gca, 'XTick', 1: length(dtxy_bank), 'XTickLabel', strsplit(num2str(dtxy_bank)));
    ylabel('\tau1');
    yLim = get(gca, 'YLim');
    % plot the dt = 0 line...
    hold on
    tau3_tau1 = find(dtxy_bank == 0);
    plot([tau3_tau1,tau3_tau1], [0, tMax], 'k--')
    tau3_tau2 = find(dtxy_bank == dtxx_bank(ii));
    plot([tau3_tau2,tau3_tau2], [0, tMax], 'k--');
    tau1_tau2_middle = (dtxx_bank(ii)/2) + tau3_tau1;
    plot([tau1_tau2_middle,tau1_tau2_middle], [0, tMax], 'r--');
    %     ConfAxis
    title(['\tau2 - \tau1 = ', sprintf('%d',dtxx_bank(ii))]);
    % title, the middle line and the label.
end
end

