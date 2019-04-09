function WriteStringsToFile(h,varargin)

% function writes a bunch of strings to the file. arbitrarily many, but all
% arguments after the handle must be strings... each gets own line

N = length(varargin);
for ii=1:N
    fprintf(h,'%s\n',varargin{ii});
end