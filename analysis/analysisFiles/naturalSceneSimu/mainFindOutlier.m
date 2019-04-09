% find Outlier and put them into a file.
% function [imageOutlier] = mainFindOutlier(desInfo,mode,plotFlag,a)
% 
%   for ii = 1:2:length(varargin)
%         eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
%     end
%     
%     if ~exist('analysisFile','var')
%         root_folder = fileparts(which('master_stimulus'));
%         
%         [analysisFile,~] = uigetfile(fullfile(root_folder,'analysis','analysisFiles'),'Select analysis file');
%     
%         if analysisFile == 0;
%             cerror('no analysis file chosen');
%         end
%         
%         analysisFile = analysisFile(1:end-2);
%     end
%     
    
load('descriptive data.mat');
a = 2.5; 
plotFlag = 0;
% mode = 1;
% indOutlier.g = DesSummary(desInfo,mode,plotFlag,a);
% mode = 2;
% indOutlier.r = DesSummary(desInfo,mode,plotFlag,a);
imageOutlier = DesSummary(desInfo,mode,plotFlag,a);

% what is the 