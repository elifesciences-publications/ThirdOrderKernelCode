function AnaDataIndVel(param)
% there are many different analysis could be done, so do them one by one.
% calculate the correlation
% analyze the bad image, or what is the outlier
% analyze the result without outlier,
% too many things could be done within one thing.
% you can write separate function.

% load all the data,
% decide later what to do

plotFlag = param.plotFlag;
D = MyLoadIndV(param);

nv = length(D);
res = cell(nv,1);


vValue = zeros(nv,1);
r.HRC = zeros(nv,1);
r.k2 = zeros(nv,1);
r.k3 = zeros(nv,1);
r.k2plusk3 = zeros(nv,1);
r.best = zeros(nv,1);
weight =  zeros(2,nv);

% the only file
for vv = 1:1:nv
    % first of all, load the data individually/
    v = D{vv}.v;
    stimc = D{vv}.stimc;
    imageID = D{vv}.imageID;
    % one more step, to exclude the image who are not very good.
    % alternatively, exclude the image who has strange values in it.
    
    
    % [v,stimc,imageID] = AnaDelData_Image(param,v,stimc,imageID);
    % try do exclude some data.
    % try to get a sense of the data.
    
    % even with the local contrast calculation , the extreme values in the
    % estimated kernel still influence the result. the correlation between
%     % predicted velocity and real velocity increases as the extrem value was throw out
 %   AnaCorrAllPerc(v,plotFlag);
 %   AnaVStimR(v,stimc);
%      p = 0.2;
%     [badImage] = AnaExtremImage(v,imageID,p);
%     if plotFlag
%         
%         HistNP(v);
%         % there is also outliers
%         ScatterV(v);
%         strTitle = ['histogram of predicted velocity, velocity = +/-', num2str(abs(v.real(1)))];
%         DistrHistPlotK2K3(v, strTitle);
%     end
%     
    % maybe, I could see whether there extreme value there..
    % calculte the correlation and plot figure?
    res{vv} = AnalysizeCorr(v.HRC,v.k2,v.k3,v.real);
    res{vv}.vreal = abs(v.real(1));
    
    r.HRC(vv) = res{vv}.r.HRC;
    r.k2(vv) = res{vv}.r.k2;
    r.k3(vv) = res{vv}.r.k3;
    r.k2plusk3(vv) = res{vv}.r.k2plusk3;
    r.best(vv) = res{vv}.r.best;
    
    weight(:,vv) = res{vv}.weight;
    vValue(vv) = res{vv}.vreal;
    
end

% sort V and all the other together.
[vValue,I] = sort(vValue);
r.HRC = r.HRC(I);
r.k2 = r.k2(I);
r.k3 = r.k3(I);
r.k2plusk3 = r.k2plusk3(I);
r.best = r.best(I);
weight = weight(:,I);

%%
if plotFlag
    % summarize the data and plot them accordingly
    
    strInfo.xlabel = 'velocity [degree/second]';
    strInfo.title = 'different velocity';
   % tempPlot(r,weight,vValue,strInfo);
    PlotXRW(r,weight,vValue,strInfo);
    % show the changing of r with v.
end
end
