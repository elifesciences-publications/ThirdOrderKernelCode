function [xtPlot,params] = GetXtPlot(dataPath)
    
    if nargin<1
        dataPath = [];
    end

    sysConfig = GetSystemConfiguration();
    
    dataLocation = sysConfig.dataPath;

    if isempty(dataPath)
        dataPath = UiPickFiles('FilterSpec',dataLocation,'Prompt','Choose folders containing the files to be analyzed');
        if length(dataPath) > 1
            error('AnalyzeXtPlot can only handle one file at a time');
        end
        dataPath = dataPath{1};
    end
    
    if isempty(regexp(dataPath(1:3),'[A-z]\:\\|/[A-z]{2}','once'))
        dataPath = fullfile(dataLocation,dataPath);
    end
    
    xtPlot = csvread(fullfile(dataPath,'xtPlot.xtp'));
    params = load(fullfile(dataPath,'chosenparams.mat'));
    params = params.params;
end