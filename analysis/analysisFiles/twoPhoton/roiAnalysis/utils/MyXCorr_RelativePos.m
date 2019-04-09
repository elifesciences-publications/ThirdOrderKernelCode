function xab = MyXCorr_RelativePos(a,b)
% before doing correlation, clean the data. pad nan with 0;
% this might destroy all your alignment work...
a(isnan(a)) = 0;
b(isnan(b)) = 0;

[corrValue,corrLag]= xcorr(a,b);
[~,maxCorrInd] = max(corrValue);
xab = corrLag(maxCorrInd); %if a is a head of b, then xcorr (a,b) peak at -1.


% first, makesure it is within one circle.
cycleN = (360/30) * 13; % this might change in the future. hard coded here, very dangerous....
halfCycleN = floor(cycleN/2);
range = -(halfCycleN - 1):1:halfCycleN; % that is my idea range.... how do you put everything into that? % you could change that in the future if you like....
% does it matter? just do it.
if ~ismember(xab,range)
    % do something...
    a = xab + 3 * cycleN; % get rid of negative values.
    a = mod(a - 1,cycleN) + 1; % a is in 1 to cycleN now.
    if a > halfCycleN
        a = -(cycleN - a);
    end
    xab = a;
end
end