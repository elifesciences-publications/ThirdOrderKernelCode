function quickViewKernelsFirst(kernels,varargin)
smoothFlag = false;
cutFilterFlag = false;
barRange = 5:15;
timeRange = 1:45;
titleByRoiSequenceFlag = false;
roiSequence = [];
subplotHt = 3;
subplotWd = 4;
colorbarFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii}, '= varargin{', num2str(ii + 1),'};'])
end
% there should be a limit on how many rois you are presenting, let us see.
% 5*5.

nMaxRoiOne = subplotHt * subplotWd;
nRoi = size(kernels,3);
nMaxRoi = min(nMaxRoiOne,nRoi);
%%
if nMaxRoi == nMaxRoiOne;
    
    nRound = ceil(nRoi/nMaxRoi);
    count = 1;
    for ii = 1:1:nRound
        MakeFigure;
        for cc = 1:1:nMaxRoiOne
            subplot(subplotHt,subplotWd,cc);
            if smoothFlag
                quickViewOneKernel_Smooth(squeeze(kernels(:,:,count)),1,'labelFlag',true,'cutFilterFlag',cutFilterFlag,'barRange',barRange,'timeRange',timeRange);
            else
                quickViewOneKernel(squeeze(kernels(:,:,count)),1,'labelFlag',false);
            end
            if titleByRoiSequenceFlag
                title(num2str(roiSequence(count)));
            else
                title(num2str(count));
            end
            count = count+1;
            if(count > nRoi)
                return
            end
        end
    end
else
    subplotHt = floor(sqrt(nRoi));
    subplotWd = ceil(nRoi/subplotHt);
    MakeFigure;
    for count = 1:1:nRoi
        subplot(subplotHt,subplotWd,count);
        if smoothFlag
            quickViewOneKernel_Smooth(squeeze(kernels(:,:,count)),1,'labelFlag',true,'cutFilterFlag',cutFilterFlag,'barRange',barRange,'timeRange',timeRange);
        else
            quickViewOneKernel(squeeze(kernels(:,:,count)),1,'labelFlag',false);
        end
        if titleByRoiSequenceFlag
            title(num2str(roiSequence(count)))
        else
            title(num2str(count));
        end
        
    end
end
