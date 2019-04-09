function [U, explained_perc] = My_SVD_K3_Flattened_Main(K3, varargin)
%% Tempting to destroy this function...
special_name = [];
savefig_flag = false;
tMax = 48;
mode = 'combine';
dtxy_bank = [-5:-1,1:5];
dtxx_bank = [-4:-1,1:4];
tau_21 = [];
tau_31 = [];
R = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
special_name = mode;
% you need to decide which mode to use
maxTau = 64;
if strcmp(mode, 'time_sym')
    
    [K3_Impulse_conv, dtxy_bank_conv,~] = K3_SVD_Utils_GetK3_Impulse( K3, dtxy_bank, dtxx_bank,'conv',tMax, maxTau);
    [K3_Impulse_div, dtxy_bank_div,~] = K3_SVD_Utils_GetK3_Impulse( K3, dtxy_bank, dtxx_bank, 'div', tMax, maxTau);
    K3_Impulse = K3_Impulse_conv + K3_Impulse_div;
    %     K3_Impulse = cat(3, K3_Impulse_conv,K3_Impulse_div);
    dtxy_bank = dtxy_bank_conv;
elseif strcmp(mode, 'conv_and_div')
    
    [K3_Impulse_conv, dtxy_bank_conv,~] = K3_SVD_Utils_GetK3_Impulse( K3, dtxy_bank, dtxx_bank,'conv',tMax, maxTau);
    [K3_Impulse_div, dtxy_bank_div,~] = K3_SVD_Utils_GetK3_Impulse( K3, dtxy_bank, dtxx_bank, 'div', tMax, maxTau);
    K3_Impulse = cat(3, K3_Impulse_conv,K3_Impulse_div);
    dtxy_bank = dtxy_bank_conv;
    
elseif strcmp(mode, 'SameSpatialSym')
    K3_Impulse = K3_SVD_Utils_GetK3_Impulse_SameSpatialSym(tau_21, tau_31, K3, tMax, maxTau);
    dtxy_bank = tau_21;
    dtxx_bank = tau_31;
    
else
    [K3_Impulse, dtxy_bank,dt_xx_bank] = K3_SVD_Utils_GetK3_Impulse( K3, dtxy_bank, dtxx_bank,mode,tMax, maxTau);
    
end
%%
% MakeFigure;
title_str = {'U most recent bar', 'V \tau3 - \tau1', 'W \tau2 - \tau1'};
order = 3;
T = K3_Impulse;
U = cpd(T,R);
%%
component_sign = ones(R, order);
for ii = 1:1:R
    component_sign(ii, 1) = sign(U{1}(20,ii));
    component_sign(ii, 2) = sign(U{2}(find((dtxy_bank == 1 |dtxy_bank == -1), 1),ii));
    component_sign(ii, 3) = sign(U{3}(find((dtxy_bank == 1 |dtxy_bank == -1), 1),ii));
end
for ii = 1:1:R
    for jj = 1:1:3
        U{jj}(:,ii) = U{jj}(:,ii) * component_sign(ii, jj) ;
        component_sign(ii, 3)  = component_sign(ii, 3) * component_sign(ii, jj);
    end
end
% adjusting the sign... sign of U1, sign of U2 is positive and negative.
% sign of U3 is set after that...

%%
if R == 2
    MakeFigure;
    for jj = 1:1:order
        subplot(3,3,1 + (jj - 1) * order);
        plot(U{jj}(:,1));hold on; plot(U{jj}(:,2)); ConfAxis;
        if jj == 1
            legend('component 1','component 2');
        end
        ylabel(title_str{jj});
        switch jj
            case 1
                set(gca, 'XTick', 1:size(T, 1), 'XTickLabel',strsplit(num2str(1:tMax)));
            case 2
                set(gca, 'XTick', 1:size(T, 2), 'XTickLabel', strsplit(num2str(dtxy_bank)));
            case 3
                set(gca, 'XTick', 1:size(T, 3), 'XTickLabel', strsplit(num2str(dtxx_bank)));
        end
        %
        subplot(3,3,2 + (jj - 1) * order);
        plot(U{jj}(:,1) + U{jj}(:,2));ConfAxis;
        if jj == 1
            title('addition');
        end
        switch jj
            case 1
                set(gca, 'XTick', 1:size(T, 1), 'XTickLabel',strsplit(num2str(1:tMax)));
            case 2
                set(gca, 'XTick', 1:size(T, 2), 'XTickLabel', strsplit(num2str(dtxy_bank)));
            case 3
                set(gca, 'XTick', 1:size(T, 3), 'XTickLabel', strsplit(num2str(dtxx_bank)));
        end
        %
        subplot(3,3, 3 + (jj - 1) * order);
        plot(U{jj}(:,1) - U{jj}(:,2));ConfAxis;
        if jj == 1
            title('subtraction');
        end
        
        switch jj
            case 1
                set(gca, 'XTick', 1:size(T, 1), 'XTickLabel',strsplit(num2str(1:tMax)));
            case 2
                set(gca, 'XTick', 1:size(T, 2), 'XTickLabel', strsplit(num2str(dtxy_bank)));
            case 3
                set(gca, 'XTick', 1:size(T, 3), 'XTickLabel', strsplit(num2str(dtxx_bank)));
        end
    end
else
    MakeFigure;
    for jj = 1:1:order
        if jj < 3
            subplot(3,1,jj);
            plot(U{jj}(:,1));
            ylabel(title_str{jj});
            ConfAxis;
            switch jj
                case 1
                    set(gca, 'XTick', 1:size(T, 1), 'XTickLabel',strsplit(num2str(1:tMax)));
                case 2
                    set(gca, 'XTick', 1:size(T, 2), 'XTickLabel', strsplit(num2str(dtxy_bank)));
            end
        elseif jj == 3
            subplot(3,1,3);
            plot(U{jj}(1:length(dtxx_bank),1));
            ylabel(title_str{jj});
            
            ConfAxis;
            set(gca, 'XTick', 1:size(T, 3), 'XTickLabel', strsplit(num2str(dtxx_bank)));
            
%             subplot(4,1,4);
%             plot(U{jj}(length(dtxx_bank)+1:end,1));
%             ylabel(title_str{jj});
%             
%             ConfAxis;
%             set(gca, 'XTick', 1:size(T, 3), 'XTickLabel', strsplit(num2str(dtxx_bank)));
        end
        hold on;
        plot(get(gca, 'XLim'), [0,0], 'k--');
    end
    
    if savefig_flag
        
        main_name = sprintf( 'K3_Flattened_SVD_R_%d_Component', R);
        text_str = [main_name, ' ' special_name];
        uicontrol('Style', 'text',...
            'String', text_str,... %replace something with the text you want
            'Units','normalized',...
            'Position', [0 0.9 0.15 0.1],'FontSize', 15);
        
        
        MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
    end
    %%
    % second, plot the kernel. and the recovered from three component.
    % how do you calculate the values?
    K3_recover = cpdgen(U);
    K3_residual = K3_Impulse - K3_recover;
    
    var_impulse = var(K3_Impulse(:));
    var_recover = var(K3_recover(:));
    var_residual = var(K3_residual(:));
    % percentage.
    explained_perc = var_recover./var_impulse;
    
    %% plot the residual
    n_dtxx_bank = length(dtxx_bank);
    numsubplot_bank = {1:n_dtxx_bank, n_dtxx_bank + [1:n_dtxx_bank], 2 * n_dtxx_bank + [1:n_dtxx_bank]};
    clim = max(abs(K3_Impulse(:)));
    numsubplot_size = [3, n_dtxx_bank];
    text_xpos =  - n_dtxx_bank - 6;
    text_ypos = tMax/2;
    MakeFigure;
    K3_SVD_Utils(K3_Impulse, tMax, dtxx_bank, dtxy_bank, clim,  numsubplot_size, numsubplot_bank{1});
    subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{1}(1));
    text(text_xpos, text_ypos, 'original K3','FontSize', 15);
    
    K3_SVD_Utils(K3_recover, tMax, dtxx_bank, dtxy_bank, clim, numsubplot_size, numsubplot_bank{2});
    subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{2}(1));
    text(text_xpos, text_ypos, sprintf('recovered K3\nexplained variance %d %', explained_perc),'FontSize', 15);
    K3_SVD_Utils(K3_residual, tMax, dtxx_bank, dtxy_bank, clim, numsubplot_size, numsubplot_bank{3});
    subplot(numsubplot_size(1),numsubplot_size(2), numsubplot_bank{3}(1));
    text(text_xpos, text_ypos, 'residual K3','FontSize', 15);
    
    % calculate how much variance is explained.
    if savefig_flag
        main_name = sprintf( 'K3_Flattened_SVD_R_%d_Kernel', R);
        % write down the name on the top left...
        
        text_str = [main_name, ' ' special_name];
        uicontrol('Style', 'text',...
            'String', text_str,... %replace something with the text you want
            'Units','normalized',...
            'Position', [0 0.9 0.15 0.1],'FontSize', 15);
        
        MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
    end
    
    %% look at the recover using glider response... that is a great idea.
    % Turn a K3_Impulse into a glider response...
    % [glider_str_3o,glider_resp_3o_mean_positive,glider_resp_3o_sem_positive] = Gilder_Response_Alone();
    % average_over_space_pairs = 53;
    % for ii = 1:1:n_glider_3o
    %     % turn K3 impulse into
    %     glider_name_this = glider_str_3o{ii};
    %     [dx, dt] = K3_Glider_Trans_Utils_Name_To_TauDx( glider_name_this);
    %     % after getting the dx dt... how to find the cor
    %     dx_which = find(cellfun(@(x) isequal(x, dx), dx_bank));
    %     corrParam = cell(1,1);
    %     corrParam{1}.dt = dt;
    %     k3_resp{ii,1} = zeros(1, n_flies_kernel);
    %
    %     for jj = 1:1:n_flies_kernel
    %         [k3_resp{ii,1}(jj),~] =  K3ToGlider_One_CorrType(third_kernel_behavior{dx_which}(:,jj),  corrParam,'tMax', tMax);
    %     end
    %     k3_resp{ii,1}(jj) = k3_resp{ii,1}(jj) * average_over_space_pairs;
    %     k3_resp{ii,2} = -k3_resp{ii,1};
    %     % first is always positive.
    % end
    
end



