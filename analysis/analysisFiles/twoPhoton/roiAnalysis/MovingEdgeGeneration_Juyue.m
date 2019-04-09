function xtFinal = MovingEdgeGeneration_Juyue(velocity,contrastPolarity,T,T_Transient,nBarUse,barWd,grayStartFlag)
% barWd = 10;
% dark or light
% left or right. 
stimHz = 60;
tVect = (1:T)* 1/stimHz; % s
xVect = (1:nBarUse) * barWd;


[ inLocsT,inLocsX ] = ndgrid( tVect, xVect );
% the velocity will determine
xt = (double((inLocsT *  abs(velocity)) > inLocsX) - 0.5) * contrastPolarity * 2;
if velocity > 0 
    xt = xt;
else
    xt = fliplr(xt);
end

startValue = - contrastPolarity;
xtFinal = ones(T_Transient,nBarUse) * startValue;
xtFinal = [xtFinal;xt(1: end - T_Transient,:)];
if grayStartFlag
    xtFinal(~(xtFinal == contrastPolarity)) = 0;
end

% moving everything a little bit later. T_transient.
% you should make sure it is 
% xt(xt == 0) = -contrastPolarity;
end