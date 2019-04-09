function [ resp ] = flyResp_expanded( whichOrder,filters,maxTau,x,y,noiseVar,XY )
% filters an input with a given filters of the desired orders. Option to add
% Gaussian noise of noiseVar variance. Inputs and outputs should all be
% column vectors.

%% Setup

dur = length(x);

if nargin < 7
    XY = [1 0];
end

if nargin < 6
    noiseVar = 0;
end

%% Generate responses

resp = zeros(size(x));

if whichOrder(1)
    if XY(1)
        resp = resp + filter(filters{1},1,x);
    end
    if XY(2)
        resp = resp + filter(filters{2},1,y);
    end
end

if whichOrder(2)
    thisResp = zeros(dur,1);
    for r = 1:(dur)-(maxTau-1)
        thisResp(r+(maxTau-1),1) = flipud(x(r:r+maxTau-1))'*filters{3}*flipud(y(r:r+maxTau-1));
    end
    resp = resp + thisResp;
end

if whichOrder(3)
    thisResp = specialthreedfilt(maxTau,x,x,y,filters{4}(:))';
    resp = resp + [zeros(maxTau-1,1); thisResp];
    thisResp = specialthreedfilt(maxTau,y,y,x,filters{5}(:))';
    resp = resp + [zeros(maxTau-1,1); thisResp];
end        
            
%% Add noise

noise = sqrt(noiseVar)*randn(size(x));
resp = resp + noise;

end

