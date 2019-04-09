function MyScatterStimLogV(stim,v,strInfo)
% because the data set are too large, it is really hard to draw the binned
% data
% plot the stimlus contrast, standard deviation, and mean value's influece
% on the value of the velocity.

titleStr = strInfo.title;
%
makeFigure
subplot(2,1,1)
scatter(stim.max,v.max,'r.');
set(gca,'YScale','log');
title(titleStr);
xlabel('maximum contrast of the stimulus');
ylabel('Log Predicted Velocity');
figurePretty;

subplot(2,1,2)
scatter(stim.std,v.std,'r.');
set(gca,'YScale','log');
title(titleStr);
xlabel('std of contrast of the stimulus');
ylabel('Log Predicted Velocity');
figurePretty;

end
