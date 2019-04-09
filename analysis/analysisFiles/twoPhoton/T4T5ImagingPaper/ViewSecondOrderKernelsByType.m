function roiUse = ViewSecondOrderKernelsByType(roiData,varargin)
% clean D a little bit..
% ViewKernelsByType(roiData,'kernelExtractionMethod','reverse','typeSelected',[1,2,3,4]);
typeSelected = [1,2,3,4];
kernelOrZ = 'kernel';
saveFigFlag = false;
MainName = 'SecondOrderKernel';
titleByRoiSequenceFlag = true;
typeStr = {'T4Progressive','T4Regressive','T5Progressive','T5Regressive'};
smoothFlag = true;
dx = 1;
MeanOrIndividual = 'individualbars';
%%
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{',num2str(ii + 1),'};']);
end

nType = length(typeSelected);
nRoi = length(roiData);
% list all the edgeType
edgeType = zeros(nRoi,1);
kernelType  = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end

%%
for ii = 1:1:nType
    tt = typeSelected (ii);
    roiUse = find(edgeType == tt & kernelType > 1);
    %     roiUse = find(edgeType == tt);
    roiPlotUse = [];
    nRoiUse = length(roiUse);
    if isempty(roiUse)
        disp(['no good second order kernel for type : ',num2str(tt)]);
    else
        secondKernel = [];
        for jj = 1:1:nRoiUse
            rr = roiUse(jj);
            roi = roiData{rr};
            
            switch dx
                case 1
                    secondKernelInfo = roi.filterInfo.secondKernel.dx1;
                case 2
                    secondKernelInfo = roi.filterInfo.secondKernel.dx2;
            end
            
            barSelected = secondKernelInfo.barSelected;
            barUse = find(barSelected);
            nBarUse = length(barUse);
            %             barUse = 1:20;
            %             nBarUse = 20;
            
            switch MeanOrIndividual
                case 'allbars'
                    secondKernel = cat(2,secondKernel,mean(secondKernelInfo.Adjusted,2));
                    roiPlotUse = [roiPlotUse,rr];
                case 'individualbars'
                    roiPlotUse = [roiPlotUse; ones(nBarUse,1) * rr];
                    for qq = 1:1:nBarUse
                        barUseThis = barUse(qq);
                        switch kernelOrZ
                            case 'kernel'
                                secondKernel = cat(2,secondKernel,secondKernelInfo.Adjusted(:,barUseThis));
                            case 'kernelZ'
                                secondKernel = cat(2,secondKernel,secondKernelInfo.ZAdjusted(:,barUseThis));
                        end
                    end
            end
        end
        
        quickViewKernelsSecond(secondKernel,'smoothFlag',smoothFlag,'titleByRoiSequenceFlag',titleByRoiSequenceFlag,'roiSequence',roiPlotUse,...
            'saveFigFlag',saveFigFlag, 'MainName', [MainName,'_DX_',num2str(dx),typeStr{tt}]);
    end
end
% you also want to show

% to help you delete bad roi, plot all of them and give me the file name.
if isempty(typeSelected)
    roiUse = find(kernelType > 1);
    roiPlotUse = [];
    
    nRoiUse = length(roiUse);
    secondKernelAll = [];
    for jj = 1:1:nRoiUse
        rr = roiUse(jj);
        roiPlotUse = [roiPlotUse; ones(nBarUse,1) * rr];
        roi = roiData{rr};
        %         barUseThis = find(roi.filterInfo.secondBarSelected);
        barSelectedFirst = roi.filterInfo.firstBarSelected; % you can find the top three...
        barSelectedSecond = roi.filterInfo.secondBarSelected;
        barSelected = barSelectedFirst | barSelectedSecond;
        barUse = find(barSelected);
        nBarUse = length(barUse);
        
        for qq = 1:1:nBarUse
            barUseThis = barUse(qq);
            secondKernelAll = cat(2,secondKernelAll,roi.filterInfo.secondKernelAdjusted(:,barUseThis));
        end
        
    end
    quickViewKernelsSecond(secondKernel,'smoothFlag',smoothFlag,'titleByRoiSequenceFlag',titleByRoiSequenceFlag,'roiSequence',roiPlotUse,...
        'saveFigFlag',saveFigFlag, 'MainName', [MainName,'AllSecondOrder']);
    
end