function Z = tp_multiNL( Z )
% Fit a multi-dimensional nonlinearity to the output of 

    %% Default Params
    nBins = 5;
    loadFlexibleInputs(Z)     
    expected = Z.multiPred.expected;
    responseData = Z.flick.responseData;  
    nRoi = size(expected,2);  
    kernelInds = Z.flick.kernelInds;
        
    %% Fit nonlinearity between filter expected and response
        
    dUse = [1 2 3];
    for r = 1:nRoi 
    % Bin contingent on 3 parameters 
%         keyboard
        nPoints = size(expected,1);
        for s = 1:length(dUse)
            nBounds{s} = [ percentileThresh(expected(:,r,s),.05),...
                percentileThresh(expected(:,r,s),.95) ];
            fitPoints{s} = linspace(nBounds{s}(1),nBounds{s}(2),nBins+1);
            lowerBounds{s} = repmat( fitPoints{s}(1:end-1)', [ 1 nPoints ] );
            upperBounds{s} = repmat( fitPoints{s}(2:end)', [ 1 nPoints ] );
            nlData.mids(:,r,s) = (fitPoints{s}(1:end-1)+fitPoints{s}(2:end))/2;
            binLocs{s} = repmat(expected(:,r,s)',[ nBins 1 ]);
            binLocs{s} = ( binLocs{s} > lowerBounds{s} ) .* ( binLocs{s} < upperBounds{s} );
        end       
        binDims = nBins*ones(1,length(dUse));
        giantLocsMat = cell(binDims);
        
        for n = 1:nPoints
            for s = 1:length(dUse)
                thisInd = find(binLocs{s}(:,n),1);
                if isempty(thisInd)
                	break
                end
                locs(s) = thisInd;  
            end
            switch length(dUse)
                case 1
                    giantLocsMat{locs(1)} = cat(1,giantLocsMat{locs(1)},n);
                case 2
                    giantLocsMat{locs(1),locs(2)} = cat(1,giantLocsMat{locs(1),locs(2)},n);
                case 3
                    giantLocsMat{locs(1),locs(2),locs(3)} = cat(1,giantLocsMat{locs(1),locs(2),locs(3)},n);
                case 4
                    giantLocsMat{locs(1),locs(2),locs(3),locs(4)} = cat(1,giantLocsMat{locs(1),locs(2),locs(3),locs(4)},n);
            end
        end        
        giantLocsMat = reshape(giantLocsMat,[nBins^length(dUse) 1]);
        for n = 1:length(giantLocsMat);
            means{r}(n) = mean(responseData(kernelInds(giantLocsMat{n}),r));
        end
        means{r} = reshape(means{r},binDims);
        threeDvisualize_slices(nBins,nBins,means{r});
%         nonlinearity = inline('                    
    end 
    Z.multiNL.means = means;
    
%     for r = 1:nRoi
%         for q = dUse
%             expected(:,r) = Z.multiPred.expected(:,r,q)

end

