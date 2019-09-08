function [ mixedStimTraces ] = MixStim( stimTraces,sigma,alpha,g,deltaPhi,omShift )
% Mixes inputs from kernel extraction experiment to emulate the fly's
% ommatidial blur. Evaluates mixing for a given phase alpha - loop over
% alphas to integrate this out.

% Note that alpha should be in actual units of the fly's eye (i.e. 5ish
% degrees), whereas xRange is the number of repeats (scaled by deltaPhi). 

xRange = 5;
gaussFun = @(x,alpha,sigma) 1/(sqrt(2*pi*sigma^2)) * exp(-(x-alpha).^2/(2*sigma^2));
xArray = [-xRange*4 : 4 : 4*xRange];

for q = 0:3
    weightsL(q+1) = sum(gaussFun((xArray+q)*deltaPhi,alpha,sigma),2);
    weightsR(q+1) = sum(gaussFun((xArray+q)*deltaPhi-omShift,alpha,sigma),2);
end

mixedStimTraces(:,1,:) = weightsL(1)*g + weightsL(2)*stimTraces(:,1,:) + ...
    weightsL(3)*stimTraces(:,2,:) + weightsL(4)*g;
mixedStimTraces(:,2,:) = weightsR(1)*g + weightsR(2)*stimTraces(:,1,:) + ...
    weightsR(3)*stimTraces(:,2,:) + weightsR(4)*g;

end

