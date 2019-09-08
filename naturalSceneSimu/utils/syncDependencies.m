function syncDependencies( targetScript, localDepDir, netID )
% Finds all the dependencies of a function or script, copies them into a
% folder, uploads them to the server
%   Arguments:
%       targetScript: a string giving the name of the function or script
%           whose dependencies you are uploading (include '.m')
%       localDepDir: address of the local directory where you would like to
%           create the dependencies folder
%       netID: user's netID, eg. ces32
      
    targetScriptName = targetScript(1:end-2);
    fullDepDir = [localDepDir '/dependencies'];
    
    %% Find dependencies
    % Clear any previous dependencies in the target folder
    if isdir(fullDepDir)
        reallyDelete = input(['Are you sure you would like to clear the ' ...
            'preexisting\ndependencies folder at this location? (1/0)    ']);
        if reallyDelete
            allFiles = dirrec(fullDepDir);
            for q = 1:length(allFiles)
                delete(allFiles{q})
            end
        else
            error('Aborting: pick a new dependencies location.');
        end
    else
        mkdir(fullDepDir);
    end
    % Find all dependent scripts
    [fList,pList] = matlab.codetools.requiredFilesAndProducts(targetScript);
    % Flag mex files to be compiled on server
    endStringLen = length(computer); % the length of the file extension for 
                                     % this type of computer, eg. "maci64"
                                     % for mac, "wi64" for windows. 
    isMex = zeros(1,length(fList));
    for q = 1:length(fList)
        if strcmp(fList{q}(end-(endStringLen+2):end-endStringLen),'mex') 
            % flag that this is a mex file
            isMex(q) = 1;
            % upload the uncompiled version insted
            fList{q}(end-8:end) = [];
            fList{q} = cat(2,fList{q},'cpp');
        end
    end

    % % % COMPILE MEX FILES!!
    
    %% Move all dependent scripts into dependencies folder    
    % Copy all dependencies into this folder
    for q = 1:length(fList)
        copyfile(fList{q},fullDepDir)
    end
    
    %% Upload
    system(['rsync -avz ' localDepDir '/dependencies ' netID '@omega.hpc.yale.edu:' targetScriptName '/']);

end

