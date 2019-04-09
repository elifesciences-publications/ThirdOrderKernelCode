function respFull = LN_CV_alignResponseInRepSeg(resp,recordingTime)
a = 1;
nSeg = length(resp);
nT = size(recordingTime);
respFull = zeros(size(recordingTime));
timeFull = 1:nT;

for ss = 1:1:nSeg
    timeUsed = timeFull(recordingTime(:,ss));
    respFull(:,ss) = interp1(timeUsed,resp{ss},timeFull,'linear');
    % the first/last several elements could be NaN. set them to zero.
end
respFull(1:5,:) = 0;
respFull(end-4:end,:) = 0;
end

% do you want to plot the predicted response in this way? very
% interesting... just do it.