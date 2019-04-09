function axesNew = MoveFigureToSubplot(figToCopyHandle, subplotToCopyIntoHandle)

axesToCopy = figToCopyHandle.Children;
figToCopyIntoHandle = subplotToCopyIntoHandle.Parent;
figToCopyIntoHandle.Resize = 'off'; % Temporary to allow us to do manipulations without worrying that sizes will come out wrong

% We want width/height measurements in pixels
subplotToCopyIntoHandle.Units = 'pixels';

% Grab width/height of final plot (in pixels)
subplotPos = subplotToCopyIntoHandle.Position;
subplotWidth = subplotPos(3);
subplotHeight = subplotPos(4);

% Delete the subplot because axes are about ot be moved in
delete(subplotToCopyIntoHandle);

for axCpInd = 1:length(axesToCopy)
    % Make sure we're getting normalized axes
    origUnitsAxCp{axCpInd} = axesToCopy(axCpInd).Units;
    axesToCopy(axCpInd).Units = 'normalized';
    
    % Grab the axis position in normalized units
    axPos(axCpInd, :) = axesToCopy(axCpInd).Position;
end

% Using copyobj because it deals with legends in a preferential way
axesNew = copyobj(axesToCopy, figToCopyIntoHandle);

for axCpInd = 1:length(axesToCopy)
    
    newPixelXShift = axPos(axCpInd, 1).*subplotWidth + subplotPos(1);
    newPixelYShift = axPos(axCpInd, 2).*subplotHeight + subplotPos(2);
    newPixelWidth = axPos(axCpInd, 3).*subplotWidth;
    newPixelHeight = axPos(axCpInd, 4).*subplotHeight;
    
%     axesToCopy(axCpInd).Parent = figToCopyIntoHandle;
    axesNew(axCpInd).Units = 'pixels';
    axesNew(axCpInd).Position = [newPixelXShift newPixelYShift newPixelWidth newPixelHeight];
    
    % Reset units on axis
    axesNew(axCpInd).Units = origUnitsAxCp{axCpInd};
    axesNew(axCpInd).Color = axesToCopy(axCpInd).Color;
    axesNew(axCpInd).XLim = axesToCopy(axCpInd).XLim;
    axesNew(axCpInd).YLim = axesToCopy(axCpInd).YLim;
    axesNew(axCpInd).ZLim = axesToCopy(axCpInd).ZLim;
end



figToCopyIntoHandle.Resize = 'on'; % Reset to original state
delete(figToCopyHandle); % No longer care about this figure
