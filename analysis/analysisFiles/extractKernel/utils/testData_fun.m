function [ saveTestData ] = testData_fun( whichOrder,maxTau,varargin )

%% Input parameters
% dur = 72000;
dur = 1e5;
N = 2; 
inVar = 1;
noiseVar = 0;
anVar = 0;
dist = 1;
afterNoise = 0;
mouseNorm = 1;
deMeanStim = 0;
    
for ii = 1:2:length(varargin)-1
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if afterNoise
    anVar = noiseVar;
    noiseVar = 0;
end

%% Create filters
filters = exampleFilters(whichOrder,maxTau);
if whichOrder(3)
    filters{3} = removeDiag(filters{3});
end

%% Create inputs and resp
for rr = 1:N
    stim(:,rr) = randInput(inVar,dist,dur)';
end
if deMeanStim
    stimMeans = mean(stim,1);
    stim = stim - repmat(stimMeans,[dur 1]);
end

resp = zeros(dur,5);

for q = 1:5
    if N > 2
        for n = 1:N
            if n < N
                x = stim(:,n);
                y = stim(:,n+1);
            elseif n == N
                x = stim(:,n);
                y = stim(:,1);
            end    
            filtersUsed = filters;
    %         filtersUsed{2} = filtersUsed{2}/2;
            resp(:,q) = resp(:,q) + flyResp(whichOrder,filtersUsed,maxTau,x,y,noiseVar,[1 0])/N - ...
                flyResp(whichOrder,filtersUsed,maxTau,y,x,noiseVar,[1 0])/N;
        end
    else
        x = stim(:,1);
        y = stim(:,2);
        filtersUsed = filters;
    %         filtersUsed{2} = filtersUsed{2}/2;
        resp(:,q) = resp(:,q) + flyResp(whichOrder,filtersUsed,maxTau,x,y,noiseVar,[1 0]) - ...
            flyResp(whichOrder,filtersUsed,maxTau,y,x,noiseVar,[1 0]);
    end
end
respMeans = mean(resp,1);
% keyboard
afterNoise = sqrt(anVar) * randn(size(resp));
resp = resp + afterNoise;
resp = resp - repmat(respMeans,[dur 1]);
% keyboard
%% Format for saving
rIndex = 14;
saveTestData.data.stim(:,rIndex:rIndex+(N-1)) = stim;

%% Save all to structure
saveTestData.data.stim(:,3) = 1;
if mouseNorm
    saveTestData.data.resp(:,3:7) = resp / (60/(1000*1/4*pi/360));
else
    saveTestData.data.resp(:,3:7) = resp;
end
saveTestData.data.resp(:,8:12) = zeros(dur,5);
saveTestData.data.resp(:,18) = 6;
saveTestData.data.params.flickerFreq = 60;
saveTestData.data.params.var = inVar;
saveTestData.filters = filters;

end

