function Z = tp_OLS( Z )
% First and second order OLS on Gaussian flicker data

    maxTau = 50;
    testData = 0;
    
    %% Load everything from Z.flick
    
    flickNames = fieldnames(Z.flick);
    for ii = 1:length(flickNames)
        eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
    end
    nMultiBars = size(alignedStimulusData,2);
    
    if testData
        [ alignedStimulusData responseData ] = tp_genCheapTestKernelData;
        kernelInds = 1:size(alignedStimulusData{1},1);
    end
    
    %% Loop through multibars and ROIs
    
    nRoi = size(responseData,2);
    
    for r = 1:nRoi
        for q = 1:nMultiBars
            
            %% Run godawful index-selecting scripts
            % Screw trying to use old script, just do it by hand, it's not
            % even that hard                 
            firstInd = q;
            secondInd = mod(q,4) + 1;
            respLen = length(kernelInds) - maxTau;
            polMat = zeros(respLen,maxTau+maxTau^2);           
            for s = 1:maxTau % START AT 0
                polMat(:,s) = alignedStimulusData{firstInd}(kernelInds(maxTau-(s-1):maxTau-s+respLen),r);
            end
            for a = 1:maxTau
                for b = 1:maxTau
                    polMat(:,a+b*maxTau) = alignedStimulusData{firstInd}(kernelInds(maxTau-(a-1):maxTau-a+respLen),r) .* ...
                        alignedStimulusData{secondInd}(kernelInds(maxTau-(b-1):maxTau-b+respLen),r);
                end
            end
                                    
            %% Invert
            allKernels(:,q,r) = polMat \ responseData(kernelInds(maxTau:maxTau+respLen-1),r);
            
            %% Cut into different kernels
            linear(:,q,r) = allKernels(1:maxTau,q,r);
            second(:,q,r) = allKernels(maxTau+1:end,q,r);
            
        end
    end
    
    Z.OLS.linear = linear;
    Z.OLS.second = second;

end