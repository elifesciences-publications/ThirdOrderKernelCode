function [timeByRois,roiMask,outVars] = PixelRoiExtraction(movieIn,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
%     std = 2;
%     numStd = 3;
% 
%     x = -numStd*std:numStd*std;
%     y = (-numStd*std:numStd*std)';
%     t = permute(-numStd*std:numStd*std,[1 3 2]);
%     
%     filtX = normpdf(x,0,std);
%     filtY = normpdf(y,0,std);
%     spatialFilter = filtY*filtX;
%     
%     deltaFOverFFiltered = imfilter(deltaFOverF,spatialFilter,'symmetric');
    
    outVars = [];
    movieSize = size(deltaFOverF);
    timeByRois=reshape(deltaFOverF,[movieSize(1)*movieSize(2) movieSize(3)])';
    roiMask = reshape((1:movieSize(1)*movieSize(2))',[movieSize(1),movieSize(2)]);
end