function [stim] = ReversePhiGeneration_Juyue(sign,d,phase,T)
% phase will go from 1 to 20, because there are 20 bars
% there would be 20 bars, put them at the different places???
% the sign could be
nBars = 20;
stimHz = 60;
% sign = [-1,1];
% d = -1;
% phase = 2;
% there is no need for T, I just have to have a 1 second stimulus. even
% shorter... I do not mind....
% it is so stupid to include a phase into it...


t = 1/stimHz:1/stimHz:T;
nT = length(t);
[ind1, ind2] = BarPairOnOff(t);
% check the time traces of the response, no need to repeat the stimulus....



%%
pos(1) = phase;
pos(2) = phase + d; % if d is 1, it is on the right, if d is -1, it is on the left. %

% if d = 1, phase 20 will have no effect.
% if d = -1, phase 1 will have no effect.
% think of this condition after the function.
stim = zeros(nT,nBars);
if d == 1
    if pos(1) == 20;
        
    else
        stim(ind2,pos(2)) = sign(2);
    end
    
    stim(ind1,pos(1)) = sign(1);
else
    
    if pos(1) == 1;
        
    else
        stim(ind2,pos(2)) = sign(2);
    end
    
    stim(ind1,pos(1)) = sign(1);
end

end
