function [res] =  AnaDataUniform(param,extOutFlag,p)
% there are many different analysis could be done, so do them one by one.
% calculate the correlation
% analyze the bad image, or what is the outlier
% analyze the result without outlier,
% too many things could be done within one thing.
% you can write separate function.

% load all the data,
% decide later what to do
D = MyLoad(param);
% the res is a temporary to get value from function , no usage in the
% end...

v = D.v;
stimc = D.stimc;
imageID = D.imageID;
if extOutFlag
    [v,~,~]  = AnaDelData_Perc(p,v,stimc,imageID);
end
strTitle = ['histogram of predicted velocity, velocity = +/-', num2str(abs(v.real(1)))];
DistrHistPlotK2K3(v, strTitle);
% calculte the correlation and plot figure?
% instead of calculating the correlation directly, you could bin the data
% and calculate the correlation inside it. why do you want to do that?
%res.theo= AnalysizeCorrTheo(v.HRC,v.ConvK3,v.PSK3,v.AutoK2,v.real);
% bin the data...



res.exp = AnalysizeCorr(v.HRC,v.k2,v.k3,v.real);
%res.exp= AnalysizeCorrSpearman(v.HRC,v.k2,v.k3,v.real);

res.theo.vreal = v.real;
res.exp.vreal = v.real;
res.v = v;
end
