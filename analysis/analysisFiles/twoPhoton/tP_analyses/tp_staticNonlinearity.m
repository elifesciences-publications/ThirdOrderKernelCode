function Z = tp_staticNonlinearity( Z, nlIn )
% Takes the linear fit from tp_kernelPrediction and fits the optimal
% nonlinearity - either polynomial fit or interpolation

    %% Default Params
    nType = 'polyfit';
    nBins = 20;
    polyOrder = 3;
    saveNL = 0;
    
    loadFlexibleInputs(Z) 
    
    expected = Z.kPred.expected;
    responseData = Z.flick.responseData;  
    nRoi = size(expected,2);  
    kernelInds = Z.flick.kernelInds;
    
        
    %% Fit nonlinearity between filter expected and response
    if nargin < 2
        switch nType
            case 'polyfit'                       
                for r = 1:nRoi
                    nlData.polyCos(:,r) = polyfit(expected(:,r),responseData(kernelInds,r),polyOrder);
                    nlData.polyRange(:,r) = [ max(expected(:,r)); min(expected(:,r)) ];
                end
                nonlinearity = inline('polyval(nlData.polyCos(:,r),x)','x','r','nlData');   

            case 'disc'           
                for r = 1:nRoi              
                   nBounds = [ min(expected(:,r)) max(expected(:,r)) ];
                   nPoints = size(expected,1);
                   fitPoints = linspace(nBounds(1),nBounds(2),nBins+1);
                   lowerBounds = repmat( fitPoints(1:end-1)', [ 1 nPoints ] );
                   upperBounds = repmat( fitPoints(2:end)', [ 1 nPoints ] );
                   nlData.mids(:,r) = (fitPoints(1:end-1)+fitPoints(2:end))/2;
                   binLocs = repmat(expected(:,r)',[ nBins 1 ]);
                   binLocs = ( binLocs > lowerBounds ) .* ( binLocs < upperBounds );
                   respSd = std(responseData(kernelInds,r));              
                   for q = 1:nBins                  
                      histID{q,r} = find(binLocs(q,:));                 
                      respVals = responseData(kernelInds(histID{q,r}),r);
                      nlData.means(q,r) = mean(respVals(:));
                      nlData.sdFunct(q,r) =  respSd / sqrt(length(histID{q,r}));
                   end                
                   figure;
                   errorbar(nlData.mids(:,r),nlData.means(:,r),nlData.sdFunct(:,r));
                   ylabel('Response'); xlabel('Linear Prediction');                             
                end 
                nonlinearity = inline('interp1(nlData.mids(:,r),nlData.means(:,r),x,''nearest'',''extrap'')','x','r','nlData');

            case 'identity'
                nlData = [];
                nonlinearity = inline('x','x','r','nlData');

        end 
    else
        % This option exists so that this script can also just be an
        % "r-squared calculating script" for a pre-set nonlinearity
        nonlinearity = nlIn.nonlinearity;
        nlData = nlIn.nlData;
    end 
    
    %% Apply nonlinearity
    for r = 1:nRoi
        nlExpected(:,r) = nonlinearity(expected(:,r),r,nlData);
    end
    
    %% Calculate angle
    nT = size(nlExpected,1);
    for r = 1:nRoi        
        expt_ms(:,r) = nlExpected(:,r) - repmat( mean( nlExpected(:,r),1 ), [ nT 1 ]);
        resp_ms(:,r) = responseData(kernelInds,r) - repmat( mean( responseData(kernelInds,r),1 ), [ nT 1 ]);
        nlR(r) = expt_ms(:,r)'*resp_ms(:,r) / sqrt(expt_ms(:,r)'*expt_ms(:,r) * ...
            resp_ms(:,r)'*resp_ms(:,r));              
    end
    
    %% Outputs
    Z.NL.nlData = nlData;
    Z.NL.nonlinearity = nonlinearity;
    Z.NL.nType = nType;
    Z.NL.nlR = nlR;
    Z.NL.which = Z.kPred.which;
%     Z.NL.kernelPaths = kernelPaths;

    if saveNL
        Z.NL.saveNlPathName = tp_saveNL(Z);
    end
    
end

