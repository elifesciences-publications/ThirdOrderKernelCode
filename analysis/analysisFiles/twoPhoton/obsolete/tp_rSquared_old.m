function Z = tp_rSquared( Z )
% Evaluate the predictive power of LN and/or kernel series model for
% flicker data

    modelType = 'LN';
    nMultiBars = 4;
    multiBarsUse = [1:4];
    kernelPaths = [];
    
    loadFlexibleInputs(Z);
    
    %% Load everything from flickerSelectAndAlign
    flickNames = fieldnames(Z.flick);
    for ii = 1:length(flickNames)
        eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
    end
    
    %% Get Data
    nRoi = size(responseData,2);
    nT = length(kernelInds);     
    
    %% Apply model
    switch modelType
        case 'LN'    
            lnNames = fieldnames(Z.LN);
            for ii = 1:length(lnNames)
                eval([lnNames{ii} '= Z.LN.' lnNames{ii} ';']);
            end             
            for r = 1:nRoi
                expected(:,r) = nonlinearity(linearExpected(:,r),r,nl);
%                   expected = linearExpected;
            end
         
        case 'kernels'
            % a little awkwardness here -- you need to manually load the
            % appropriate first and second order kernels   
            
            %% Select kernels
            if size(kernelPaths,1)==0
                HPathIn = fopen('dataPath.csv');
                C = textscan(HPathIn,'%s');
                kernel_folder = C{1}{3};        
                kernelPaths{1} = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the file containing the linear kernel.');
                kernelPaths{2} = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the file containing the 2o kernel.');     
            end
            
            %% Load kernels
            for q = 1:2
                load(kernelPaths{q}{1});
                inKernels{q} = saveKernels.kernels;
            end
            
            %% Reorganize for compatibility with flyResp
            maxTau = size(inKernels{1},1);
            for q = multiBarsUse
                for r = 1:nRoi
                    useKernels{q,r}{1} = inKernels{1}(:,q,r);
                    useKernels{q,r}{2} = reshape( inKernels{2}(:,q,r), [ maxTau maxTau ] );
                end   
            end
            
            %% Create predicted response
            expected = zeros(nT,nRoi);
            for q = multiBarsUse
                firstInd = q;
                secondInd = mod(q,nMultiBars) + 1;               
                for r = 1:nRoi
                    x = alignedStimulusData{firstInd}(kernelInds,r);
                    y = alignedStimulusData{secondInd}(kernelInds,r);
                    expected(:,r) = expected(:,r) + ...
                        flyResp( [ 1 1 0 ],useKernels{q,r},maxTau,x,y );
                end
            end            
    end
    
    %% Calculate angle
    for r = 1:nRoi        
        expt_ms(:,r) = expected(:,r) - repmat( mean( expected(:,r),1 ), [ nT 1 ]);
        resp_ms(:,r) = responseData(kernelInds,r) - repmat( mean( responseData(kernelInds,r),1 ), [ nT 1 ]);
        rSquared.R(r) = expt_ms(:,r)'*resp_ms(:,r) / sqrt(expt_ms(:,r)'*expt_ms(:,r) * ...
            resp_ms(:,r)'*resp_ms(:,r));              
    end
    rSquared.Rsq = rSquared.R.^2;
    Z.rSquared = rSquared;
    
    %% Scatter plot of the two against each other - plausible?
    
%     for r = 1:nRoi
%     	figure;
%         thisTitle = sprintf('Expected versus measured - ROI %i',r);
%         scatter(expt_ms(:,r),resp_ms(:,r));
%         title(thisTitle);
%     end     

end

