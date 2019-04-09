function bckgkernel = filterRoiTraces_Utils_GetBackgroundKernel(filename)

pathname = [filename,'/','savedAnalysis/'];
% you should put data after that.
filename = dir([pathname,'bckgKernel*.mat']);
load([pathname,'/',filename(end).name]);
if ~exist('bckgkernel','var')
    error('no background kernel!')
end
end