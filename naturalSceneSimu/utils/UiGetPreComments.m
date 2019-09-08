function [genostr,condstr,sameFly] = UiGetPreComments

    formats = {};

    prompts(1, :) = {sprintf('Enter genotype info'), 'genostr', []};
    formats(1,1).type = 'edit';
    formats(1,1).format = 'text';
    formats(1,1).labelloc = 'topleft';

    prompts(2, :) = { 'Enter special conditions', 'condstr', []};
    formats(2,1).type = 'edit';
    formats(2,1).format = 'text';
    formats(2,1).labelloc = 'topleft';

    prompts(3, :) = { 'same fly', 'sameFly', []};
    formats(3,1).type = 'check';
    formats(3,1).format = '';
    formats(3,1).style = 'checkbox';
    formats(3,1).items = [0 1];
    formats(3,1).labelloc = 'topleft';

    dialogTitle = 'enter run info';

    % numLines = [1 80; 1 40; 1 40; 1 80; 1 40; 1 40; 5 80];
    % answer = inputdlg(prompts, 'Fly database input',numLines);

    options.Interpreter = 'none';
    options.CancelButton = 'off';
    options.ButtonNames = {'Submit'};

    [userIn,Cancelled] = InputsDlg(prompts,dialogTitle,formats,[],options);

    genostr = userIn.genostr;
    condstr = userIn.condstr;
    sameFly = userIn.sameFly;

end