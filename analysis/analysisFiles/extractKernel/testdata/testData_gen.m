close all
clear all

%% Create filters
whichOrder = [ 1 1 1 ];
maxLen = 5;
dur = 50000;
origFreqRatio = 1;
freqRatio = 1;

filters = exampleFilters(whichOrder,maxLen);

%% Filter random inputs. Could add noise here if you wanted
x = randInput(1,1,dur*freqRatio)';
y = randInput(1,1,dur*freqRatio)';
noiseVar = 0;
resp = flyResp(whichOrder,filters,maxLen,x,y,noiseVar,[1 0]);
resp = repmat(resp, [1 5]);

%% Save
for p = 1:dur
    for q = 1:freqRatio;
        rIndex = 14+(q-1)*2;
        saveTestData.data.stim(p,rIndex) = x((p-1)*freqRatio+q);
        saveTestData.data.stim(p,rIndex+1) = y((p-1)*freqRatio+q);
    end
end

saveTestData.data.stim(:,3) = 1;
% saveTestData.data.resp(:,3:7) = resp / (60/(1000*1/4*pi/360));
% saveTestData.data.resp(:,8:12) = zeros(dur,5);
saveTestData.data.resp(:,3:7) = zeros(dur,5);
saveTestData.data.resp(:,8:12) = resp / (60/(1000*1/4*pi/360));
saveTestData.data.resp(:,18) = 6;
saveTestData.data.params.flickerFreq = 60 * origFreqRatio;
saveTestData.data.params.var = 1;

clearvars -except saveTestData
save saveTestData

