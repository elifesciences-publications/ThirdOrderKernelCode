function [lastRoi, forceRois] = LoadLastSavedRoiFile(dataPath, varargin)


unChangeableVarargin = {'dataPath'};

for ii = 1:2:length(varargin)
    if any(strcmp(unChangeableVarargin,    varargin{ii}))
        continue
    else
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
end

savedAnalysisPath = fullfile(dataPath,'savedAnalysis');
savedAnalyses = dir(savedAnalysisPath);
savedAnalysesNames = {savedAnalyses(3:end).name};
savedAnalysesNames(strcmp(savedAnalysesNames, 'lastRoi.mat'))=[];
savedAnalysesNames(cellfun('isempty',strfind(savedAnalysesNames, roiExtractionFile)))=[];

if ~isempty(savedAnalysesNames)
    for analysesNameInds = length(savedAnalysesNames):-1:1
        % so it works with a badly named extraction function:
%         if strcmp(roiExtractionFile, 'watershedRoiExtraction_v2')
%             [~, newestInd] = max(cellfun(@(fname) datenum(fname(regexp(fname, '_\d+_\d+_\d+', 'start'):regexp(fname, '_\d+_\d+_\d+', 'end')), '_dd_mm_yy'),savedAnalysesNames));
%         else
            [~, newestInd] = max(cellfun(@(fname) datenum(fname(regexp(fname, '\d+_\d+_\d+.mat', 'start'):regexp(fname, '\d+_\d+_\d+.mat', 'end')), 'dd_mm_yy'),savedAnalysesNames));
%         end
        %                 [~, sortedInds] = sort(cellfun(@(fname) datenum(fname(regexp(fname, '\d+_\d+_\d+', 'start'):regexp(fname, '\d+_\d+_\d+', 'end')), 'dd_mm_yy'),savedAnalysesNames));
        %                 newestInd = sortedInds(end-1);
        lastRoiFilename = savedAnalysesNames{newestInd};
        savedAnalysesNames(newestInd) = [];
        
        lastRoiPath = fullfile(dataPath,'savedAnalysis',lastRoiFilename);
        
        lastRoi = load(lastRoiPath);
        lastRoi = lastRoi.lastRoi;
        
        % check that the epochs were selecting and the roi
        % extraction file is the same
        if isequal(lastRoi.roiExtractFile,roiExtractionFile) && isfield(lastRoi, 'timeByRoisInitial')
            if isfield(lastRoi, 'extraVars')
                extraVars = lastRoi.extraVars;
                importantVars = fields(extraVars);
                goodFile = true;
                for i = 1:length(importantVars)
                    if isequal(importantVars{i}, 'defaults')
                        continue
                    end
                    if ~exist(importantVars{i}, 'var')
                        % On occasion, the roiExtractionFunction will save
                        % extraVars that you don't define in the call to
                        % RunAnalysis, because the defaults work--this is a
                        % way to check if the used value is the default
                        % value; if it is, then the check for this saved
                        % ROI file passes for this variable. If not, we
                        % break.
                        if isfield(extraVars, 'defaults') && isfield(extraVars.defaults, importantVars{i})
                            if isequal(extraVars.defaults.(importantVars{i}), extraVars.(importantVars{i}))
                                goodFile = true;
                            else
                                goodFile = false;
                                warning('The stored value the variable %s neither got defined in your RunAnalysis call nor did it match the default value from the roiExtractionFunction', importantVars{i});
                                break;
                            end
                        else
                            warning('The stored value the variable %s neither got defined in your RunAnalysis call nor was a default value against which to compare it stored.', importantVars{i});
                            goodFile = false;
                            break;
                        end
                    else
                        if isequal(eval(importantVars{i}), extraVars.(importantVars{i})) || isequal(size(eval(importantVars{i})), size(extraVars.(importantVars{i}))) && all(strcmpi(eval(importantVars{i}), extraVars.(importantVars{i})))
                            goodFile = true;
                        else
                            goodFile = false;
                            break;
                        end
                    end
                end
            else
                goodFile = true;
            end
            if goodFile
                forceRois = false;
                break;
                
            else
                forceRois = true;
                lastRoi = [];
                continue
            end
        else
            forceRois = true;
            lastRoi = [];
            continue
        end
    end
else
    forceRois = true;
    lastRoi = [];
end