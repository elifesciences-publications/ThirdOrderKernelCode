function Z = tp_averageKernels( Z, linPath, quadPath, flickPath, noiseLinPath, noiseQuadPath )
% Picks out significant linear kernels, finds which bars are significant,
% averages the corresponding quadratic kernels by ROI type or direction
% selectivity.

    verbose = 0;
    loadFlexibleInputs(Z);
    
    if nargin < 4
        HPathIn = fopen('dataPath.csv');
        C = textscan(HPathIn,'%s');
        kernelFolder = C{1}{3};
        flickPath = UiPickFiles('FilterSpec',[kernelFolder '\twoPhoton\' name],'Prompt','Select flicker data.');
    end
    
    if nargin < 3
        quadPath = UiPickFiles('FilterSpec',[kernelFolder '\twoPhoton\' name],'Prompt','Select 2o kernels.');
    end
    
    if nargin < 2
        linPath = UiPickFiles('FilterSpec',[kernelFolder '\twoPhoton\' name],'Prompt','Select 1o kernels.');
    end
    
    %% Load the things you will need
    
    load(linPath);
    linearFilters = saveKernels.kernels;
    ROIuse = saveKernels.ROIuse;
    maxTau(1) = saveKernels.maxTau;
    
    load(quadPath);
    quadFilters = saveKernels.kernels;
    assert(all(ROIuse == saveKernels.ROIuse));
    maxTau(2) = saveKernels.maxTau;
    
%     load(flickPath);
%     kernelInds = saveFlick.kernelInds;
%     spatialAlignTrace = saveFlick.spatialAlignTrace;
%     assert(all(ROIuse == saveFlick.ROIuse));
    
    nRoi = length(ROIuse);
    roisInverse = zeros(size(Z.ROI.roiMasks,3),1);
    for q = 1:length(ROIuse)
        roisInverse(ROIuse(q)) = q;
    end
 
    %% Pick out linear filters that have "high peaks".
    % Find bars among these that are significant. 
    
    % IF NOISEKERNELS EXIST WE SHOULD USE THEM, otherwise use overall
    % variance
    
    barChooseMethod = 2;
    
    zThresh = 4.1;

    signifLinearRoiIndices = [];
    barsSignif = cell(0);
    
    for q = 1:nRoi
        thisLin = linearFilters(:,:,q);
        thisQuad = quadFilters(:,:,q);
        if nargin < 5
            linSD = std(thisLin(:));
            quadSD = std(thisQuad(:));
            signif = abs(thisLin) > zThresh*linSD;
        end
        signifSum = sum(sum(signif));
        if signifSum > 0
            switch barChooseMethod

                case 1 % default - which bars have significant pixels?            
                    theseBarsSignif = find(sum(signif,1));
                    signifLinearRoiIndices = cat(1,signifLinearRoiIndices,q);
                    barsSignif{length(signifLinearRoiIndices)} = theseBarsSignif;

                case 2 % find bars with significant pixels, get neighbors (lower threshold)  
                    lessSignif = abs(thisLin) > zThresh*linSD*.8; % lower threshold
                    allSignif = find(sum(lessSignif,1));
                    if length(allSignif) == 1 % there's probably a much less terrible way to do all of this
                        blocks{1} = allSignif;
                    else
                        seqInd = 1;
                        clear blocks
                        blocks{1} = allSignif(1);
                        for r = 2:length(allSignif)
                            if allSignif(r) - allSignif(r-1) == 1
                                blocks{seqInd} = cat(1,blocks{seqInd},allSignif(r));
                            else
                                seqInd = seqInd + 1;
                                blocks{seqInd} = allSignif(r);
                            end
                        end
                        keepBlock = zeros(length(blocks),1);
                        for r = 1:length(blocks)
                            if length(blocks{r}) > 1                                   
                                keepBlock(r) = 1;
                            end
                        end
                        if sum(keepBlock) > 0
                            blocks = blocks(find(keepBlock));
                            theseBarsSignif = [];
                            for r = 1:length(blocks)
                                theseBarsSignif = cat(1,theseBarsSignif,blocks{r});
                            end
                            signifLinearRoiIndices = cat(1,signifLinearRoiIndices,q);
                            barsSignif{length(signifLinearRoiIndices)} = theseBarsSignif(1:end-1);
                            %% visualize
%                             for q = 1:length(barsSignif{end})
%                                 figure;
%                                 imagesc(reshape(thisQuad(:,barsSignif{end}(q)),[60 60]));
%                             end
                        end                        
                    end
                    
                case 3 % only based on the 2o kernels themsleves. 
                    % get standard error based on the 20 kernels
                    thisSignif = zeros(1,size(thisQuad,2));
                    numOffDiag = 5;
                    [ iMap jMap ] = meshgrid([1:maxTau(2)]);
                    keepMap = abs(iMap - jMap) <= numOffDiag;
                    keepMap = keepMap .* ( ones(maxTau(2)) - eye(maxTau(2)) );
                    keepMap = keepMap(:);
                    for r = 1:size(thisQuad,2)
                        if sum((thisQuad(:,r) .* keepMap ) > 4 * quadSD) > 5
                            thisSignif(r) = 1;
                            figure; 
                            subplot(2,1,1); imagesc(reshape(thisQuad(:,r),[60 60]));
                            subplot(2,1,2); imagesc(reshape(thisQuad(:,r) .* (abs(thisQuad(:,r)) > 4 * quadSD),[60 60]));
                        end
                    end
                    if sum(thisSignif) > 0
                        signifLinearRoiIndices = cat(1,signifLinearRoiIndices,q);
                        barsSignif{length(signifLinearRoiIndices)} = find(thisSignif);
                    end    
                    
            end             
        end         
    end
    signifRoiIDs = ROIuse(signifLinearRoiIndices);
    
    %% Get direction selectivity (edge type preference) of significant ROIs
    if ~isfield(Z,'eval')
        Z = tp_roiEval(Z);
    end
    
    dsMag = Z.eval.direction_selectivity(signifRoiIDs);
    leftPop = find( dsMag > 0 );
    rightPop = find( dsMag < 0 );
    
    %% Average over direction-selective populations
    leftMean = zeros(60^2,1);
    totalL = 0;
    for q = 1:length(leftPop)
        leftMean = leftMean + sum(quadFilters(:,barsSignif{leftPop(q)},roisInverse(signifRoiIDs(leftPop(q)))),2);
        totalL = totalL + length(barsSignif{leftPop(q)});
    end
    leftMean = reshape(leftMean,[60 60]) / max(totalL,1);
    rightMean = zeros(60^2,1);
    totalR = 0;
    for q = 1:length(rightPop)
        rightMean = rightMean + sum(quadFilters(:,barsSignif{rightPop(q)},roisInverse(signifRoiIDs(rightPop(q)))),2);
        totalR = totalR + length(barsSignif{rightPop(q)});
    end
    rightMean = reshape(rightMean,[60 60]) / max(totalR,1);
    figure;
    subplot(1,2,1); imagesc(leftMean); hold all; plot([1:60],[1:60],'k');
    maxLeft = max(leftMean(:)); axis xy;
    if maxLeft == 0
        maxLeft = 1;
    end
    set(gca,'Clim',[-maxLeft maxLeft]); title('left');
    set(gca,'XTick',[15:15:60],'XTickLabel',round(1000/60*[15:15:60]),...
        'YTick',[15:15:60],'YTickLabel',round(1000/60*[15:15:60]));
    xlabel('\tau_1 (ms)'); ylabel('\tau_2 (ms)');
    
    subplot(1,2,2); imagesc(rightMean); hold all; plot([1:60],[1:60],'k');
    maxRight = max(rightMean(:)); axis xy;
    if maxRight == 0
        maxRight = 1;
    end
    set(gca,'Clim',[-maxRight maxRight]); title('right');
    set(gca,'XTick',[15:15:60],'XTickLabel',round(1000/60*[15:15:60]),...
        'YTick',[15:15:60],'YTickLabel',round(1000/60*[15:15:60]));
    xlabel('\tau_1 (ms)'); ylabel('\tau_2 (ms)');
    
    %% See individual filters 
    if verbose
        for q = 1:length(signifRoiIDs);
            figure;
            imagesc(linearFilters(signifRoiIDs(q)));
            title(['1^o filter, ROI ' num2str(signifRoiIDs(q)) ]);
            ceilSP = ceil(sqrt(length(barsSignif{q})));
            roundSP = round(sqrt(length(barsSignif{q})));
            figure;
            suptitle(['2^o filters, ROI ' num2str(signifRoiIDs(q)) ]);
            for r = 1:length(barsSignif{q})
                subplot(roundSP,ceilSP,r);
                imagesc(reshape(quadFilters(:,barsSignif{q}(r),roisInverse(signifRoiIDs(q))),[60 60]));
            end 
        end
    end
    
    %% See ROIs selected
    seeAll = zeros(imgSize(1),imgSize(2));
    for q = 1:length(signifRoiIDs)
        seeAll = seeAll + Z.ROI.roiMasks(:,:,q) * (mod(q,4) + 1); 
    end
    figure; imagesc(seeAll); title('ROIs used');
    
    %% Save average kernels
    avg.leftMean = leftMean;
    avg.rightMean = rightMean;
    avg.signifRoiIDs = signifRoiIDs;
    avg.barsSignif = barsSignif;
    avg.dsMag = dsMag;
    Z.avg = avg;
    
end

