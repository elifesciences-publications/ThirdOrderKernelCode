function WriteAutoLog(Q)

autoLog = Q.handles.autoLog;
allLog = Q.handles.allLog;
genotype = Q.genotype;
condstr = Q.condstr;
if isfield(Q,'runNumber')
    runNumber = Q.runNumber;
else
    runNumber = 0;
end
currTime = Q.currTime;
numEpochs = size(Q.stims.params,2);
paramPath = Q.paths.chosenparameterfile;
paramFilename = Q.paramFilename;
% dataPath = Q.paths.data;

paramNameStart = regexp(paramPath,'paramfiles\');
generalParamPath = paramPath(paramNameStart:end);
generalDataPath = fullfile(genotype,paramFilename,currTime);

%% print to autolog
fprintf(autoLog,'%s\n',['%% ' genotype '\' paramFilename]);
fprintf(autoLog,'%s\n',['OpenParamFile(''' generalParamPath ''');']);
fprintf(autoLog,'%s\n\n','% description: ');

fprintf(autoLog,'%s\n',['% ' currTime]);
fprintf(autoLog,'%s\n',['OpenDataFolder(''' generalDataPath ''');']);
fprintf(autoLog,'%s\n',['% Rig name: ' Q.rigName ', Run number: ' runNumber ', comments: ' condstr]);
fprintf(autoLog,'%s\n\n',['D=RunAnalysis(''analysisFile'',{''CombAndSep''},''dataPath'',''' generalDataPath ''',''tickX'',1:' num2str(numEpochs-1) ',''tickLabelX'',[1:' num2str(numEpochs-1) '],''labelX'','''',''fTitle'','''',''combOpp'',0);']);

%% print to alllog
fprintf(allLog,'%s\n',['%% ' genotype '\' paramFilename]);
fprintf(allLog,'%s\n',['OpenParamFile(''' generalParamPath ''');']);
fprintf(allLog,'%s\n\n','% description: ');

fprintf(allLog,'%s\n',['% ' currTime]);
fprintf(allLog,'%s\n',['OpenDataFolder(''' generalDataPath ''');']);
fprintf(allLog,'%s\n',['% Rig name: ' Q.rigName ', Run number: ' runNumber ', comments: ' condstr]);
fprintf(allLog,'%s\n\n',['D=RunAnalysis(''analysisFile'',{''CombAndSep''},''dataPath'',''' generalDataPath ''',''tickX'',1:' num2str(numEpochs-1) ',''tickLabelX'',[1:' num2str(numEpochs-1) '],''labelX'','''',''fTitle'','''',''combOpp'',0);']);

end