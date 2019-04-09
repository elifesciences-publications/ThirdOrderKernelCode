function [res] =  AnaDataIndVelFullTemp(param,extOutFlag,p)
% there are many different analysis could be done, so do them one by one.
% calculate the correlation
% analyze the bad image, or what is the outlier
% analyze the result without outlier,
% too many things could be done within one thing.
% you can write separate function.

% load all the data,
% decide later what to do
D = MyLoadIndV(param);
% sort D !
D = MySortD(D);
nv = length(D);

% the res is a temporary to get value from function , no usage in the
% end...
res.exp = cell(nv,1);
res.theo = cell(nv,1);
res.v = cell(nv,1);
% the res.exp and res.theo should be the return value.
% this is the final result. for different velocity.
% they are infomation for real experimental one, exclude the HRC, and put
% the HRC into the theoretical workd.

for vv = 1:1:nv
    % first of all, load the data individually/
    v = D{vv}.v;
    stimc = D{vv}.stimc;
    imageID = D{vv}.imageID;
    % one more step, to exclude the image who are not very good.
    % alternatively, exclude the image who has strange values in it.
    
    
    %[v,stimc,imageID] = AnaDelData_Image(param,v,stimc,imageID);
    if extOutFlag
        [v,~,~]  = AnaDelData_Perc(p,v,stimc,imageID);
    end
   
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
    res.theo{vv} = AnalysizeCorrTheo(v.HRC,v.ConvK3,v.PSK3,v.AutoK2,v.real);
    res.exp{vv} = AnalysizeCorrSpearman(v.HRC,v.k2,v.k3,v.real);
    
    res.theo{vv}.vreal = abs(v.real(1));
    res.exp{vv}.vreal = abs(v.real(1));
    res.v{vv} = v;
end

end
