function saveOrAppendMatFile(file, saveVariables) %#ok<INUSD>
%SAVEORAPPENDMATFILE This function takes care of determining whether you
%should save a new mat file or append to an existing one
%   saveOrAppendMatFile(file, saveVariables) save the variables in the
%   structure 'saveVariables' into the provided file 'file'. It checks whether
%   the file already exists at which point it appends to it. If the file
%   does not exist, it saves a new one. The 'saveVariables' structure
%   should be defined such that the field names are the names of the
%   variables to be saved and the field values are the values of the
%   variables
%
%   % Example:
%   %  Save a workspace variable 'numElements' into mat file 'numbers.mat'
%
%   matFile = 'numbers.mat';
%   numElements = 13;
%   saveVariables.numElements = numElements;
%   saveOrAppendMatFile(matFile, saveVariables);
%
%   % Adding another variable with a different name later will not
%   % overwrite the original numElements variable saved in matFile

try
    save(file, '-struct', 'saveVariables', '-append');
catch err
    if strcmp(err.identifier, 'MATLAB:save:couldNotWriteFile')
        try 
            save(file, '-struct', 'saveVariables', '-v7.3');
        catch err2
            if strcmp(err.identifier, 'MATLAB:save:couldNotWriteFile')
                warning('Variables not being saved, potentially because your hard drive is improperly formatted for the system to write to it. Below is the actual error');
                warning(err.message);
                return;
            end
        end
    else
        rethrow(err);
    end
end