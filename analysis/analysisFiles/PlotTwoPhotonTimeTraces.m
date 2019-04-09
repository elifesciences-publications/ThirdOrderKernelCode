 function analysis = PlotTwoPhotonTimeTraces(flyResp,epochs,params,~,dataRate, dataType, interleaveEpoch, varargin)
    epochToPlot = '';
    axesToPlotIn = [];
    
    
    % Gotta unwrap the eyes because of how they're put in here
%     params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    if any(cellfun('isempty', flyResp))
        nonResponsiveFlies = cellfun('isempty', flyResp);
        fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
        flyResp(nonResponsiveFlies) = [];
        epochs(nonResponsiveFlies) = [];
    else
        nonResponsiveFlies = [];
    end
    
    numFlies = length(flyResp);
    flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);
    
    MakeFigure;
    % run the algorithm for each fly
    for ff = 1:numFlies
        PlotROITraces( flyResp{ff}, params{ff}, epochs{ff}(:, 1), epochToPlot, axesToPlotIn, dataRate)
        b = axis;
        text((b(2)+b(1))/2, (b(3)+b(4))/2, flyEyes{ff});
    end
    analysis = [];
end