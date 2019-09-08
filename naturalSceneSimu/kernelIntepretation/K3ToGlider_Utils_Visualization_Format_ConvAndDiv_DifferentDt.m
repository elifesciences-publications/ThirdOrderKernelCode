function K3ToGlider_Utils_Visualization_Format_ConvAndDiv_AverageOverBar(firstKernel,secondKernel,thirdKernelCorrType,corrParam_Third,barUse)
plotDiv =  cellfun(@(corrType) corrType.dt(2) == 0 & corrType.dt(1) ~= 0 ,corrParam_Third); 
plotConv =  cellfun(@(corrType) corrType.dt(1) == corrType.dt(2) & corrType.dt(1) ~= 0 ,corrParam_Third); 

MakeFigure;
subplot(2,2,1);
quickViewOneKernel(flipud(firstKernel),1);
subplotNum = [2,4,5,6,7,8]; % 6 bars. % only one of them would show up.
% how about only plot part of it...
% data is there, but you have to present it nicely...
for qq = 1:1:length(barUse)
    subplot(4,2,subplotNum(qq));
    % value..% 
    DivPosThisBar = thirdKernelCorrType{1}(plotDiv,barUse(qq));
    ConvPosThisBar = thirdKernelCorrType{1}(plotConv,barUse(qq));
    DivNedThisBar = thirdKernelCorrType{2}(plotDiv,barUse(qq));
    ConvNegThisBar = thirdKernelCorrType{2}(plotConv,barUse(qq));
    
    % plot them.
    plot([DivPosThisBar,ConvPosThisBar,DivNedThisBar,ConvNegThisBar],'lineWidth',2);
    legend('Pos Div','Post Conv','Neg Div','Neg Conv'); % diverging work. conv does not work.
    title(sprintf('bar %d', barUse(qq)));
end

