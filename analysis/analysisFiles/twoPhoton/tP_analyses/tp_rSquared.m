function Z = tp_rSquared( Z )
% Evaluate the predictive power of LN and/or kernel series model for
% flicker data

    loadFlexibleInputs(Z);
    
    %% Load previous parts
    % The expectation is that you will have extracted kernels at some point
    % in the past, and then more recently run kernelPrediction ->
    % staticNonlinearity (even if the nonlinearity is set to be the
    % identity function).
    kernelExpected = Z.kPred.expected;
    nlData = Z.NL.nlData;
    nonlinearity = Z.NL.nonlinearity;
    responseData = Z.flick.responseData;
    kernelInds = Z.flick.kernelInds;
    
    %% Get Data
    nRoi = size(responseData,2);
    nT = length(kernelInds);     
    
    %% Apply nonlinearity  
    lnNames = fieldnames(Z.LN);
    for ii = 1:length(lnNames)
        eval([lnNames{ii} '= Z.LN.' lnNames{ii} ';']);
    end             
    for r = 1:nRoi
        expected(:,r) = nonlinearity(linearExpected(:,r),r,nl);
    end
         
       
    

end

