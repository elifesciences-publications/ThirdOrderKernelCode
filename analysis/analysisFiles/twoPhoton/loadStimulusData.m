function stimulusData = loadStimulusData( Z )
%LOADSTIMULUSPARAMS takes care of loading the stimulus parameters into Z

try paramVar = load(fullfile(Z.params.pathName,'stimulusData','chosenparams.mat'), 'params');
catch err
    if strcmp(err.identifier, 'MATLAB:load:couldNotReadFile')
        try 
            [allStimulusBehaviorData] = grabStimulusData(Z);
            paramVar = load(fullfile(Z.params.pathName, 'stimulusData', 'chosenparams.mat'), 'params');
        catch err2
            if strcmp(err2.identifier, 'MATLAB:AddField:InvalidFieldName')
                paramVar = load('chosenparams.mat', 'params');
                cd(Z.params.pathName);
            else
                rethrow(err2)
            end
        end
    else
        rethrow(err)
    end
end

files = dir(fullfile(Z.params.pathName,'stimulusData'));
fileNames = {files.name};
probeFileInd = cellfun(@(ind) ~isempty(ind) && ind(1)==1,strfind(fileNames, 'probe_'));

if any(probeFileInd)
    stimulusData.probe = fileNames{probeFileInd}(7:end-4);
    stimulusData.probeParams = GetParamsFromPaths({fullfile(Z.params.pathName, 'stimulusData',fileNames{probeFileInd})});
else
    stimulusData.probe = false;
end

stimFunction = Z.params.name;
lastUnder = find(stimFunction=='_', 1,'last');
stimFunction = stimFunction(1:lastUnder-1);



stimulusData.params = paramVar.params;
stimulusData.stimParams = GetParamsFromPaths({fullfile(Z.params.pathName,'stimulusData',[stimFunction '.txt'])});
stimulusData.stimulusFunction  = stimFunction;
stimulusData.allStimulusBehaviorData = grabStimulusData(Z);



end

