function Analysis_Function_ErrorReport(filepath, err)
    % in the saved analysis, these is an error log.
    S = GetSystemConfiguration;
    twoPhotonDataPathLocal = S.twoPhotonDataPathLocal;
    
    % get into the folder. 
    err_log_file = [filepath,'/savedAnalysis/err_log_Juyue.mat'];
    save(err_log_file,'err');
end