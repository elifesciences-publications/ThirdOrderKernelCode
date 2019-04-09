function Z = tp_modelPrediction( kernelsIn, nlIn, varargin )
 
    %% Parameters
    noiseVar = 0;
    T = 1e3;
    nOm = 72;
    nlType = 'identity';
    
    % model parameters - should match the experimental conditions
    multiBarsUse = [1:4];
    which = [ 1 1 0 ];
    barWd = 5;
    stimHz = 60;
    
    % stimulus default parameters - edit with varargin
    stimType = 'sine';
    stimOmega = 2*pi; % rad/s
    stimLambda = 30; % degrees
    
    %%    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Load stuff
    %% Get kernels
    if nargin < 1
        for r = 1:2
            kernelPath = uipickfiles('FilterSpec',dataFolder,'Prompt',...
                'Choose the .mat file containing the %io kernel');
            load(kernelPath{1});
            kernels{r} = saveKernels.kernels;
        end
        
    elseif ischar(kernelsIn{1})
        for r = 1:2
            load(kernelsIn{r});
            kernels{r} = saveKernels.kernels;
        end
        
    else
        kernels = kernelsIn;
        
    end
    nRoi = size(kernels{1},3);

    %% Get nonlinearity
    if strcmp(nlIn,'identity') || strcmp(nlIn,'rectify')
        % something - figure out how incorporating nl
        NL = [];
        
    elseif nargin < 3
        nlPath = uipickfiles('FilterSpec',dataFolder,'Prompt',...
            'Choose the .mat file containing the nonlinearity');
        load(nlPath);
        NL = saveNL;
        
    elseif isstr(nlIn)
        load(nlIn);
        NL = saveNL;
        
    end
    
    %% Generate stimulus
    %%      
    tVect = [1:T] * 1/stimHz; % s
    xVect = [1:nOm] * barWd; 
    [ inLocsT inLocsX ] = ndgrid( tVect, xVect );
                        
    switch stimType
        case 'sine'
            xt = sin(inLocsX * 2*pi/stimLambda - inLocsT * stimOmega);

        case 'square'
            xt = square(inLocsX * 2*pi/stimLambda - inLocsT * stimOmega);

        case 'flicker'           
            
    end
    %% Scale by sampling frequency
    for r = 1:2
        kernels{r} = kernels{r} * 60^r;
    end
    xt = xt / stimHz; 
    
    %% Run on model    
    filtUnit = 1 / stimHz;
    whichWhich = find(which);
    for r = 1:nRoi
        for sp = length(whichWhich)
            for t = multiBarsUse
                s = whichWhich(sp);
                inFilt = kernels{s}(:,t,r);
                maxTau = round(length(inFilt)^(1/s));
                reshapeVect = [ maxTau * ones(1,s) 1 ];
                inFilt = reshape(inFilt,reshapeVect);
                respStruct{r,sp,t} = masterFly_xt( xt,inLocsX,inLocsT,inFilt,s,filtUnit ); 
                resp(:,r,sp,t) = respStruct{r,sp,t}.resp;
            end
        end
    end
    
    %% Average multibars
    linResp = mean(resp,4);
    %% Apply nonlinearity
    resp = mean(linResp,3);
    switch nlIn
        case 'identity'
            resp = resp;
        case 'rectify'
            resp = resp .* (resp > 0);
            
    end
       
    respMean = mean(resp,1);
    
    model.linResp = linResp;
    model.resp = resp;
    model.respMean = respMean;
    model.kernels = kernels;
    model.NL = NL;
    Z.model = model;

end

