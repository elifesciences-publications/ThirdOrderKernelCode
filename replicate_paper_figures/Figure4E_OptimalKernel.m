function Figure4E_OptimalKernel()
%%
clear
clc

%% for optimal kernel?
corr_type_str_2o = {'Two Point DT 1','Two Point DT 2','Two Point DT 3','Two Point DT 4','Two Point DT 5'};
corr_type_str_3o = {'Diverging DT 1','Diverging DT 2','Diverging DT 3',...
    'Converging DT 1','Converging DT 2','Converging DT 3',...
    'Late Knight', 'Elbow','Early Knight'};
kernel_extraction_method_bank = {'reverse_correlation','four_quadrant','non_multiplicative','unrestricted','extra_input',}; % same as the unrestricted.
kernel_extraction_method_str = {'measured kernel', 'four quadrant','non multiplicative','unrestricted','extra input'};
kernel_glider_format = High_Corr_PaperFig_OptimalKernel_Utils_Compute(kernel_extraction_method_bank,corr_type_str_2o,corr_type_str_3o);

%%

h_plot = repmat(struct('Units','inches','Position',[]), 2, 1);
h_plot(1).Position = [1/2,4, 2,      2];
h_plot(2).Position = [3,  4, 4 + 1/4,2];

MakeFigure;
High_Corr_PaperFig_OptimalKernel_Utils_Plot(kernel_glider_format,kernel_extraction_method_str,corr_type_str_2o,corr_type_str_3o, h_plot);

end