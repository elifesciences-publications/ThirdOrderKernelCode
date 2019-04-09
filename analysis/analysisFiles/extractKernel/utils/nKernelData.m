function [ kernelData ] = nKernelData( D,OD,q,N )
% Takes output from grabData and picks out parts necessary for kernel
% extraction. Interpolation functionality removed (see getKernelData).
% Only extracts turning 
%% Pull the right columns out of D.data
whichFile =  diff(OD.rig) < 1;
whichFile = [0 cumsum(whichFile)] + 1;  
qRange = find( whichFile == q );
kernelData.qSize = size(qRange,2); % corresponds to number of flies in this q

%% Get turning traces

turnTraces(:,:) = OD.XY(:,qRange,1);
% turnTraces = mean(turnTraces,2);
walkTraces(:,:) = OD.XY(:,qRange,2); 
% walkTraces = mean(turnTraces,2);

%% Get stimulus traces   
for r = 1:N
    rIndex = 14; 
    stimTraces(:,r) = D.data.stim(:,rIndex+(r-1),q); 
end

%% Save output
kernelData.stimTraces = stimTraces;
kernelData.turnTraces = turnTraces;
kernelData.walkTraces = walkTraces;

end

