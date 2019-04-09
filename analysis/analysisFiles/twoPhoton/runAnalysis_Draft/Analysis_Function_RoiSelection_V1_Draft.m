function roiSelected = Analysis_Function_RoiSelection_V1_Draft(filepath, kernel_identifier)

% load edge_related data
roi_data = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data','roi_data_edge_only');
nRoi = length(roi_data);
% first, select on DSI and ESI.
DSI = cellfun(@(roi) roi.typeInfo.DSI_Edge,roi_data);
ESI = cellfun(@(roi) roi.typeInfo.ESI,roi_data);
ccWholeTrace = cellfun(@(roi) roi.repeatability.value,roi_data);

%% 1o kernel selection code.
% load the first order kernel.
first_order_kernel = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data','first','first_order_format', 'old');
first_order_kernel_noise = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data', 'first_noise');
% calculate the rank of the distance.
firstRank = zeros(nRoi,1);
for rr = 1:1:nRoi
    firstRank(rr) = KernelSelectoin_MultiD_1o_draft(first_order_kernel(:,:,rr), first_order_kernel_noise(:,:,:,rr));
end

%% selection on some creteria
threshESIT4 = 0.3;
threshESIT5 = 0.4;
threshDSI = 0.4;
roiSelectedByDSI = abs(DSI) > threshDSI;
% roiSelectedByESI = abs(ESI) > threshESI;
roiSelectedByESI = ESI < - threshESIT5| ESI > threshESIT4;
roiSelectedByEdge =  roiSelectedByDSI & roiSelectedByESI;
repeatabilityThresh = 0.4;
roiSelectedByTrace = ccWholeTrace > repeatabilityThresh;
roiSelected = roiSelectedByEdge & roiSelectedByTrace & firstRank > 9990;
end