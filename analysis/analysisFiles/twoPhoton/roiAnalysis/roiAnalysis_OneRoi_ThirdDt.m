function roi = roiAnalysis_OneRoi_ThirdDt(roi,varargin)
dtMax = 5;
tMax = 27; % size of the third order kernel. 32 - 5;
whichSecondKernel = 'Aligned';
order = 3;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% create corrParam.
dtBank_ThirdOrder = [{(0:dtMax)'},{(0:dtMax)'}];
corrParam_Third = K2K3ToGlider_Utils_FromDtBankToCorrParam(dtBank_ThirdOrder,order);

switch whichSecondKernel
    case 'Orignal'
        thirdKernel = roi.filterInfo.thirdKernel.Original; % cell(4,1); cell{1} has 20 bars.
    case 'Aligned'
        thirdKernel = roi.filterInfo.thirdKernel.Aligned; % cell(4,1); cell{1} has 20 bars.
end
nDxBank = length(thirdKernel);
nMultiBars = size(thirdKernel{1},2);
% you could calculate only part of it..
if isfield(roi.filterInfo.thirdKernel,'barSelected')
    barSelected = roi.filterInfo.thirdKernel.barSelected;
else
    barSelected = true(nMultiBars,1);
end

%% calculate glider response
averageCorrValue_3o = cell(4,1);
barUse = find(barSelected);
for cc = 1:1:nDxBank
    averageCorrValue_3o{cc} = zeros(length(corrParam_Third),nMultiBars);
    % store, but do not compute.
     for qq = 1:1:length(barUse)
         barUseThis = barUse(qq);
        [averageCorrValue_3o{cc}(:,barUseThis),~] = K3ToGlider_One_CorrType(thirdKernel{cc}(:,barUseThis),corrParam_Third,'tMax',tMax);
    end
end

roi.filterInfo.thirdKernel.glider = averageCorrValue_3o;

end