function [ meanVals ] = threeDvisualize_glidAxes( kernel,zThresh,theTitle,subplotInd,offplot)
% plots integral along diagonals specified by (t2-t1) and (t3-t1) (t2 > t1)

zScale = 1;
if nargin < 2
    zScale = 0;
end

if nargin < 3
    theTitle = '';
end

isSubplot = 1;
if nargin < 4
    isSubplot = 0;
end

if nargin < 5
    offplot = 0;
end

% Generate grid
maxTau = length(kernel);
maxDisp = 3;
gridAxis = [0:maxTau-1];
[ X1 X2 X3 ] = meshgrid(gridAxis, gridAxis, gridAxis);
X1 = X1(:); X2 = X2(:); X3 = X3(:);
meanVals = zeros(maxDisp+1,2*maxDisp+1);
% Get means
for disp2 = 0:maxDisp
    for disp3 = -maxDisp:maxDisp
        getLocs = ( X2 - X1 == disp2 ) .* ( X3 - X1 == disp3 );
        if sum(getLocs)>0
            xPos = disp2 + 1;
            yPos = disp3 + maxDisp+1;
%             meanVals(xPos,yPos) = getLocs'*kernel(:) / sum(getLocs);
            meanVals(xPos,yPos) = getLocs'*kernel(:); % REMOVED 08/06/2015 -- REMAKE FIGURE
                                                      % scaling factor of 2?                                                    
        end
%         seeLocs = reshape(getLocs,[maxTau maxTau maxTau]);
%         threeDvisualize_corner(seeLocs,0);
%         keyboard
    end
end

% See
if ~offplot
    if isSubplot
        subplot(subplotInd(1),subplotInd(2),subplotInd(3));
    else
        figure
    end
    imagesc(meanVals); colormap_gen; colormap(mymap);
    axis xy; maxVal = max([ abs(min(meanVals(:))) abs(max(meanVals(:))) ]);
    set(gca,'Clim',[-maxVal maxVal]);

    set(gca,'XTick',[1:1:2*maxDisp+1])
    set(gca,'XTickLabel',[-maxDisp:1:maxDisp])
    xlabel('T3-T1');

    set(gca,'YTick',[1:1:maxDisp+1])
    set(gca,'YTickLabel',[0:1:maxDisp])
    ylabel('T2-T1');
    title(theTitle);
end

end