function viewLocs = AlignmentAdjust(Q)

% to be called each loop, checks for keyboard inputs appropriately to move
% view locations around appropriately

%% this top line works on mac, bottom on PC
% [pressBOOL,dum,keyList]=PsychHID('KbCheck'); % check this once
[pressBOOL,dum,keyList]=KbCheck; % check this once

viewLocs = Q.OGL.viewLocs;

% % i think these are correct for MAC
% leftArrow = 80;
% rightArrow = 79;
% downArrow = 81;
% upArrow = 82;
% keyQ = 20;
% keyW = 26;
% keyS = 22;
% key1 = 30;
% key2 = 31;
% key3 = 32;

% i think these are correct for WIN7
leftArrow = 37;
rightArrow = 39;
downArrow = 40;
upArrow = 38;
keyQ = 81;
keyW = 87;
keyS = 83;
key1 = 49;
key2 = 50;
key3 = 51;
key4 = 52;

if ~pressBOOL
    return;
end

if keyList(keyS)
    % cd somewhere, then save this
    dlmwrite(Q.paths.viewlocsfile,viewLocs,',');
    disp('Saving viewlocs file! Strong work.');
    return
end

% which view?
viewChoose = 0;
if keyList(key1)
    viewChoose = 1;
end
if keyList(key2)
    viewChoose = 2;
end
if keyList(key3)
    viewChoose = 3;
end
if keyList(key4)
    viewChoose = 4;
end
if viewChoose == 0
    return
end;

% position or width?
movePos = [];
if keyList(keyQ)
    movePos = 1;
end
if keyList(keyW)
    movePos = 0;
end
if ~length(movePos)
    return
end

% move how?
moveHow = [];
if keyList(leftArrow)
    moveHow = [-1 0];
end
if keyList(rightArrow)
    moveHow = [1 0];
end
if keyList(upArrow)
    moveHow = [0 1];
end
if keyList(downArrow)
    moveHow = [0 -1];
end
if ~length(moveHow)
    return
end

% do the damn move
if movePos
    viewLocs(viewChoose,[1 2]) = viewLocs(viewChoose,[1 2]) + moveHow;
else
    viewLocs(viewChoose,[3 4]) = viewLocs(viewChoose,[3 4]) + moveHow;
end

