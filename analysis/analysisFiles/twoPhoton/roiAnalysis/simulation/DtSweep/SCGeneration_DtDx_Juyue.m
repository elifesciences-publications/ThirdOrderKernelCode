function stim = SCGeneration_DtDx_Juyue(dtNum,dxNum,nT,sign,nBars)
%
% the simpliest situtation, rate 60 Hz or 180Hz.
% d = -1;
% nT = 5;
% dtNum = 1;
% 
% nBars = 20;
A = 0.5;

% Initializtion.
% randStim = [1,-1];
% dt = 0; only spatial correlation shows up. dependends on dx... linear
% map will be happy, if it is not very direction selective. but bundle
% together.
dtNumAbs = abs(dtNum);
stim = zeros(nT,nBars);
randStim = 2 * round(rand(nT,nBars)) -1;

% for every frame, the stimulus will change....
% so there is no dt... still good to keep this term.stim(1:dtNumAbs,:) = randStim(1:dtNumAbs,:);

for tt = dtNumAbs + 1:nT
    %
    corrLineTemp = randStim(tt - dtNumAbs,:);
    paddingDigit = 2 * round(rand(1,dxNum)) - 1;
    if dtNum >= 0   % to the right
        corrLine = [paddingDigit, corrLineTemp(1,1:end - dxNum)];
    elseif dtNum < 0 % to the left
        corrLine = [corrLineTemp(1,dxNum + 1:end),paddingDigit];
    end
    
    noiseLine = randStim(tt,:);
    stim(tt,:) = sign * A * corrLine + (1 - A) * noiseLine;
    
end

end