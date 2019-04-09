function [v,stimc,imageIDarray] = AnaDelData_Image(param,v,stimc,imageIDarray)
% I need the image outlier array once more, all the correspond value should
% be changed.
%
imageOutlier = param.imageOutlier;
imageOutlier = sort(imageOutlier);
nOut = length(imageOutlier);

for i = 1:1:nOut;
    % delete the data one by one....
    imageID = imageOutlier(i);
    indDel = imageIDarray == imageID;
    v.HRC(indDel) = [];
    v.k2(indDel) = [];
    v.k3(indDel) = [];
    v.real(indDel) = [];
    
    v.MC(indDel,:) = [];
    v.ConvK3(indDel,:) = [];
    v.PSK3(indDel,:) = [];
    v.AutoK2(indDel,:) = [];
    
    stimc.std(indDel) = [];
    stimc.max(indDel) = [];
    imageIDarray(indDel) = [];
    
end

end