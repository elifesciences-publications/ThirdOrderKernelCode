function bestRoi = FigPlot2_Util_SelectIndividualKernel(roiData,n,varargin)
method = 'manual';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
switch method
    case 'manual'
        bestRoi = [];
        
    case 'maxConnectedArea'
        nType = 4;
        % roiDataType = cell(nType,1);
        % roiDataBest = cell(nType,1);
        roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData);
        
        nRoi = length(roiData);
        edgeType = zeros(nRoi,1);
        kernelType = zeros(nRoi,1);
        for rr = 1:1:nRoi
            roi = roiData{rr};
            edgeType(rr) = roi.typeInfo.edgeType;
            kernelType(rr) = roi.filterInfo.kernelType;
        end
        
        flyID = zeros(nRoi,1);
        nfly = length(roiByFly);
        for ff = 1:1:nfly
            roiUse = roiByFly(ff).roiUse;
            flyID(roiUse) = ff;
        end
        
        kernelQuality = zeros(nRoi,1);
        for rr = 1:1:nRoi
            kernelQuality(rr) = roiData{rr}.filterInfo.firstKernel.maxConnectedArea;
        end
        
        bestRoi = zeros(nType,n);
        for tt = 1:1:4
            %     roiUse = find(edgeType == tt & kernelType > 1); % do not limited to the kernel you selected.
            roiSelectedType = edgeType == tt & (kernelType == 1 | kernelType == 3);
            bestRoiFly = zeros(nfly,1);
            if isempty(find(roiSelectedType,1))
                disp(['no good second order kernel for type : ',num2str(tt)]);
            else
                % get the best one for each flyID...
                for ff = 1:1:nfly
                    roiSelectedFly = flyID == ff; % selected for this might be all zeros.
                    roiUse = find(roiSelectedFly & roiSelectedType);
                    if ~isempty(roiUse) % this fly has rois in this type. which one is the largest.
                        kQ = zeros(nRoi,1);
                        kQ(roiUse) = kernelQuality(roiUse);
                        [~,bestRoiFly(ff)] = max(kQ);
                    end
                end
                
                bestRoiFly(bestRoiFly == 0) = [];
                kQ = zeros(nRoi,1);
                kQ(bestRoiFly) = kernelQuality(bestRoiFly);
                
                % select the highest 4.
                [~,indSort] = sort(kQ,'descend');
                bestRoi(tt,1:min(n,length(bestRoiFly))) = indSort(1:min(n,length(bestRoiFly)));
            end
        end
        
end
end
