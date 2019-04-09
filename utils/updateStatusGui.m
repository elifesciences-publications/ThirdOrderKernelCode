function updateStatusGui(handles,frameNum,Nframes,currEpoch,showDX,showDY)
    handles.progressBar.Value = 1000*frameNum/Nframes;
    secondsRemaining = round((Nframes - frameNum)/60);
    secondsRemainingString = sprintf('%02d',mod(secondsRemaining,60));
    minutesRemainingString = sprintf('%02d',mod(floor(secondsRemaining/60),60));
    hoursRemainingString   = num2str(floor(secondsRemaining/(60*60)));
    timeRemainingString = [hoursRemainingString ':' minutesRemainingString ':' secondsRemainingString];
    progressString = [timeRemainingString  ' remaining in parameter file'];
    handles.progressBar.setString(progressString);

    if isnumeric(currEpoch)
        epochString = sprintf('Current Epoch Number: %d',currEpoch);
    else
        epochString = sprintf('Current Epoch: %s',currEpoch);
    end
    handles.currentEpochText.String = epochString;

    flyXString = sprintf('%-3s %-7d %-7d %-7d %-7d %-7d','X:',showDX);
    handles.flyXText.String = flyXString;
    flyYString = sprintf('%-3s %-7d %-7d %-7d %-7d %-7d','Y:',showDY);
    handles.flyYText.String = flyYString;
    if verLessThan('matlab','8.5')
        drawnow update
    else
        drawnow limitrate;
    end
end