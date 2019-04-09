function ShutdownStimulus(Q)
    %% close the handles

    t=GetSecs()-Q.timing.t0;
    fprintf(Q.handles.metadata,'*********\n');
    fprintf(Q.handles.metadata,'%10.3f CLOSE DOWN\n',t);

    % close all the file handles
    fclose(Q.handles.metadata);
    fclose(Q.handles.stimdata);
    fclose(Q.handles.respdata);


    if Q.stims.xtPlot
        fclose(Q.handles.xtPlot);
    end

    if Q.stims.movie
        close(Q.handles.movie);
    end
    
    if Q.readMouse
        % tell the arduino to stop reading the mice
        IOPort('Write',Q.handles.arduino,'b');
        IOPort('Purge',Q.handles.arduino);
        IOPort('close',Q.handles.arduino);
    end

    % close the PTB screens
    Screen('closeall');
    
    if isfield(Q,'lightCrafter4500')
        Q.lightCrafter4500.standby()
    end

    if ~Q.stims.test && ~Q.stims.xtPlot && ~Q.stims.movie
        WriteAutoLog(Q);
        fclose(Q.handles.autoLog);
        fclose(Q.handles.allLog);
    end
    
    %% save stim and resp data as mat files
    respPath = fullfile(Q.paths.data,'respdata.csv');
    respData = csvread(respPath);
    respSaveTo = fullfile(fileparts(respPath),'respdata.mat');
    respNameChange = fullfile(fileparts(respPath),'textRespData.csv');
    save(respSaveTo,'respData');
    movefile(respPath,respNameChange)

    stimPath = fullfile(Q.paths.data,'stimdata.csv');
    stimData = csvread(stimPath, 1, 0);
    stimSaveTo = fullfile(fileparts(stimPath),'stimdata.mat');
    stimNameChange = fullfile(fileparts(stimPath),'textStimData.csv');
    save(stimSaveTo,'stimData');
    movefile(stimPath,stimNameChange)
	
	if Q.automateRecording
        % Stop recording
        
        h = actxserver('WScript.Shell');
        if ~h.AppActivate('clampex');
            msgbox('Could not connect to Clampex.\nRecording may not have completed.\nPlease ensure recording is stopped, then press OK', 'Error','error');
        else
            h.AppActivate('clampex');
            h.SendKeys('{ESC}');
        end
        
        % Copy data into data folder
        
        d = dir(fullfile(Q.paths.clampexData,'*.abf'));
        % Sort by creation date
        [~,sortedIndexes] = sort([d.datenum]);
        newestFile = d(sortedIndexes(end)).name;
        newestFileFullPath = fullfile(Q.paths.clampexData,newestFile);
        % Wait for file to be written to disk
        for j = 1:200
            fid = fopen(newestFileFullPath);
            if fid ~= -1
                break
            end
        end
        if fid ~= -1
            fclose(fid);
        else
            msgbox('ABF file may not have finished writing.\nMake sure the writing is done and then press OK', 'Error','error');
        end
        pause(1);
        copyfile(newestFileFullPath,fullfile(Q.paths.data,newestFile));
    end
end
