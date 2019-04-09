function axHndl = FilledSubplot(rows, cols, pos)

normRowHeight = 1/rows;
normColWidth = 1/cols;

selCol = mod(pos, cols);
if selCol == 0
    selCol = cols;
end
selRow = floor((pos-1)/cols)+1;

% Calculate normalized position to fill out the plot
xPos = (selCol-1).*normColWidth;
yPos = (rows - selRow).*normRowHeight;

axHndl = subplot(rows, cols, pos);
% Remember default units, then make it normalized and set the calculated
% position
axHndlOrigUnits = axHndl.Units;
axHndl.Units = 'normalized';
axHndl.Position = [xPos yPos normColWidth normRowHeight];

% Reset to default
axHnld.Units = axHndlOrigUnits;