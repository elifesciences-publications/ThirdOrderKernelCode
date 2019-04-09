function [ saveTestData ] = genTestData( order,varargin )

%% Default parameters
maxLen = 50;
dur = 72000;
origFreqRatio = 1;
freqRatio = 1;
inVar = 1;
noiseVar = 5;

%% Varargin
    
for ii = 1:2:length(varargin)-1
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% Generate filters

% example 1D filter
filtx = linspace(1,maxLen,maxLen);
lpfun = @(x,tau) x.*exp(-x/tau);
lpslow = lpfun(filtx,10);
lpfast = lpfun(filtx,5);
% figure; plot(lpslow);

% example 2D filter
exfilt = lpslow'*lpfast - lpfast'*lpslow;
% figure; imagesc(exfilt);

% example 3D filter
[X Y Z] = meshgrid(linspace(1,maxLen,maxLen),linspace(1,maxLen,maxLen),...
    linspace(1,maxLen,maxLen));
omx = .02; omy = .01; omz = .1;
infilt = cos(omx*X.^2 + omy*Y.^2 + omz*Z.^2);
% threeDvisualize_slices(maxLen,9,infilt); % cool

%% Filter random inputs. Could add noise here if you wanted
 
x = randInput(1,inVar,dur*freqRatio)';
y = randInput(1,inVar,dur*freqRatio)';
switch order
    case 1
        resp = filter(lpslow,sum(lpslow),x);
        saveTestData.trueKernel = lpslow;
    case 2 
        resp = zeros(1,dur*freqRatio);
        for q = 1:(dur*freqRatio)-(maxLen-1)
            resp(q+(maxLen-1)) = flipud(x(q:q+maxLen-1))'*exfilt*flipud(y(q:q+maxLen-1));
        end
        saveTestData.trueKernel = exfilt;
    case 3
        resp = specialthreedfilt(maxLen,x,x,y,infilt(:));
        resp = [zeros(1,maxLen-1) resp];
        saveTestData.trueKernel = infilt;
end

% downsample
tGiven = linspace(1,dur,dur*freqRatio)';
tQuery = linspace(1,dur,dur)';
resp = interp1(tGiven,resp,tQuery);

% add noise
resp = repmat(resp, [1 5]);
resp(maxLen:end,:) = resp(maxLen:end,:) + sqrt(noiseVar)*randn(dur-maxLen+1,5);

% mean subtract everything
for q = 1:5
    resp(:,q) = resp(:,q) - mean(resp(:,q));
end
x = x - mean(x); y = y - mean(y);

%% Save

for p = 1:dur
    for q = 1:freqRatio;
        rIndex = 14+(q-1)*2;
        saveTestData.data.stim(p,rIndex) = x((p-1)*freqRatio+q);
        saveTestData.data.stim(p,rIndex+1) = y((p-1)*freqRatio+q);
    end
end

saveTestData.data.stim(:,3) = 1;
saveTestData.data.resp(:,3:7) = resp;
saveTestData.data.resp(:,8:12) = zeros(dur,5);
saveTestData.data.resp(:,18) = 6;
saveTestData.data.params.flickerFreq = 60 * origFreqRatio;
saveTestData.data.params.var = inVar;

end

