function [pmtVoltage] = UiGetVoltageCorrection

    formats = {};

    prompts(1, :) = {sprintf('Enter correct PMT voltage. If a PMT is unused, please leave it blank.'), '', []};
    formats(1,1).type = 'text';
%     defAns.pmtVoltage = '-';
    
    prompts(2, :) = {sprintf('PMT A:'), 'pmtAVoltage', []};
    formats(2,1).type = 'edit';
    formats(2,1).format = 'text';
    formats(2,1).labelloc = 'topleft';
    defAns.pmtAVoltage = '-';

    prompts(3, :) = {sprintf('PMT B:'), 'pmtBVoltage', []};
    formats(3,1).type = 'edit';
    formats(3,1).format = 'text';
    formats(3,1).labelloc = 'topleft';
    defAns.pmtBVoltage = '-';
    
    dialogTitle = 'PMT Voltage Correction';

    % numLines = [1 80; 1 40; 1 40; 1 80; 1 40; 1 40; 5 80];
    % answer = inputdlg(prompts, 'Fly database input',numLines);

    options.Interpreter = 'none';
    options.CancelButton = 'off';
    options.ButtonNames = {'Submit'};

    [userIn,Cancelled] = InputsDlg(prompts,dialogTitle,formats,defAns,options);
    pmtAVoltage = userIn.pmtAVoltage;
    pmtBVoltage = userIn.pmtBVoltage;
    pmtVoltage = {pmtAVoltage, pmtBVoltage};
    % This is a quick way to get rid of ignored fields that just have '-'
    % or empty in them
    pmtVoltage = cellfun(@(pmtVol) num2str(str2num(pmtVol)), pmtVoltage, 'UniformOutput',  false);

end