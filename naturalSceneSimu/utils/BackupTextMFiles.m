function BackupTextMFiles(Q)
    % function does two things: FIRST, in the data folder, it generates a text list of all files in
    % the home folder, util folder, stimfunctions folder, and paramfiles folder
    % it lists names, dates of all files, line by line
    % SECOND, it generates a zipped back up of all the *m files in the
    % main directory + util, stimfunctions, and paramfiles, and places it in the data folder

    % note, this should all be done through absolute paths, defined in the
    % paths structure in Q... do it!

    % keep the copy here un-zipped
    copyfile(Q.paths.chosenparameterfile,Q.paths.data);
    if isfield(Q.paths, 'probePath') && ~isempty(Q.paths.probePath)
        [~, probeStimFunction, fileEnd] = fileparts(Q.paths.probePath);
        copyfile(Q.paths.probePath, fullfile(Q.paths.data, ['probe_' probeStimFunction fileEnd]));
    end

    cd(Q.paths.home);
    dlow_m = dir('*.m');
    dutil = dir(Q.paths.utils);
    dstimfunctions = dir(Q.paths.stimfunctions);
    dparamfiles = dir(Q.paths.paramfiles);

    for ii=1:length(dlow_m)
        ziplist{ii} = dlow_m(ii).name;
    end
    ziplist{end+1} = Q.paths.utils;
    ziplist{end+1} = Q.paths.stimfunctions;
    ziplist{end+1} = Q.paths.paramfiles;


    zip([Q.paths.data '/filebackup.zip'],ziplist);

    f = fopen([Q.paths.data '/fileinfo.txt'],'w');
    fprintf(f,'***HOME FILES\n');
    for ii=1:length(dlow_m)
        fprintf(f,'%s, %s\n',dlow_m(ii).name,dlow_m(ii).date);
    end

    fprintf(f,'***UTILS FILES\n');
    for ii=1:length(dutil)
        if ~(dutil(ii).name(1)=='.')
            fprintf(f,'%s, %s\n',dutil(ii).name,dutil(ii).date);
        end
    end

    fprintf(f,'***STIMFUNCTIONS FILES\n');
    for ii=1:length(dstimfunctions)
        if ~(dstimfunctions(ii).name(1)=='.')
            fprintf(f,'%s, %s\n',dstimfunctions(ii).name,dstimfunctions(ii).date);
        end
    end

    fprintf(f,'***PARAMFILES FILES\n');
    for ii=1:length(dparamfiles)
        if ~(dparamfiles(ii).name(1)=='.')
            fprintf(f,'%s, %s\n',dparamfiles(ii).name,dparamfiles(ii).date);
        end
    end

    f = fclose(f);
end




