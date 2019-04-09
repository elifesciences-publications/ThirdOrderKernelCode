function [ saveTestData ] = genTestData( order,N,varargin )

%% Default parameters
maxLen = 5;
dur = 1e4;
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
 
for rr = 1:N
    stim(:,rr) = randInput(1,inVar,dur)';
end

for rr = 1:N
    x = stim(:,rr);
    if rr == N
        y = stim(:,1);
    else 
        y = stim(:,rr+1);
    end
    
    switch order
        case 1
            resp(:,rr) = filter(lpslow,sum(lpslow),x);
            saveTestData.trueKernel = lpslow;
        case 2 
            resp = zeros(1,dur);
            for q = 1:(dur)-(maxLen-1)
                resp(q+(maxLen-1),rr) = flipud(x(q:q+maxLen-1))'*exfilt*flipud(y(q:q+maxLen-1));
            end
            saveTestData.trueKernel = exfilt;
        case 3
            resp(:,rr) = [ zeros specialthreedfilt(maxLen,x,x,y,infilt(:))];
            saveTestData.trueKernel = infilt;
    end
end
 
% add noise
resp = repmat(mean(resp,2), [1 5]);
resp(maxLen:end,:) = resp(maxLen:end,:) + sqrt(noiseVar)*randn(dur-maxLen+1,5);

% mean subtract everything
for q = 1:5
    resp(:,q) = resp(:,q) - mean(resp(:,q));
end
x = x - mean(x); y = y - mean(y);

%% Save

rIndex = 14;
for n = 1:N    
    saveTestData.data.stim(:,rIndex+(n-1)) = stim(:,n);
end

saveTestData.data.stim(:,3) = 1;
saveTestData.data.resp(:,3:7) = resp;
saveTestData.data.resp(:,8:12) = zeros(dur,5);
saveTestData.data.resp(:,18) = 6;
saveTestData.data.params.flickerFreq = 60 ;
saveTestData.data.params.var = inVar;

end

