function screen = UiChooseScreen

    % function asks which screen to use...
    % 0 is main screen, 1 is DLPs (also default)

    answer = questdlg('Select display','Which screen do you want to use?','Main','DLPs','Main');

    if isequal(answer,'')
        error('Run cancled by user');
    end
    
    screen = isequal(answer,'DLPs');
end
