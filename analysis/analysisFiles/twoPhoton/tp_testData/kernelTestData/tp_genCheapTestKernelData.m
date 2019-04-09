function [ alignedStimulusData, responseData, settings ] = tp_genCheapTestKernelData( varargin )
% Creates test data that emulates the output of alignStimulusAndResponse
% for kernel extraction. 

    %% Generate Test Movie for Two Photon Analysis
    nMultiBars = 4;
    nSamples = 1e5;
    inVar = 1;
    dist = 1;
    maxTau = 10;
    nRoi = 1;
    nonlinearity = 1;  
    noiseVar = 0;
    optionSet = 2;

    switch optionSet
        case 1
            which = [ 1 0 0 ];
            multiBarsUse = 1;
            nonlinearity = 2;
        case 2
            which = [ 1 0 0 ];
            multiBarsUse = 1;
            nonlinearity = 1;
        case 3
            which = [ 0 1 0 ];
%             multiBarsUse = [1:nMultiBars];
            multiBarsUse = 1;
        case 4 
            which = [ 1 1 0 ];
            multiBarsUse = 1:nMultiBars;
    end
    
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Generate flicker input
    
    for q = 1:nMultiBars
        alignedStimulusData{q} = ...
            repmat( randInput(inVar,dist,nSamples)', [ 1 nRoi ] );
    end

    %% Create stimulus with first and second-order dependence on flicker input
   
    filters{1} = exampleFilters(which,maxTau);
    filters{2} = exampleFilters(which,maxTau);
    lpFun = @(x,tau) x.* exp(-x/tau) / tau^2;
    filtAxis = [1:1:maxTau];
    slow = lpFun(filtAxis,5);
    fast = lpFun(filtAxis,3);
    filters{1}{1} = slow;
    filters{2}{1} = fast;
    
    offDiag = ones(maxTau) - eye(maxTau);
%     offDiag = zeros(maxTau);
%     offDiag(1:end-1,2:end) = eye(maxTau-1);
%     offDiag(2:end,1:end-1) = offDiag(2:end,1:end-1) - eye(maxTau-1);
    filters{1}{2} = offDiag;
    filters{2}{2} = offDiag;

    for q = multiBarsUse
        firstInd = q;
        secondInd = mod(q,nMultiBars)+1;
        responseData(:,q) = flyResp( which,filters{1},maxTau,...
            alignedStimulusData{firstInd}(:,1),alignedStimulusData{secondInd}(:,1),noiseVar) + ... 
            flyResp( which,filters{2},maxTau,...
            alignedStimulusData{secondInd}(:,1),alignedStimulusData{secondInd}(:,1),noiseVar);
    end
    
    %% Static nonlinearity on responseData
    
    switch nonlinearity
        case 1
            nlUsed = inline('x','x');
%             responseData = responseData;
        case 2
            nlUsed = inline('x.^2','x');
%             responseData = (10*responseData) .^ 2;
        case 3
            nlUsed = inline('cos(1.5*x)','x');
%             responseData = cos(1.5*responseData);
        case 4
            nlUsed = inline('x + .3*x.^2','x');
        case 5
            nlUsed = inline('x.^2','x');
    end
    responseData = nlUsed(responseData);  
    settings.nonlinearity = nlUsed;
    settings.which = which;
    settings.filters = filters;
    Z.params.multiBarsUse = multiBarsUse;    
    
end

