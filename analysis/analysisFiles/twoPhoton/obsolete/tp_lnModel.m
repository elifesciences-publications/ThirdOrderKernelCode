function Z = tp_lnModel( Z )
% Fit LN model of flicker data

    maxTau = 50;
    nBins = 20;
    nType = 'disc';
    lnModelTestData = 0;
    polyOrder = 2;
    nMultiBars = 4;
    multiBarsUse = [1:nMultiBars];

    loadFlexibleInputs(Z)
    
    %% Load everything from Z.flick  

    flickNames = fieldnames(Z.flick);
    for ii = 1:length(flickNames)
        eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
    end

    %% Mean subtract response data
    responseData(kernelInds,:) = responseData(kernelInds,:) - ...
        repmat(mean(responseData(kernelInds,:),1),[length(kernelInds) 1]);
    
    %% Linear kernels 
    
    for q = multiBarsUse
        for r = 1:length(ROIuse)
            firstInd = q;
            secondInd = mod(q,nMultiBars) + 1;
            kernels(:,firstInd,r) = oneD_filter(alignedStimulusData{firstInd}(kernelInds,r),...
                responseData(kernelInds,r),maxTau);
            kernels(:,secondInd,r) = oneD_filter(alignedStimulusData{secondInd}(kernelInds,r),...
                responseData(kernelInds,r),maxTau);
        end
    end
    
    %% Compute expected response
    
    linearExpected = zeros(size(kernelInds,2),length(ROIuse));
    for q = multiBarsUse
        for r = 1:length(ROIuse)
            firstInd = q;
            secondInd = mod(q,nMultiBars) + 1;
            thisExpected =  (filter(kernels(:,firstInd,r),1,alignedStimulusData{firstInd}(kernelInds,r)) + ...
                filter(kernels(:,secondInd,r),1,alignedStimulusData{secondInd}(kernelInds,r)))/2;
            linearExpected(:,r) = linearExpected(:,r) + thisExpected;
        end
    end      

    %% Static nonlinearity
    switch nType
        case 'polyfit'             
            
            for r = 1:length(ROIuse)
                nl.polyCos(:,r) = polyfit(linearExpected(:,r),responseData(kernelInds,r),polyOrder);
            end
            nonlinearity = inline('polyval(nl.polyCos(:,r),x)','x','r','nl'); 
            
            for r = 1:length(ROIuse)
               predRange = max(abs(linearExpected(:,r)));
               nlAxis = linspace(-predRange,predRange,1000);
               nlY = nonlinearity(nlAxis,r,nl);
               figure;
               subplot(1,2,1);
               theseKernels = kernels(:,:,r);
               imagesc(theseKernels); 
               thisMax = max(abs(theseKernels(:))); 
               set(gca,'Clim',[-thisMax thisMax]);
               colormap_gen; colormap(mymap);
               title('linear kernels');               
               subplot(1,2,2);
               plot(nlAxis,nlY); 
               title('nonlinearity');
                            
            end  
                           
        case 'disc'           
        	for r = 1:length(ROIuse)
               
               nBounds = [ min(linearExpected(:,r)) max(linearExpected(:,r)) ];
               nPoints = size(linearExpected,1);
               fitPoints = linspace(nBounds(1),nBounds(2),nBins+1);
               lowerBounds = repmat( fitPoints(1:end-1)', [ 1 nPoints ] );
               upperBounds = repmat( fitPoints(2:end)', [ 1 nPoints ] );
               nl.mids(:,r) = (fitPoints(1:end-1)+fitPoints(2:end))/2;
               binLocs = repmat(linearExpected(:,r)',[ nBins 1 ]);
               binLocs = ( binLocs > lowerBounds ) .* ( binLocs < upperBounds );
               
               respSd = std(responseData(kernelInds,r));
               
               for q = 1:nBins                  
                  histID{q,r} = find(binLocs(q,:));                 
                  respVals = responseData(kernelInds(histID{q,r}),r);
                  nl.means(q,r) = mean(respVals(:));
                  nl.sdFunct(q,r) =  respSd / sqrt(length(histID{q,r}));
               end 
               
               figure;
               subplot(1,2,1);
               theseKernels = kernels(:,:,r);
               imagesc(theseKernels); 
               thisMax = max(abs(theseKernels(:))); 
               set(gca,'Clim',[-thisMax thisMax]);
               colormap_gen; colormap(mymap);
               title('linear kernels');               
               subplot(1,2,2);
               errorbar(nl.mids(:,r),nl.means(:,r),nl.sdFunct(:,r));
               ylabel('Response'); xlabel('Linear Prediction');              
               nonlinearity = inline('interp1(nl.mids(:,r),nl.means(:,r),x,''nearest'',''extrap'')','x','r','nl'); 
               
            end             
    end    
    Z.LN.nl = nl;
    
    %% Outputs
    Z.LN.nonlinearity = nonlinearity;
    Z.LN.kernels = kernels;
    Z.LN.linearExpected = linearExpected;
    Z.LN.nType = nType;
   
end

