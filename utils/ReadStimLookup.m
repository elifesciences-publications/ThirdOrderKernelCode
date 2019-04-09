function [fh_array,num] = ReadStimLookup(filename)

% [num,funcnames]=textread(filename,'%f,%s\n');
[num,funcnames]=textread(filename,'%f,%s%*[^\r\n]');

% if ~all(num==[1:length(num)]')
%     disp('error in the stimulus look up file numbering.');
%     return;
% end

% strlist = funcnames; % cell array of strings of function names

% this is an array of handles to all the functions listed. if too much
% overhead (i doubt it), this can be called only on the functions to be
% called (by looking at stims.params)
fh_array = cellfun(@str2func, funcnames, ...
                   'UniformOutput', false);
               
end