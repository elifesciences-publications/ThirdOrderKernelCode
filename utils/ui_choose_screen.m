function [screen,SCREENCHOOSE] = ui_choose_screen

    % function asks which screen to use...
    % 0 is main screen, 1 is DLPs (also default)
    % second option out is the number of x pixels on the main screen, which can
    % be used to shift to everything to the DLPs

answer = questdlg('Select display','Which screen do you want to use?','Main','DLPs','DLPs');

screen = strcmp(answer, 'DLPs');


    SCREENCHOOSE = screen+1;
end
