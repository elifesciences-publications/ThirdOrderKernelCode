function W = runAnalysisTestData( epoch,turn,walk,params,varargin)
% Generates and saves a folder resembling the masterWrapper output to
% validate the run analysis software.
%
%   Inputs:
%       Epoch: a 72001x1 vector of numbers specifying the epoch to which
%           each turning and walking trace belongs
%       Turn, Walk:
%           72001x5 vectors of responses
%       Params:
%           structure array of dim nEpochs x 1 including any params that
%           might be necessary to run the analysis you want to test.
%           Minimum to include are stimtype, duration, and framesPerUp.

    %% Name destination for output

    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    dataFolder = C{1}{1};
    manualName = 'standard';
    otherStimData = zeros(72001,20); % rewrite this with a varargin if you 
                                     % like to print other variables in
                                     % otherStimData.
    
    if ~exist(params,'var')
        nEpochs = max(epoch);
        for q = 1:nEpochs
            params(q).stimtype = 1;
            params(q).duration = 30;
            params(q).fpu = 6;
        end
    end

    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    fullFilePath = sprintf('%s/testData/%s',dataFolder,manualName);
    if ~isdir(fullFilePath)
        mkdir(fullFilePath);              
    end 

    fullRespName = sprintf('%s/respdata.csv',fullFilePath);
    fullStimName = sprintf('%s/stimdata.csv',fullFilePath);
    fullParamsName = sprintf('%s/chosenparams.mat',fullFilePath);

    %% Set up respData

    frameAxis = [1:1:72001]';
    timeAxis = linspace(.271,1200.886,72001)';
    mouseReads = [ 6 repmat([7 6],[1 72000/2]) ]';

    % 3-7 turning, 8-12 walking, 18 mouse reads
    respDataMat = zeros(72001,18);
    respDataMat(:,1) = timeAxis;
    respDataMat(:,2) = frameAxis;
    respDataMat(:,3:7) = turn;
    respDataMat(:,8:12) = walk;
    respDataMat(:,18) = mouseReads;

    %% Set up stimData

    stimDataMat = zeros(72001,18);
    stimDataMat(:,1) = timeAxis;
    stimDataMat(:,2) = frameAxis;
    stimDataMat(:,3) = epoch;
    stimData(:,4:23) = otherStimData;

    %% Save

    xlswrite(fullRespName,respDataMat);
    xlswrite(fullStimName,stimDataMat);
    save(fullParamsName,'params');

    %% Output

    W.respData = respDataMat;
    W.stimData = stimDataMat;
    W.params = params;

end

