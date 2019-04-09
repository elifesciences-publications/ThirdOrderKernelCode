function kernelCenter = roiAnalysis_FindFirstKernelCenter(roi,varargin)
% roiAnalysis_FindFirstKernelCenter(roi,varargin,'method',
% 'barQuality','flyEye','left');
methodFilterCenter = 'barQuality';
%
% methodFilterCenter = 'prob';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{',num2str(ii + 1),'};']);
end

switch methodFilterCenter
    case 'barQuality'
        % first,double barSelected. then find connected region, then
        barSelected = roi.filterInfo.firstKernel.barSelected;
        % find connected region.
        barSelectedLong = repmat(barSelected,[2,1]);
        
        conBar = bwconncomp(barSelectedLong);
        nObj = conBar.NumObjects;
        % find the largest
        nPixelPerObj = zeros(nObj,1);
        for ii = 1:1:nObj
            nPixelPerObj(ii) = length(conBar.PixelIdxList{ii});
        end
        [~,ind] = max(nPixelPerObj);
        if isempty(ind)
            kernelCenter = 10;
        else
            kernelCenter = round(mean(conBar.PixelIdxList{ind}));
            kernelCenter = mod(kernelCenter - 1,20) + 1;
            % find the
        end
    case 'prob'
        % dangerous, store the data and move it to somewhere.
        S = GetSystemConfiguration;
        kernelFolder = S.kernelSavePath;

        dataForAlign = [kernelFolder,'\T4T5_Imaging_Paper\TimeTracesToFindRF\AlignmentGoldTrace.mat'];
        load(dataForAlign);
        edgeType = roi.prob.PStim.edgeType;
        trace = [roi.prob.PStim.trace{1,edgeType}; roi.prob.PStim.trace{2,edgeType}];
        barWidth = roi.stimInfo.barWidth;

        if edgeType == 1 || edgeType == 3
            dirType = 1;
        else
            dirType = 2;
        end
        switch dirType
            case 1 % left
                traceTemplate = left.trace;
                relativeTimeTemplate = left.relativeTime;
            case 2 % right
                traceTemplate = right.trace;
                relativeTimeTemplate = right.relativeTime;
        end
        % judge it was left or right....
        nTemplate = length(traceTemplate);
        relativeTimeMat = size(nTemplate,1);
        for ii = 1:1:nTemplate
            relativeTimeMat(ii) = MyXCorr_RelativePos(trace,traceTemplate{ii});
        end
        
        % find the best alignment, which maintain the structure, but store the
        % structure.
        xInit = relativeTimeMat(1);
        xBest = fminsearch(@(x)sum(((relativeTimeTemplate + x) - relativeTimeMat').^2)  ,xInit);
        xBest = -xBest; % because you want template VS trace, not trace VS template.
        switch dirType
            case 1
                kernelCenter =  xBest * 1/13 *30 / barWidth;
                kernelCenter = round(kernelCenter - 4.52); % align all the left guy along the center 11
                
            case 2
                kernelCenter =  -xBest * 1/13 *30 / barWidth;
                kernelCenter = round(kernelCenter + 5.4891); % for the left .... cool.... soooooo cool....
                kernelCenter = kernelCenter + 1; % to componsate left and right. align all the right guy along the center 10
        end
        nMultiBars = 20;
        kernelCenter = kernelCenter + nMultiBars * 4; % avoid negetive number.
        kernelCenter = mod(kernelCenter - 1,nMultiBars) + 1;
        
end
end