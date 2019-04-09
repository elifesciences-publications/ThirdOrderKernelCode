function totalChars = PrintStatus(frameNum,Nframes,currEpoch,showDX,showDY,deletePrevious)

    frameString = sprintf('%-43s',['On frame ' num2str(frameNum) ' of ' num2str(Nframes)]);
    
    progressFraction = frameNum/Nframes;
    progressFilled = round(40*progressFraction);
    progressUnfilled = 40 - progressFilled;
    progressString = sprintf('%-43s',['[' repmat('=',[1 progressFilled]) repmat(' ',[1 progressUnfilled]) ']']);
    
    secondsRemaining = round((Nframes - frameNum)/60);
    secondsRemainingString = sprintf('%02d',mod(secondsRemaining,60));
    minutesRemainingString = sprintf('%02d',mod(floor(secondsRemaining/60),60));
    hoursRemainingString   = num2str(floor(secondsRemaining/(60*60)));
    timeRemainingString = [hoursRemainingString ':' minutesRemainingString ':' secondsRemainingString];
    timeString = sprintf('%-43s',[timeRemainingString  ' remaining in parameter file']);
    
    if isnumeric(currEpoch)
        epochString = sprintf('Current Epoch Number: %d',currEpoch);
    else
        epochString = sprintf('Current Epoch: %s',currEpoch);
    end
    currEpochString = sprintf('%-80s',epochString);
    
    flyLabelString = sprintf('%-3s %-7s %-7s %-7s %-7s %-7s','','Fly 1','Fly 2','Fly 3','Fly 4','Fly 5');
    flyXString = sprintf('%-3s %-7d %-7d %-7d %-7d %-7d','X:',showDX);
    flyYString = sprintf('%-3s %-7d %-7d %-7d %-7d %-7d','Y:',showDY);

    charsPerLine = 43;
    numLines = 7;
    numNewlines = 8;
    currEpochStringOverrun = 80 - 43;
    totalChars = charsPerLine*numLines + numNewlines + currEpochStringOverrun;
    deleteStr = repmat('\b',[1 totalChars]);
    if  ~deletePrevious
        deleteStr = '';
    end
    fprintf(1,[deleteStr '%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n'],frameString,progressString,timeString,currEpochString,flyLabelString,flyXString,flyYString);
    
end