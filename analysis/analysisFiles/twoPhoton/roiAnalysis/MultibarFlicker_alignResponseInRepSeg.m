function [respFull,indSetToZeros] = MultibarFlicker_alignResponseInRepSeg(resp,recordingTime)
[nT,nSeg]= size(recordingTime);

if nT  == sum(recordingTime(:,1))
    respFull = cell2mat(resp);
    respFull = reshape(respFull,[nT,nSeg]);
else
    respFull = zeros(size(recordingTime));
    timeFull = 1:nT;
    
    % you need a flag here to show that you do not need interpolation....
    for ss = 1:1:nSeg
        timeUsed = timeFull(recordingTime(:,ss));
        respFull(:,ss) = interp1(timeUsed,resp{ss},timeFull,'previous'); % you need non interpolated version here....
        % the first/last several elements could be NaN. set them to zero.
    end
end
indSetToZeros = false(nT,1);
indSetToZeros(1:5) = true;
indSetToZeros(end - 4:end) = true;

respFull(indSetToZeros,:) = 0;

end

% do you want to plot the predicted response in this way? very
% interesting... just do it.