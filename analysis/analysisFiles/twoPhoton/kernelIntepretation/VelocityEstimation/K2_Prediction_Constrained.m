function prediction = K2_Prediction_Constrained(stimData, K2)
% stimData = zeros(T, nMultiBars);
[~, nMultiBars] = size(stimData);
maxTau_squared = size(K2{1},1);  maxTau = round(sqrt(maxTau_squared));
starting_point = maxTau;
ending_point = size(stimData,1);
dt_max = 2;
% at least two time points. if
stimInd = int32(starting_point:1:ending_point)';
nT = length(stimInd);
%% build the window size. do not use the whole K2 kernel, only small dt, signal is larger.
maxTau = round(sqrt(size(K2{1},1)));
ind = reshape( 1:1:maxTau^2,[maxTau,maxTau]);
wind = tril(true(maxTau, maxTau), dt_max) & triu(true(maxTau, maxTau), -dt_max);
indUse = ind(wind);
% 
dx_bank = 0:2; % only dx = 2 is used. for three, it is too noisy....
n_dx = length(dx_bank);
prediction_t_x_dx = zeros(nT,nMultiBars, n_dx); % prediction_t_x_dx is a function of time, location, and spatial interval
prediction = zeros(nT,1);% prediction is a function of time.
for dxx = 1:1:length(dx_bank)
    dx = dx_bank(dxx);
    stimMatrix = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimInd,maxTau,false,0,nMultiBars,2, dx);
    for qq = 1:1:nMultiBars
        % not the full dt is used.
        % get the index for dt is 5...
        
        prediction_t_x_dx(:,qq,dxx) = stimMatrix{qq}(:,indUse) * K2{dxx}(indUse,qq);
    end
    prediction = prediction + sum(prediction_t_x_dx(:,1: nMultiBars - dx,dxx),2);
end
end