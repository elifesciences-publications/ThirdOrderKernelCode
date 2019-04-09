function AnaDataIndVelFull(param,extOutFlag)
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
% sort D !
D = MySortD(D);
nv = length(D);

% the res is a temporary to get value from function , no usage in the
% end...
res.exp = cell(nv,1);
res.theo = cell(nv,1);
% the res.exp and res.theo should be the return value.
% this is the final result. for different velocity.
% they are infomation for real experimental one, exclude the HRC, and put
% the HRC into the theoretical workd.
%%
vValue = zeros(nv,1);

%%
exp.r.k2 = zeros(nv,1);
exp.r.k3 = zeros(nv,1);
exp.r.k2plusk3 = zeros(nv,1);
exp.r.best = zeros(nv,1);
exp.weight =  zeros(2,nv);
exp.mut.r = zeros(nv,3);
%% there could still be several other correlation could be done.
thoe.r.HRC = zeros(nv,1);
thoe.r.ConvK3 = zeros(nv,2);
thoe.r.bestConvK3 = zeros(nv,1);
thoe.weight.ConvK3 = zeros(2,nv);
thoe.r.PSK3 = zeros(nv,2);
thoe.r.bestPSK3 = zeros(nv,1);
thoe.weight.PSK3 = zeros(2,nv);
thoe.r.AutoK2 = zeros(nv,4);
thoe.r.bestAutoK2 = zeros(nv,1);
thoe.weight.AutoK2 = zeros(4,nv);
thoe.r.HRCConvK3 = zeros(nv,1);
thoe.weight.HRCConvK3 = zeros(3,nv);
thoe.r.HRCPSK3 = zeros(nv,1);
thoe.weightHRCPSK3 = zeros(3,nv);
thoe.r.HRCCP = zeros(nv,1);
thoe.weight.HRCCP = zeros(5,nv);
thoe.mut.r = zeros(nv,70,70);
thoe.mut.rroi = zeros(nv,9,9);

% the only file
for vv = 1:1:nv
    % first of all, load the data individually/
    v = D{vv}.v;
    stimc = D{vv}.stimc;
    imageID = D{vv}.imageID;
    % one more step, to exclude the image who are not very good.
    % alternatively, exclude the image who has strange values in it.
    
    
    %[v,stimc,imageID] = AnaDelData_Image(param,v,stimc,imageID);
    if extOutFlag
        p = 0.25;
        [v,stimc,imageID]  = AnaDelData_Perc(p,v,stimc,imageID);
    end
    % try do exclude some data.
    % try to get a sense of the data.
    
    % even with the local contrast calculation , the extreme values in the
    % estimated kernel still influence the result. the correlation between
    %     % predicted velocity and real velocity increases as the extrem value was throw out
    %   AnaCorrAllPerc(v,plotFlag);
    %    AnaVStimR(v,stimc);
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
    res.thoe{vv} = AnalysizeCorrThoe(v.HRC,v.ConvK3,v.PSK3,v.AutoK2,v.MC,v.real);
    res.exp{vv} = AnalysizeCorr(v.HRC,v.k2,v.k3,v.real);
    % res{vv} = AnalysizeCorr(v.HRC,v.k2,v.k3,v.real);
    % analysis the correlation between thoretical work.
    % analysis the correlation between experimental work
    % they should be calculated in different ways, do I have a way to
    % simplify my code?
    res.thoe{vv}.vreal = abs(v.real(1));
    res.exp{vv}.vreal = abs(v.real(1));
    
    %% exeperiment one.
    exp.r.HRC(vv) = res.exp{vv}.r.HRC;
    exp.r.k2(vv) = res.exp{vv}.r.k2;
    exp.r.k3(vv) = res.exp{vv}.r.k3;
    exp.r.k2plusk3(vv) = res.exp{vv}.r.k2plusk3;
    exp.r.best(vv) = res.exp{vv}.r.best;
    exp.weight(:,vv) = res.exp{vv}.weight;
    exp.mut.r(vv,:) = res.exp{vv}.mut.r;
    
    %% theoretical one.
    thoe.r.HRC(vv) = res.thoe{vv}.r.HRC;
    thoe.r.ConvK3(vv,:) = res.thoe{vv}.r.ConvK3;
    thoe.r.bestConvK3(vv) = res.thoe{vv}.r.bestConvK3;
    thoe.weight.ConvK3(:,vv) = res.thoe{vv}.weight.ConvK3;
    thoe.r.PSK3(vv,:) = res.thoe{vv}.r.PSK3;
    thoe.r.bestPSK3(vv) = res.thoe{vv}.r.bestPSK3;
    thoe.weight.PSK3(:,vv) = res.thoe{vv}.weight.PSK3;
    thoe.r.AutoK2(vv,:) = res.thoe{vv}.r.AutoK2;
    thoe.r.bestAutoK2(vv) = res.thoe{vv}.r.bestAutoK2;
    thoe.weight.AutoK2(:,vv) = res.thoe{vv}.weight.AutoK2;
    thoe.r.HRCConvK3(vv) = res.thoe{vv}.r.HRCConvK3;
    thoe.weight.HRCConvK3(:,vv) =res.thoe{vv}.weight.HRCConvK3;
    thoe.r.HRCPSK3(vv) = res.thoe{vv}.r.HRCPSK3;
    thoe.weight.HRCPSK3(:,vv) = res.thoe{vv}.weight.HRCPSK3;
    thoe.r.HRCCP(vv) = res.thoe{vv}.r.HRCCP;
    thoe.weight.HRCCP(:,vv) = res.thoe{vv}.weight.HRCCP;
    thoe.mut.r(vv,:,:) = res.thoe{vv}.mut.r;
    thoe.mut.rROI(vv,:,:) = res.thoe{vv}.mut.rROI;
    
    vValue(vv) = res.exp{vv}.vreal;
end

% sor the theoretical one.
%%
if plotFlag
    % summarize the data and plot them accordingly
    
    strInfo.xlabel = 'velocity [degree/second]';
    strInfo.title = 'different velocity';
    % first, plot the thoeretical data.
    PlotXRThoe(thoe.r,thoe.mut,vValue,strInfo)
    % tempPlot(r,weight,vValue,strInfo);
    PlotXRW(exp.r,exp.weight,exp.mut,vValue,strInfo);
    % show the changing of r with v.
end
end
