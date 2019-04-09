function [K2_norm, K3_U_norm, R, dtxy_bank, dtxx_bank, tMax] = K2K3_SVD_Together_Main(k2_sym, k3_sym, R, mode, varargin)
% R = 1;
% mode = [];
dtxy_bank  = [-5:-1, 1:5];
tMax = 49;
dtxx_bank = [-4:-1,1:4];
kernel_extraction_method = 'reverse_correlation';
savefig_flag = false;
special_name = [];
tau_23 = [-5:5];
tau_13 = [-5:5];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% add names on it... which one?
special_name = mode;
%% SVD on third order kernel is not that simple...
[K3_U, ~] = My_SVD_K3_Flattened_Main(k3_sym, 'R', R, 'mode', mode, 'savefig_flag', savefig_flag, 'special_name', special_name,...
    'tMax',tMax,'tau_21',tau_23,'tau_31',tau_13);

[~, K2_U ,K2_V] = My_SVD_K2_Flattened(k2_sym(:),'dtxy_bank',  [dtxy_bank(dtxy_bank < 0), dtxy_bank(dtxy_bank > 0)],...
    'tMax',tMax );

if savefig_flag
    MySaveFig_Juyue(gcf, 'K2_flattened_SVD', kernel_extraction_method, 'nFigSave',2,'fileType',{'png','fig'});
end
%% MakeFigure;
% normalize those components.
K2_U_norm = K2_U(:,1)./norm(K2_U(:,1));
K2_V_norm = K2_V(:,1)./norm(K2_V(:,1));
K2_norm = {K2_U_norm, K2_V_norm};
K3_U_norm = K3_U;
for ii = 1:1:R
    for jj = 1:1:3
        
        K3_U_norm{jj}(:,ii) = K3_U{jj}(:,ii)./norm(K3_U{jj}(:,ii));
        if jj == 1 || jj == 3
            K3_U_norm{jj}(:,ii) = K3_U_norm{jj}(:,ii);
        end
    end
end
%%
% plot_component_together(K2_norm, K3_U_norm, R, dtxy_bank, dtxx_bank, tMax)
% if savefig_flag
%     main_name = sprintf('K23_Component_Together_R%d',R);
%     text_str = [main_name, ' ' special_name];
%     uicontrol('Style', 'text',...
%         'String', text_str,... %replace something with the text you want
%         'Units','normalized',...
%         'Position', [0 0.9 0.15 0.1],'FontSize', 15);
%     
%     MySaveFig_Juyue(gcf,main_name, special_name, 'nFigSave',2,'fileType',{'png','fig'});
% end
end
