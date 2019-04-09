function [genotype] = UiGetGenotypeCorrection

    formats = {};

    prompts(1, :) = {sprintf('Enter the correct genotype'), 'genotype', []};
    formats(1,1).type = 'edit';
    formats(1,1).format = 'text';
    formats(1,1).labelloc = 'topleft';
    defAns.genotype = '';


    dialogTitle = 'Genotype Correction';

    % numLines = [1 80; 1 40; 1 40; 1 80; 1 40; 1 40; 5 80];
    % answer = inputdlg(prompts, 'Fly database input',numLines);

    options.Interpreter = 'none';
    options.CancelButton = 'off';
    options.ButtonNames = {'Submit'};

    [userIn,Cancelled] = InputsDlg(prompts,dialogTitle,formats,defAns,options);

    genotype = userIn.genotype;

end