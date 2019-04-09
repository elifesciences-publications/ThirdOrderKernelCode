function  data_for_plot = K3_Visualization_Format_1213(third_kernel, varargin)
dx_bank  =  {[0,1],[0,-1],[1,2],[-1,-2]};
dx_bank_plot = {[0,-2],[0,-1],[0,1],[0,2]};
dt_vary_max = 10;
barUse = 1:size(third_kernel{1},2);
n_bars_averaged_over = 2;
mode = [];
plot_flag = true;
nMultiBars = 20;
maxTau = 32;
tMax = 32;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
dtMax = dt_vary_max;

%% First, calculate the corrValue for each dxbank
dtBank_ThirdOrder = [{(0:dtMax)'},{(0:dtMax)'}];
corrParam_third = K2K3ToGlider_Utils_FromDtBankToCorrParam(dtBank_ThirdOrder,3);
% you will deal with
ndx_bank  = length(dx_bank );
corrValue_3o = cell(ndx_bank ,1);
individualCorrTrace_3o = cell(ndx_bank ,1);

for cc = 1:1:ndx_bank
    corrValue_3o{cc} = zeros(length(corrParam_third),nMultiBars);
    individualCorrTrace_3o{cc} = zeros(tMax,length(corrParam_third),nMultiBars);
    
    for qq = 1:1:nMultiBars
        [corrValue_3o{cc}(:,qq),individualCorrTrace_3o{cc}(:,:,qq)] = K3ToGlider_One_CorrType(third_kernel{cc}(:,qq),corrParam_third,'tMax', tMax);
    end
end

%% Second, visualize it.
% switch mode.
switch mode
    case 'x_varied'
        MakeFigure;
        for ii = 1:1:3
            subplot(3,3,ii)
            dt_fixed_bank = 1:3; dt_vary = (0:dt_vary_max )';
            K3_Visualizatoin_Utils_One_Plot_X_Varies(corrValue_3o, dx_bank,corrParam_third, 'which_tau_fixed', [1,2],...
                'x_bank', barUse, 'dt_fixed', dt_fixed_bank(ii),'dt_vary', dt_vary);
        end
        
        for ii = 1:1:3
            subplot(3,3,ii + 3)
            dt_fixed_bank = 0:2; dt_vary = (1:dt_vary_max )';
            K3_Visualizatoin_Utils_One_Plot_X_Varies(corrValue_3o, dx_bank,corrParam_third, 'which_tau_fixed', [1,3],...
                'x_bank', barUse, 'dt_fixed', dt_fixed_bank(ii),'dt_vary', dt_vary);
        end
        for ii = 1:1:3
            subplot(3,3,ii + 6)
            dt_fixed_bank = 0:2; dt_vary = (1:dt_vary_max )';
            K3_Visualizatoin_Utils_One_Plot_X_Varies(corrValue_3o, dx_bank,corrParam_third, 'which_tau_fixed', [2,3],...
                'x_bank', barUse, 'dt_fixed', dt_fixed_bank(ii),'dt_vary', dt_vary);
        end
    case 'x_fixed'
        dt_vary = (1:dt_vary_max )';
        data_x_fixed = cell(length(barUse),1);
        for ii = 1:1:length(barUse)
            x_fixed_use = barUse(ii);
            data_x_fixed{ii} = K3_Visualizatoin_Utils_One_Plot_X_Fixed_Calculate(corrValue_3o, dx_bank, corrParam_third,...
                'x_fixed', x_fixed_use,'dx_bank_plot', dx_bank_plot,'dt_vary', dt_vary);
        end
        if plot_flag
            MakeFigure;
            subplot(1,length(barUse),ii)
            K3_Visualizatoin_Utils_One_Plot_X_Fixed_Plot(data_x_fixed{ii}, x_fixed, dx_bank_plot, dt_vary);
        end
        data_for_plot = data_x_fixed;
        % make the function smaller. the smaller the better, so that you can use it.
    case 'x_fixed_average_over_bars'
       
        dt_vary = (1:dt_vary_max)';
        data_x_fixed = cell(length(barUse),1);
        for ii = 1:1:length(barUse)
            x_fixed_use = barUse(ii);
            data_x_fixed{ii} = K3_Visualizatoin_Utils_One_Plot_X_Fixed_Calculate(corrValue_3o, dx_bank, corrParam_third, ...
                'x_fixed', x_fixed_use,'dx_bank_plot', dx_bank_plot,'dt_vary', dt_vary);
        end
        barUse_after_average = length(data_x_fixed) - n_bars_averaged_over + 1;
        data_x_fixed_averaged_over_bars = cell(barUse_after_average,1);
        for ii = 1:1:barUse_after_average
            data_x_fixed_averaged_over_bars{ii} = zeros(size(data_x_fixed{1}));
            for jj = 1:1:n_bars_averaged_over
                data_x_fixed_averaged_over_bars{ii} = data_x_fixed_averaged_over_bars{ii} + data_x_fixed{ii + jj - 1};
            end
            data_x_fixed_averaged_over_bars{ii} = data_x_fixed_averaged_over_bars{ii}/n_bars_averaged_over;
        end
        data_for_plot =  data_x_fixed_averaged_over_bars;
end

end
function K3_Visualizatoin_Utils_One_Plot_X_Varies(corrValue_3o, dx_bank, corrParam_third, varargin)
which_tau_fixed = [1,2]; % which dt is fixed. it could be tau2 - tau1, or tau3 - tau1 or tau3 - tau2. This would be a pair

dt_fixed = 0; % it is probabily only the first would be used...
dt_vary = (0:5)'; % should start from 0; oh sure.
x_bank = 1:3;
dx_bank_plot = {[0,1];[0,-1]};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% this function can be replaced..

% data_for_plotting = cell(length(dx_bank_plot),1);

data_for_plotting = K3_Visualizatoin_One_Plot_Utils(corrValue_3o, dx_bank, corrParam_third, ...
    'x_bank', x_bank, 'dt_fixed', dt_fixed, 'dt_vary', dt_vary, 'dx_bank_plot', dx_bank_plot, 'which_tau_fixed',  which_tau_fixed);

%% the top one should be flipped and joined together with the bottom one. top and bottom one are left and right mirror of each other.
data_for_plotting{1} = flipud(data_for_plotting{1});
data_for_plotting_mat = cell2mat(data_for_plotting);
% also create labels....

quickViewOneKernel(data_for_plotting_mat, 1,'labelFlag', false)
% xlabel('x position');
% not always
if isequal(which_tau_fixed, [1,2])
    ylabel('\tau3 - \tau1')
    title(['\tau2 - \tau1 = ', num2str(dt_fixed)]);
elseif   isequal(which_tau_fixed,[1,3])
    ylabel('\tau2 - \tau1')
    title(['\tau3 - \tau1 = ', num2str(dt_fixed)]);
elseif  isequal(which_tau_fixed, [2,3])
    ylabel('\tau2 - \tau1')
    title(['\tau3 - \tau2 = ', num2str(dt_fixed)]);
end


set(gca, 'XTick', 1:length(x_bank), 'XTickLabel', strsplit(num2str(x_bank)));
YTickLabel = cat(2,strsplit(num2str(flipud(dt_vary)')), strsplit(num2str(dt_vary')));
set(gca, 'YTick', 1:length(dt_vary) * 2, 'YTickLabel',YTickLabel)
% set dx
text_posistion_x = -1.5; text_position_y = ceil(size(data_for_plotting_mat,1)/4); text_str = ['dx = ', num2str(dx_bank_plot{1}(2))];
text(text_posistion_x, text_position_y, text_str);

text_position_y = 3 * ceil(size(data_for_plotting_mat,1)/4); text_str = ['dx = ', num2str(dx_bank_plot{2}(2))];
text(text_posistion_x, text_position_y, text_str);
ConfAxis
end