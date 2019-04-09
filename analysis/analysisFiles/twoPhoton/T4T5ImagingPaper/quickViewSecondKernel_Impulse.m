function quickViewSecondKernel_Impulse(K2,varargin)
mode  = 1; % default, plot the final state. other wise, plot the

xLabelStr = 'temporal interval [s]';
yLabelStr = 'time in the past [s]';
timeUnit = 1/60; % 60Hz,16.6 ms.

labelFlag = true;

colorbarFlag = true;
limPreSetFlag = false;

maxValue = 0;

smoothFlag = false;
smoothDim = 1; %
chopFlag = false;
boxFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% cut the second order kernel to be 1 second.

maxTauSquared = length(K2);
maxTau = round(sqrt(maxTauSquared));
K2 = reshape(K2,[maxTau,maxTau]);
maxTau = 60 + 1;  % 1 second!
K2 = K2(1:maxTau,1:maxTau);
if smoothFlag
    K2 = reshape(MySmooth_2DKernel_tilted(K2(:)),[maxTau,maxTau]);
end

% beautiful shift.
K2_1 = [zeros(maxTau,maxTau-1),K2];
for ii=1:maxTau
    K2_1(ii,:) = circshift(K2_1(ii,:),[0,-(ii-1)]);
end



K2_2 = K2_1;
for ii=1:maxTau-1
    K2_2(:,ii) = circshift(K2_2(:,ii),[-(maxTau-ii),0]);
end

% you have to smooth the thing in the same way...and then shift them...

K2_1_Plot = K2_1;
K2_2_Plot = K2_2;

% plot the half second and half second.

if chopFlag
    % half a second
    K2_1_Plot = K2_1_Plot(1:31,31:91); % square...
    K2_2_Plot = K2_2_Plot(1:31,31:91);
    yTick = [1,16,31];
    xTick = [1 16 31 46 61];
    yTickLabelStr = strsplit(num2str((yTick -1) * timeUnit,2));
    xTickLabelStr = strsplit(num2str([-30 -15 0 -15 30] * timeUnit,2));
    N = 31;
    
else
    yTick = [1,31,61];
    xTick = [1 31 61 91, 121];
    yTickLabelStr = strsplit(num2str((yTick -1) * timeUnit,2));
    xTickLabelStr = strsplit(num2str([-60 -30 0 30 60] * timeUnit,2));
    N = maxTau;
end

colormap_gen;


% for the sake of visualization, smooth the result a little bit.
% you could choose
switch mode
    case 1
        imagesc( K2_1_Plot);
        if limPreSetFlag
            cmax = maxValue;
        else
            cmax = max(K2_1_Plot(:));
        end
    case 2
        imagesc(K2_2_Plot);
        if limPreSetFlag
            cmax = maxValue;
        else
            cmax = max(K2_2_Plot(:));
        end
        % you have to draw a box.
        if boxFlag
            hold on
            plot([31,31],[0,31],'k-');
            plot([91,91],[0,31],'k-');
            plot([31,91],[31,31],'k-');
        end
end
colormap(mymap);
set(gca,'clim',cmax*[-1 1],'dataa',[1 1 1]);
hold on
plot([N N],[1 N],'k--');
axis image;
set(gca,'ydir','reverse','xtick',xTick ,'xticklabel',xTickLabelStr,'ytick',yTick,'yticklabel',yTickLabelStr);
if labelFlag
    xlabel(xLabelStr);
    ylabel(yLabelStr);
end
if colorbarFlag
    colorbar
end
end