function OpenParamFile(inputPath)
    paramPath = fileparts(which('RunStimulus'));
    
    if isempty(regexp(inputPath(1:3),'[A-z]\:\\','once'))
        inputPath = fullfile(paramPath,inputPath);
    end
    
    system(['explorer ' inputPath ' &']);
end