function ReichFilter(filterType,calcType,alpha)
    % this file is used to calculate the power spectrum extracted by a
    % reichardt correlator to different moving sine waves

    % k = spatial frequency
    % w = temporal frequency
    % r = reichardt response to a stimulus
    % x = space
    % t = time
    % i = sqrt(-1)
    % <> = mean
    
    % s(x,t) = sin(ko*x + wo*t) stimulus in real space
    % S(w,k) = stimulus in fourier space
    % h{1}(x,t), h{2}(x,t) = real filter of arm 1 and arm 2
    % h{1}D(x,t), h{2}D(x,t) = real delayed filter of arm 1 and arm 2
    % H{1}(w,k),H{2}(w,k),H{3}(w,k),H{4}(w,k) = fourier transform of filter
    % int represents an integral
    
    % r = <conv(h{3},s)*conv(h{2},s) - conv(h{4},s)*conv(h{1},s)>
    % r = [conv(H{3}*S,H{2}*S)-conv(H{4}*S,H{1}*S)]*delta(w)*delta(k)
    
    % simplifies to
    % r = int[int[ |S|^2 ( H{3} * conj(H{4}) -  H{4} * conj(H{1}) ) dwdk ] ]

    % this equation demonstrates that you can think of the reichardt
    % correlator as filtering power from a scene, and then summing across
    % the extracted power. Furthermore, since you sum over all power, and
    % the stimulus is real, only the real parts of the combined filters
    % matter. Thefore you can think of the reichardt filter Hr as
    
    % Hr = Re[ H{3} * conj(H{4}) - H{4} * conj(H{1}) ]
    
    % such that r = int[int[ |S|^2 * Hr dwdk ] ]

    % the real is unnessary here, but is useful when simplifying the
    % equation when you plug in filters

    
    % filterType = 1;
    % calcType = 1;
    
    if nargin < 3
        alpha = 1;
    end
    
    numAlpha = length(alpha);
    
    %% fundamental frequency and space variables
    xSam = 1/6*180/pi; % sample rate in samples/radian for filter - determines the highest frequencies to measure
    tSam = 10; % sample rate in Hz for filter - determines the highest frequencies to measure
    xNum = 2^7+1; % number of measurments in x, factors of 2 make for faster FFT - determines the resolution in fourier space
    tNum = 2^8+1; % number of measurements in t, factors of 2 make for faster FFT - determines the resolution in fourier space
    
    totalX = (xNum-1)/xSam; % in radians
    totalT = (tNum-1)/tSam; % in seconds
    
    x = (0:xNum-1)/xSam-totalX/2; % in radians
    t = (0:tNum-1)'/tSam; % in seconds
    [xMat,tMat] = meshgrid(x,t);
    
    % angular frequencies of the fourier transforms
    SF = 2*pi*((0:xNum-1)/totalX - xSam/2);
    TF = 2*pi*((0:tNum-1)'/totalT - tSam/2);
    [sfMat,tfMat] = meshgrid(SF,TF);
    
    %% plotting version of fundamental variables
    xDeg = floor(x*180/pi*10)/10; % x in degrees
    tMsec = floor(t*1000*10)/10; % x in radians
    TFhz = floor(TF/(2*pi)*10)/10; % TF in Hz
    lambda = floor((2*pi./SF)*(180/pi)); % spatial wavelength
    velVals = TF*(1./SF)*180/pi; % velocity at each point of the k omega plot
    velVals(:,1:floor(end/2)) = flipud(velVals(:,1:floor(end/2))); % change from four quadrant to positive above k axis and negative below
    
    % minimum and maximum velocity
    minVel = min(velVals(~isinf(velVals))); % deg/s
    maxVel = max(velVals(~isinf(velVals))); % deg/s

    % velocities to project into (linear)
    VEL = linspace(minVel,maxVel,tNum)';
    
    velLimit = 200; % zoom in on velocity graph
%     [~,velStart] = min(abs(VEL+velLimit)); % index at which to start plotting
    [~,velStart] = min(abs(VEL)); % index at which to start plotting
    [~,velEnd] = min(abs(VEL-velLimit));
    
    [sfMatVel,velMat] = meshgrid(SF,VEL); % SF's and full Vel's in a meshgrid
    VEL = VEL(velStart:velEnd); % trim down Vels for plotting later
    
    %% useful ploting values
    plotNumT = 9; % number of plot ticks for t/TF
    plotNumX = 9; % number of plot ticks for x/SF
    plotVectT = round(linspace(1,tNum,plotNumT)); % values for each plot tick
    plotVectX = round(linspace(1,xNum,plotNumX)); % values for each plot tick
    plotVectVel = round(linspace(1,velEnd-velStart+1,plotNumT)); % values for each plot tick
    numToSkip = 1; % plot every other numToSkip
    cAxisMax = 0;
    
    plotSF = round(xNum+1)/2:xNum;
%     plotTF = (round(tNum+1)/2:tNum)';
    plotTF = (1:tNum)';
    
    %% antialiasing filters
    % typically xSam and tSam are fairly low frequencies because there
    % isn't much going on at high temporal and spatial frequencies. However
    % these filters can't simply be sampled at low rates as that could
    % cause aliasing. So first we will sample everything at a high sample
    % rate initSam, filter it with an antialiasing filter, and then down
    % sample it.
    
    initSamXthresh = 10*180/pi; % minimum sample rate in X, samples/radian
    initSamXfactor = ceil(initSamXthresh/xSam); % make the actual sample rate a multiple of xSam
    initSamX = initSamXfactor*xSam; % calculate initSamX with this factor
    
    initSamTthresh = 2000; % minimum sample rate in t, in Hz
    initSamTfactor = ceil(initSamTthresh/tSam); % make the actual sample rate a multiple of tSam
    initSamT = initSamTfactor*tSam; % calculate initSamT with this factor
    
    % we want the range of x and t to be the same in the high sampling
    % case
    initNumX = (totalX*initSamX+1); % number of samples initially
    initNumT = (totalT*initSamT+1);
    
    initX = (0:initNumX-1)/initSamX-totalX/2; % initial x values
    initT = (0:initNumT-1)'/initSamT; % initial t values
    
    
    %% standard values to use for filters
    xMean1 = 0; % mean left input location in radians
    xMean2 = 2*5*pi/180; % mean right input location in radians
%     sWidth = 5.7/(2*sqrt(2*log(2)))*pi/180; % filter std in radians convert from full width half max to STD of Gaussian
    sWidth = 5*pi/180; % filter std in radians convert from full width half max to STD of Gaussian

%     ndTau = 40*1/1000; % peak time in seconds for non delay filter
%     dTau = 55*1/1000; % peak time in seconds for delay filter

    ndTau = 10*1/1000; % peak time in seconds for non delay filter
    dTau = 60*1/1000; % peak time in seconds for delay filter


    % spatial filters - gaussian
    s1 = normpdf(initX,xMean1,sWidth);
    s2 = normpdf(initX,xMean2,sWidth);
    
    s1 = SincResample(s1,initSamX,xSam);
    s2 = SincResample(s2,initSamX,xSam);
    

    
    %% cell arrays for filters and reichardt filters
    h = cell(4,1);
    H = cell(4,1);
    RHtf = cell(numAlpha,1);
    RHvel = cell(numAlpha,1);
    
    %% define filters
    % typically these filters are seperable in space and time with a
    % gaussian spatial filter and differing temporal filters. tND and tD
    % are reasonable maximum values for the non delay and delay temporal
    % filters but they don't need to be used. Any real filter is allowed,
    % seperable filters are not required.
    
    % once the filters are defined with initT and initX they will be
    % convolved with the antialiasing filter and resampled.
    
    % the convolution is done in the case statement, so that if the
    % temporal filters are reused, the convolution need only be done once,
    % rather than 4 times for the 4 h's
    
    switch filterType
        case 1 % standard reichard, two low pass
            % temporal filter
            tND = initT.*exp(-initT/ndTau);
            tD = initT.*exp(-initT/dTau);
            
            tNDf = SincResample(tND,initSamT,tSam);
            tDf = SincResample(tD,initSamT,tSam);
            
            h{1} = tDf*s1;
            h{2} = tNDf*s2;

            h{3} = tNDf*s1;
            h{4} = tDf*s2;
            
        case 2 % delta function as ND and exponential as D
            % find closest value to mean and make 1 to approximate delta
            % function
            [~,mean1Loc] = min(abs(initX-xMean1));
            [~,mean2Loc] = min(abs(initX-xMean2));
            
%             s1 = zeros(size(initX));
%             s1(mean1Loc) = 1;
%             s2 = zeros(size(initX));
%             s2(mean2Loc) = 1;
%             
%             s1f = SincResample(s1,initSamX,xSam);
%             s2f = SincResample(s2,initSamX,xSam);
    
            tND = zeros(size(initT));
            tND(1) = 1;
            tD = initT.*exp(-initT/dTau);
            
            tNDf = SincResample(tND,initSamT,tSam);
            tDf = SincResample(tD,initSamT,tSam);
            
%             h{1} = tDf*s1f;
%             h{2} = tNDf*s2f;
%             
%             h{3} = tNDf*s1f;
%             h{4} = tDf*s2f;

            h{1} = tDf*s1;
            h{2} = tNDf*s2;
            
            h{3} = tNDf*s1;
            h{4} = tDf*s2;
            
        case 3 % derivative for ND arm
            % temporal filter
            tND = (1-initT/ndTau).*exp(-initT/ndTau).*HeavisideZero(initT);
            tD = initT.*exp(-initT/ndTau);
            
            tNDf = SincResample(tND,initSamT,tSam);
            tDf = SincResample(tD,initSamT,tSam);
            
            h{1} = tDf*s1;
            h{2} = tNDf*s2;

            h{3} = tNDf*s1;
            h{4} = tDf*s2;
            
        case 4 % derivative for ND and D arm
            % temporal filter
            tND = (1-initT/ndTau).*exp(-initT/ndTau).*HeavisideZero(initT);
            tD = (1-initT/dTau).*exp(-initT/dTau).*HeavisideZero(initT);
            
            tNDf = SincResample(tND,initSamT,tSam);
            tDf = SincResample(tD,initSamT,tSam);
            
            h{1} = tDf*s1;
            h{2} = tNDf*s2;

            h{3} = tNDf*s1;
            h{4} = tDf*s2;
            
        case 5 % Mi1 and Tm3
            q = load('C:\Documents\MATLAB\ALL_sep15');
            
            tND = q.Tm3_Kxsum;
            tD = q.Mi1_T_Kxsum;
            
            dataSam = 1000; % data sample rate in hz
            
            if mod(dataSam,tSam) ~= 0
                error('data sample rate needs to be an integer multiple of desired sample rate');
            end
            
            % resample data to get to the proper frequency
            tNDf = SincResample(tND,dataSam,tSam);
            tDf = SincResample(tD,dataSam,tSam);
            
            % if, after resampling the vector is too long, just take the
            % first tNum entries. If it's too short pad with zeros
            if length(tNDf)>tNum
                tNDf = tNDf(1:tNum);
                tDf = tDf(1:tNum);
            else
                tNDf = [tNDf; zeros(tNum-length(tNDf),1)];
                tDf = [tDf; zeros(tNum-length(tDf),1)];
            end
            
            h{1} = tDf*s1;
            h{2} = tNDf*s2;

            h{3} = tNDf*s1;
            h{4} = tDf*s2;
            
        case 6 % Tm1 and Tm2
            q = load('C:\Documents\MATLAB\ALL_sep15');
            
            tND = q.Tm1_Kxsum;
            tD = q.Tm2_Kxsum;
            
            dataSam = 1000; % data sample rate in hz
            
            if mod(dataSam,tSam) ~= 0
                error('data sample rate needs to be an integer multiple of desired sample rate');
            end
            
            % resample data to get to the proper frequency
            tNDf = SincResample(tND,dataSam,tSam);
            tDf = SincResample(tD,dataSam,tSam);
            
            % if, after resampling the vector is too long, just take the
            % first tNum entries. If it's too short pad with zeros
            if length(tNDf)>tNum
                tNDf = tNDf(1:tNum);
                tDf = tDf(1:tNum);
            else
                tNDf = [tNDf; zeros(tNum-length(tNDf),1)];
                tDf = [tDf; zeros(tNum-length(tDf),1)];
            end
            
            h{1} = tDf*s1;
            h{2} = tNDf*s2;

            h{3} = tNDf*s1;
            h{4} = tDf*s2;
        case 7
            s1 = normpdf(x,xMean1,sWidth);
            s2 = normpdf(x,xMean2,sWidth);
            
            tD = t.*exp(-t/ndTau);
            tND = [diff(tD) ;0];
            
            h{1} = tD*s1;
            h{2} = tND*s2;

            h{3} = tND*s1;
            h{4} = tD*s2;
        case 8
            s1 = normpdf(initX,xMean1,10^-10);
            s2 = normpdf(initX,xMean2,10^-10);

            s1 = s1./sum(s1);
            s2 = s2./sum(s2);
            
            s1 = SincResample(s1,initSamX,xSam);
            s2 = SincResample(s2,initSamX,xSam);
    
            % temporal filter
            tND = initT.*exp(-initT/ndTau);
            tD = initT.*exp(-initT/dTau);
            
            tNDf = SincResample(tND,initSamT,tSam);
            tDf = SincResample(tD,initSamT,tSam);
            
            h{1} = tDf*s1;
            h{2} = tNDf*s2;

            h{3} = tNDf*s1;
            h{4} = tDf*s2;
    end

    %% perform 2d Fourier transform
    H{1} = fft2(ifftshift(h{1},2));
    H{2} = fft2(ifftshift(h{2},2));

    H{3} = fft2(ifftshift(h{3},2));
    H{4} = fft2(ifftshift(h{4},2));

    % normalize to unit energy
    h{1} = h{1}/sqrt(sum(sum(abs(H{1}).^2)));
    h{2} = h{2}/sqrt(sum(sum(abs(H{2}).^2)));
    h{3} = h{3}/sqrt(sum(sum(abs(H{3}).^2)));
    h{4} = h{4}/sqrt(sum(sum(abs(H{4}).^2)));

    % normalize to unit energy
    H{1} = H{1}/sqrt(sum(sum(abs(H{1}).^2)));
    H{2} = H{2}/sqrt(sum(sum(abs(H{2}).^2)));
    H{3} = H{3}/sqrt(sum(sum(abs(H{3}).^2)));
    H{4} = H{4}/sqrt(sum(sum(abs(H{4}).^2)));
    
    %% calculate the Reichardt filter from filter inputs
    switch calcType
        case 1
            arm1 = real(H{1}.*conj(H{2}));
            arm2 = real(H{3}.*conj(H{4}));
        case 2
            arm1 = abs(H{1}).^2.*ifftshift(cos((dTau-ndTau)*tfMat + (xMean2-xMean1)*sfMat));
            arm2 = abs(H{1}).^2.*ifftshift(cos((dTau-ndTau)*tfMat - (xMean2-xMean1)*sfMat));
        case 3
            arm1 = imag(H{3});
            arm2 = real(H{3});

            RHtf = imag(H{3}).*ifftshift(sin((xMean2-xMean1)*sfMat));
        case 4
            arm1 = real(H{1}.*conj(H{2}));
            arm2 = real(H{3}.*conj(H{4}));
            
            arm1(arm1<0) = 0;
            arm2(arm2<0) = 0;
        case 5
            s1 = normpdf(x,0,sWidth*2);
            t1 = normpdf(t,dTau,dTau);
            arm1 = t1*s1;
            
            sinComp = sin(20*repmat(x,[length(t) 1]) + 160*repmat(t,[1 length(x)]));
            
            arm1 = abs(fft2(arm1.*sinComp)).^2;
            arm2 = abs(fft2(arm1.*fliplr(sinComp))).^2;
    end
    
    %% plot delay and non delay temporal filters
    [~,plotLoc1] = max(sum(h{1}.^2));
    [~,plotLoc2] = max(sum(h{2}.^2));
    
    numSteps = 5;
    timeToPlot = 1:numSteps;
    dTime = h{1}(timeToPlot,plotLoc1);
    ndTime = h{2}(timeToPlot,plotLoc2);
    
    maxPlotY = max(max([dTime ndTime]));
    minPlotY = min(min([dTime ndTime]));
    
    MakeFigure;
    subplot(2,2,1);
    plot(initT(1:numSteps*initSamTfactor),tD(1:numSteps*initSamTfactor));
    ylabel({'arbitrary units' 'before downsampling'});
    ConfAxis('fTitle','delay');
    subplot(2,2,2);
    plot(initT(1:numSteps*initSamTfactor),tND(1:numSteps*initSamTfactor));
    ConfAxis('fTitle','non delay');
    subplot(2,2,3);
    plot(t(timeToPlot),dTime);
    axis([t(1) t(timeToPlot(end)) minPlotY maxPlotY]);
    xlabel('time');
    ylabel({'normalized arbitrary units' 'after downsampling'});
    ConfAxis();
    subplot(2,2,4);
    plot(t(timeToPlot),ndTime);
    axis([t(1) t(timeToPlot(end)) minPlotY maxPlotY]);
    xlabel('time');
    ConfAxis();

    %% plot individual filters and fourier transforms
    MakeFigure;
    for ii = 1:4
        maxVal = max(max(abs(H{ii})));
        cAxisMax = max([cAxisMax maxVal]);
    end
    
    for ii = 1:4
        subplot(4,3,(ii-1)*3+1);
        imagesc(SF,TF,fftshift(abs(H{ii})));
        ConfAxis('tickX',SF(plotVectX(1:numToSkip:end)),'tickLabelX',lambda(plotVectX(1:numToSkip:end)),'tickY',TF(plotVectT(1:numToSkip:end)),'tickLabelY',TFhz(plotVectT(1:numToSkip:end)));
        caxis([-cAxisMax cAxisMax]);
        
        subplot(4,3,(ii-1)*3+2);
        imagesc(SF,TF,fftshift(real(H{ii})));
        ConfAxis('tickX',SF(plotVectX(1:numToSkip:end)),'tickLabelX',lambda(plotVectX(1:numToSkip:end)),'tickY',TF(plotVectT(1:numToSkip:end)),'tickLabelY',TFhz(plotVectT(1:numToSkip:end)));
        caxis([-cAxisMax cAxisMax]);
        
        subplot(4,3,(ii-1)*3+3);
        imagesc(SF,TF,fftshift(imag(H{ii})));
        ConfAxis('tickX',SF(plotVectX(1:numToSkip:end)),'tickLabelX',lambda(plotVectX(1:numToSkip:end)),'tickY',TF(plotVectT(1:numToSkip:end)),'tickLabelY',TFhz(plotVectT(1:numToSkip:end)));
        caxis([-cAxisMax cAxisMax]);
        colormap(flipud(cbrewer('div','RdBu',100)));
        
        if ii == 1
            subplot(4,3,(ii-1)*3+1);
            ConfAxis('fTitle','amplitude');

            subplot(4,3,(ii-1)*3+2);
            ConfAxis('fTitle','real part');

            subplot(4,3,(ii-1)*3+3);
            ConfAxis('fTitle','imaginary part');
        end
    end
    
    %% make reichardt filter k omega plot
    MakeFigure;
    w = ceil(sqrt(numAlpha)); % determines how many sub plots to draw. makes it as square as possible
    h = ceil(numAlpha/w);
    
    for aa = 1:numAlpha;
        % plot the SF,TF surface
        subplot(h,w,aa);
        RHtf{aa} = fftshift(arm1-alpha(aa)*arm2); % rfftshift here for maths later
        imagesc(SF,TF(plotTF),RHtf{aa}(plotTF,:)); % plot the surface
        colormap(flipud(cbrewer('div','RdBu',100)));
        hold on;
        
        [~,tfMax] = max(RHtf{aa}); % find where maximums occur
        [~,tfMin] = min(RHtf{aa}); % find where minimums occur
        scatter(SF,TF(tfMax),'k'); % scatter maximum locations on graph
        scatter(SF,TF(tfMin),'k','x'); % scatter minimum locations on graph
        contour(SF,TF(plotTF,:),RHtf{aa}(plotTF,:),'k');
        ConfAxis('tickX',SF(plotVectX),'tickLabelX',lambda(plotVectX),'tickY',TF(plotVectT),'tickLabelY',TFhz(plotVectT),'fTitle',['alpha = ' num2str(alpha(aa))]);
        maxResp = max(max(abs(RHtf{aa}(plotTF,:))));
        caxis([-maxResp maxResp]);
        set(gca,'ydir','normal')
%         colormap(mymap);
    end
    
%     keyboard;
%     colorbar;
%     subplot(h,w,8);
%     xlabel('lambda (deg)');
%     subplot(h,w,4);
%     ylabel('TF (Hz)');
%    
%     % make Reichardt filter k velocity plot
%     MakeFigure;
%     for aa = 1:numAlpha;
%         % remove infinities from velocity (0 spatial freq)
%         noInfVel = velVals;
%         noInfSF = sfMatVel;
%         noInfRH = RHtf{aa};
%         
%         infCol = find(isinf(velVals(1,:)));
%         
%         noInfVel(:,infCol) = [];
%         noInfSF(:,infCol) = [];
%         noInfRH(:,infCol) = [];
%         
%         % starting points are noInfVel and we want to stretch back to
%         % sfMat,velMat
%         RHvel{aa} = griddata(noInfSF,noInfVel,noInfRH,sfMatVel,velMat);
%         RHvel{aa} = RHvel{aa}(velStart:velEnd,:);
%         
%         % actually plot the map now that we have it
%         subplot(h,w,aa);
%         imagesc(SF,VEL,RHvel{aa}); % plot map
%         hold on;
%         [~,velMax] = max(RHvel{aa}); % calculate maximum locations
%         [~,velMin] = min(RHvel{aa}); % calculate minimum locations
%         scatter(SF,VEL(velMax),'k'); % scatter markers on max locs
%         scatter(SF,VEL(velMin),'k','x'); % scatter markers on min locs
%         contour(SF,VEL,RHvel{aa},'k'); % overlay contours
%         ConfAxis('tickX',SF(plotVectX),'tickLabelX',lambda(plotVectX),'tickY',VEL(plotVectVel),'tickLabelY',VEL(plotVectVel),'fTitle',['alpha = ' num2str(alpha(aa))]);
%         maxResp = max(max(abs(RHtf{aa})));
%         caxis([-maxResp maxResp]);
%         set(gca,'ydir','normal')
% %         colormap(mymap);
%     end
%     colorbar;
%     subplot(h,w,8);
%     xlabel('lambda (deg)');
%     subplot(h,w,4);
%     ylabel('velocity (deg/sec)');

%% plot the power spectrum of scintillator
phiRight = 1+cos((dTau-ndTau)*tfMat + (xMean2-xMean1)*sfMat);
rPhiRight = 1-cos((dTau-ndTau)*tfMat + (xMean2-xMean1)*sfMat);
phiLeft = 1+cos((dTau-ndTau)*tfMat - (xMean2-xMean1)*sfMat);
rPhiLeft = 1-cos((dTau-ndTau)*tfMat - (xMean2-xMean1)*sfMat);
phi0Dt = 1+cos((xMean2-xMean1)*sfMat);
rPhi0Dt = 1-cos((xMean2-xMean1)*sfMat);

% MakeFigure;
% imagesc(SF,TF,RHtf{1});
% maxVal = max(max(abs(RHtf{1})));
% caxis([-maxVal maxVal]);
MakeFigure;
subplot(3,2,1);
imagesc(SF,TF,phiRight);
caxis([-2 2]);
ConfAxis('fTitle','phi right');
subplot(3,2,2);
imagesc(SF,TF,rPhiRight);
caxis([-2 2]);
ConfAxis('fTitle','reverse phi right');
subplot(3,2,3);
imagesc(SF,TF,phiLeft);
caxis([-2 2]);
ConfAxis('fTitle','phi left');
subplot(3,2,4);
imagesc(SF,TF,rPhiLeft);
caxis([-2 2]);
ConfAxis('fTitle','reverse phi left');
subplot(3,2,5);
imagesc(SF,TF,phi0Dt);
caxis([-2 2]);
ConfAxis('fTitle','phi 0 dt');
subplot(3,2,6);
imagesc(SF,TF,rPhi0Dt);
caxis([-2 2]);
ConfAxis('fTitle','rPhi 0 dt');
colormap(flipud(cbrewer('div','RdBu',100)));

%% plot multiplication of scintillator power spectrum and reichardt filter
afterMultPhiRight = phiRight.*RHtf{1};
afterMultRPhiRight = rPhiRight.*RHtf{1};
afterMultPhiLeft = phiLeft.*RHtf{1};
afterMultRPhiLeft = rPhiLeft.*RHtf{1};
afterMultPhi0Dt = phi0Dt.*RHtf{1};
afterMultRPhi0Dt = rPhi0Dt.*RHtf{1};

maxVal = max(max(abs([afterMultPhiRight afterMultRPhiRight afterMultPhiLeft afterMultRPhiLeft afterMultPhi0Dt afterMultRPhi0Dt])));

MakeFigure;
subplot(3,2,1);
imagesc(SF,TF,afterMultPhiRight);
ConfAxis('fTitle','afterMultPhiRight');
caxis([-maxVal maxVal]);
subplot(3,2,2);
imagesc(SF,TF,afterMultRPhiRight);
ConfAxis('fTitle','afterMultRPhiRight');
caxis([-maxVal maxVal]);
subplot(3,2,3);
imagesc(SF,TF,afterMultPhiLeft);
ConfAxis('fTitle','afterMultPhiLeft');
caxis([-maxVal maxVal]);
subplot(3,2,4);
imagesc(SF,TF,afterMultRPhiLeft);
ConfAxis('fTitle','afterMultRPhiLeft');
caxis([-maxVal maxVal]);
subplot(3,2,5);
imagesc(SF,TF,afterMultPhi0Dt);
ConfAxis('fTitle','afterMultPhi0Dt');
caxis([-maxVal maxVal]);
subplot(3,2,6);
imagesc(SF,TF,afterMultRPhi0Dt);
ConfAxis('fTitle','afterMultRPhi0Dt');
caxis([-maxVal maxVal]);
colormap(flipud(cbrewer('div','RdBu',100)));


%% plot reichardt response to scintillator
phiRightSum = sum(sum(afterMultPhiRight));
rPhiRightSum = sum(sum(afterMultRPhiRight));
phiLeftSum = sum(sum(afterMultPhiLeft));
rPhiLeftSum = sum(sum(afterMultRPhiLeft));
phi0DtSum = sum(sum(afterMultPhi0Dt));
rPhi0DtSum = sum(sum(afterMultRPhi0Dt));
MakeFigure;
plot((1:3)',[phi0DtSum rPhi0DtSum; phiLeftSum rPhiLeftSum; phiRightSum rPhiRightSum]);
maxVal = max(abs([phi0DtSum rPhi0DtSum phiLeftSum rPhiLeftSum phiRightSum rPhiRightSum]));
hold on;
plot(1:3,repmat(sum(sum(RHtf{1})),[1 3]),'r');
legend({'phi' 'reverse phi' 'random noise'});
hold off;
ConfAxis('tickX',1:4,'tickLabelX',{'0 dt' 'left' 'right'});
ax = gca;
ax.YLim = [-maxVal maxVal];

end
