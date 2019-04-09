function xt = SineWaveGeneration_Juyue(stimLambda,stimOmega,constrast,T, nBarUse,barWd)
% barWd = 10;
stimHz = 60;
tVect = (1:T) * 1/stimHz; % T is the total length of the stimulus.
xVect = (1:nBarUse) * barWd;
[ inLocsT,inLocsX ] = ndgrid( tVect, xVect );
xt = constrast * sin(2*pi *(inLocsX /stimLambda - inLocsT * stimOmega));

% what is the range of your stimulus? do you want to change that?

end