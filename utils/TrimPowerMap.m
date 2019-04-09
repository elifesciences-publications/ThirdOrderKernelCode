function outMap = TrimPowerMap(varargin)
    outMap = cell(nargin,1);

    for ii = 1:length(varargin);
        outMap{ii}.resp = varargin{ii}.analysis{1}.p8_respMat.respMatPlot;
        outMap{ii}.respSem = varargin{ii}.analysis{1}.p8_respMat.respMatSemPlot;
        outMap{ii}.respInd = varargin{ii}.analysis{1}.p9_respMatInd.respMatIndPlot;
    end
end