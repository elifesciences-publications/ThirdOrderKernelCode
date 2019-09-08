function Z = masterFly_xt( inImg,inLocsX,inLocsT,filtIn,filtOrder,filtUnit,varargin )
% predicting the response of a realistic array of Reichardt correlators to 
% arbitrary input stimuli. 


    %% default flyish parameters

    debug = 0;

    % ommatidia parameters
    degView = 270; 
    degPerOm = 5;
    ommPerDeg = 1/degPerOm;
    samplesPerDeg = 10;
    phase = 0;
    samplesPerS = 100;

    % spatial filter parameters
    whichAccFun = 1; % 1 = Gaussian
%     sig = 5.7 / 2.3548; % make sure this is reasonable compared to ommPerDeg
    sig = .1;


    %% Vararararar

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    %% Define boundaries of image indices to (a) exclude values less than the
    % lowest number in your input vectors, since indexing there may not start
    % at 0, and (b) cut from the top any overhang that can't be given to a
    % whole sample. 
    minX_fromimg = min(inLocsX(:));
    minT_fromimg = min(inLocsT(:));
    maxX_fromimg = max(inLocsX(:));
    maxT_fromimg = max(inLocsT(:));
    diffX_fromimg = maxX_fromimg - minX_fromimg;
    diffT_fromimg = maxT_fromimg - minT_fromimg;
    maxX_fromimg = maxX_fromimg - mod(diffX_fromimg,1/samplesPerDeg);
    maxT_fromimg = maxT_fromimg - mod(diffT_fromimg,1/samplesPerS);

    % The size of your stretched xt plot in image coordinates is given by the
    % difference between the highest and lowest spatial pixels visible
    stretchLen_X = floor(diffX_fromimg*samplesPerDeg);
    stretchLen_T = floor(diffT_fromimg*samplesPerS); 

    if diffX_fromimg < degView
        numX = floor(diffX_fromimg/degPerOm); 
    else
        numX = floor(degView/degPerOm);
    end

    %% Debug

    if debug
        keyboard
    end

    %% Interpolate your image to the right sampling rate in x and t

    tic

    % This assumes InLocsX in degrees, inLocsT in ms.
    Xq_vect = linspace(minX_fromimg,maxX_fromimg,stretchLen_X);
    Tq_vect = linspace(minT_fromimg,maxT_fromimg,stretchLen_T);

    [Xq Tq] = meshgrid(Xq_vect,Tq_vect);

    stretchImg = interp2(inLocsX,inLocsT,inImg,Xq,Tq,'linear');

    fprintf('Interpolated the xt plot: '); toc; 

    %% Interpolate your kernel to match your ommatidia array

    tic

    % filtUnit gives the conversion factor between pixels in kernel and ms
    maxTau = length(filtIn);
    filtind_vect = linspace(0,maxTau*filtUnit,maxTau);
    filtq_vect = [0:1/samplesPerS:maxTau*filtUnit];
    newMaxTau = length(filtq_vect);
    interpRenorm = (length(filtq_vect)/length(filtind_vect)).^filtOrder;

    switch filtOrder
        case 1
            interpKernel = interp1(filtind_vect,filtIn,filtq_vect);
        case 2
            [X Y] = meshgrid(filtind_vect,filtind_vect);
            [Xq Yq] = meshgrid(filtq_vect,filtq_vect);
            interpKernel = interp2(X,Y,filtIn,Xq,Yq);  
        case 3
            [X Y Z] = meshgrid(filtind_vect,filtind_vect,filtind_vect);
            [Xq Yq Zq] = meshgrid(filtq_vect,filtq_vect,filtq_vect);
            interpKernel = interp3(X,Y,Z,filtIn,Xq,Yq,Zq);    
    end
    interpKernel = interpKernel / sqrt(interpRenorm);

    fprintf('Interpolated the filter: '); toc;  

    %% Generate acceptance functions

    omInd = linspace(-degPerOm/2,degPerOm/2,degPerOm*samplesPerDeg) - phase;

    switch whichAccFun
        case 1 % Gaussian         
            gaussFun = @(x,sig) exp(-(x.^2/(2*sig^2))); % Not normalized
            eachOm = gaussFun(omInd,sig)/sum(gaussFun(omInd,sig));
        case 2 % delta
            assert(mod(degPerOm*ommPerDeg,2)==1); % Could be improved to allow for even
            deltaFun = @(x,xi) (x == xi);
            eachOm = deltaFun(omInd,0);
    end     
    % figure; plot(eachOm);

    timeFiltImg = stretchImg;

    %% Time trace for each ommatidium

    tic

    % determine where each ommatidium starts in terms of column number in the
    % stretched image.
    for q = 1:numX
        omLeft(q) = (q-1)*degPerOm*samplesPerDeg+1;
        % Starting at zero so that when r = 1, in first slot
    end

    % combine columns according to weights in eachOm
    om = zeros(stretchLen_T,numX);
    for q = 1:numX
        for r = 1:length(eachOm)
            om(:,q) = om(:,q) + timeFiltImg(:,omLeft(q)+r-1)*eachOm(r);
        end
    end
    fprintf('Filtered in space: '); toc;

    %% use filter

    tic

    filtered = zeros(stretchLen_T-newMaxTau+1,numX-1);
    switch filtOrder
        case 1    
            filtered = filter(interpKernel,1,om,[],1);   
            filtered = filtered(newMaxTau:end,:);
        case 2      
            for q = 1:numX-1
                filtered(:,q) = specialtwodfilt(interpKernel,om(:,q),om(:,q+1)); 
            end
        case 3
            for q = 1:numX-1
                filtered(:,q) = specialthreedfilt(newMaxTau,om(:,q),om(:,q),om(:,q+1),interpKernel(:));
            end       
    end
    filtered = filtered / (stretchLen_T/size(inImg,1));
    
    fprintf('Applied kernels: '); toc;

    %% plot response out
    om_mean = mean(filtered,2);
    Z.resp = om_mean;
    Z.respMean = mean(om_mean(1:end-1));
    Z.blurFilt = eachOm;
    Z.tempFilt = interpKernel;
    Z.om_mean = om_mean;

end