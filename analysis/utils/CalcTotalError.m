function totalError = CalcTotalError(varargin)
    totalError = zeros(nargin,2);

    for vv = 1:nargin
        totalError(vv,:) = mean(varargin{vv}.respSem*sqrt(size(varargin{vv}.respInd,2)),1);
    end
end