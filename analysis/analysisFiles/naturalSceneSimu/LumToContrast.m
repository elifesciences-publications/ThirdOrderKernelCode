% data processing....
function xContr = LumToContrast(xLum,mode)
% xLum should be one image.
% there are several way to calculate the contrast map
% mode :
% 3 : local one, calculate it locally.
% 2 : per row, maximize the information get by fly
% 1 : global
switch mode 
    case 1
        xContr = xLum/mean(mean(xLum)) - 1;
    case 2
        rowMean = mean(xLum,2);
        rowMean = repmat(rowMean,[1,size(xLum,2)]);
        xContr = (xLum - rowMean)./rowMean;
    case 3
        
end
end