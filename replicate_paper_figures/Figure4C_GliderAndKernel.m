function Figure4C_GliderAndKernel()
clc
clear
close all

mode = 'ai_publish';
switch mode
    case 'ai_publish'
        h_axes = repmat(struct('Units', 'inches', 'Position',[]), 4, 1);
        h_axes(1).Position = [1/2, 5, 5,  1+1/2];
        h_axes(2).Position = [6 + 1/2,   5 + 1/2, 1 + 1/2,  1 + 1/2];
        lineWidth= 1;
        h_axes(3).Position = [1/2,2, 2,      2];
        h_axes(4).Position = [3,  2, 4 + 1/4,2];
    case 'matlab_debug'
        h_axes = repmat(struct('Units', 'normalized', 'Position',[]), 4, 1);
        a = subplot(2,4,1:3);
        h_axes(1).Position = a.Position;
        a = subplot(2,4,4);
        h_axes(2).Position = a.Position;
        lineWidth= 1;
        a = subplot(2,4,1);h_axes(3).Position = a.Position;
        a = subplot(2,4,2:3);h_axes(4).Position = a.Position;
end
%% load the behavior kernel.
[glider_str_3o, glider_data, kernel_data] = High_Corr_PaperFig_GliderKernel_Utils_Compute();
batch_ind = {[1,6,10],[2,7,12],[4,3,5]};
MakeFigure_Paper;
High_Corr_PaperFig_Utils_GliderVSKernel_WithColor(glider_data, kernel_data, h_axes(1));
daspect([1,1,1])
% ConfAxis
% MySaveFig_Juyue(gcf, 'GliderAndKernel','colorful_unity_line','nFigSave',2,'fileType',{'eps','fig'});
end



