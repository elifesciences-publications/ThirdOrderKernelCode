function Histogram_Untils_SetBinWidthLimitsTheSame(h,varargin)
% Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);
normByProbabilityFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
binWidth = min(cellfun(@(x)x.BinWidth,h,'UniformOutput',true));
a = min(cellfun(@(x)x.BinLimits(1),h,'UniformOutput',true));
b = max(cellfun(@(x)x.BinLimits(2),h,'UniformOutput',true));
% cellfun(@(x) x.BinLimits = [a,b],h,);
% cellfun(@(x) x.BinWidth = binWidth,);
for ii = 1:1:length(h)
    h{ii}.BinLimits = [a,b];
    h{ii}.BinWidth = binWidth;
end
if normByProbabilityFlag
    %    cellfun(@(x)(x.Normalizatoin = 'probability'),h);
    for ii = 1:1:length(h)
        h{ii}.Normalization = 'probability';
    end
end
end
