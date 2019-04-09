function [newEpoch,CH,allStims,varargout] = StateMachine(allStims,currEpoch,locFrame, overallFrame)

% stupid statemachine. could have far more complicated conditions for
% changing state in here...

CH = (locFrame >= allStims(currEpoch).duration);

if ~CH || (length(allStims)==1)  % stay here
    newEpoch=currEpoch;
else    % move

    if isfield(allStims(currEpoch),'nextEpoch') && ~isempty(allStims(currEpoch).nextEpoch)  % move is dictated by next epoch, if that field exists
        if allStims(currEpoch).nextEpoch < currEpoch %If the next epoch takes you back, make sure you want to go back
            if isfield(allStims(currEpoch), 'repeats') && ~isempty(allStims(currEpoch).repeats) && allStims(currEpoch).ordertype == -1 %First check that there's a 'repeats' field in your current epoch
                % Set repeatsLeft field to keep track of how many fields
                % you have left, if it's not there.
                if ~isfield(allStims(currEpoch), 'repeatsLeft') || isempty(allStims(currEpoch).repeatsLeft)
                    allStims(currEpoch).repeatsLeft = allStims(currEpoch).repeats;
                end
                % Tick down repeatsLeft, tick to the nextEpoch, if there
                % are some repeatsLeft
                if allStims(currEpoch).repeatsLeft ~= 0
                    allStims(currEpoch).repeatsLeft = allStims(currEpoch).repeatsLeft-1;
                    newEpoch = allStims(currEpoch).nextEpoch;
                else
                    % If there are no repeatsLeft, (and we were going to a
                    % previous epoch, remember!) go the next epoch, which
                    % should break us out of the loop!
                    if currEpoch + 1 > length(allStims)
                        newEpoch = 1;
                    else
                        newEpoch = currEpoch+1;
                    end
                    % And reset to the start state, in case we loop back to
                    % here again
                    allStims(currEpoch).repeatsLeft = allStims(currEpoch).repeats;
                end
            else
                if allStims(currEpoch).nextEpoch == 1 && isfield(allStims, 'interEdit')
                    allStims(1).nextEpoch = floor((length(allStims)-1)*rand)+2;
                    allStims(1).flickerL = allStims(allStims(1).nextEpoch).interEdit;
                end
                newEpoch = allStims(currEpoch).nextEpoch;
            end
        else
            newEpoch = allStims(currEpoch).nextEpoch;
        end
    else
        
        % if ordering is specified -- 0 or 1 for random or sequential
        OT = 0;
        if isfield(allStims(currEpoch),'ordertype') && ~isempty(allStims(currEpoch).ordertype)
            OT = allStims(currEpoch).ordertype;
        end
        
        % If a probe has been presented, then the first epoch of the
        % stimulus is no longer epoch 1, it is now epoch length(probe)+1!!!
        % Probe presentation automatically assigns this epoch to
        % allStims(end).nextEpoch in uiLoadMultiFiles.m, and the if part of
        % this giant if statement takes care of not representing the probe.
        % However, we need to take care of not going back to the probe
        % here either!
        if isfield(allStims(currEpoch),'nextEpoch')
            firstStimEpoch = allStims(end).nextEpoch;
        else
            firstStimEpoch = 1;
        end
        
        switch OT
            case 0 % default, random interleave
                if (currEpoch ~= firstStimEpoch) % not at interleave, so go to interleave
                    newEpoch = firstStimEpoch;
                else     % at interleave, so go to random epoch
                    newEpoch = floor((length(allStims)-firstStimEpoch)*rand+1+firstStimEpoch);
                end
            case {1, -1} % sequential ordering; -1 is for probes
                newEpoch = currEpoch + 1;
                
                if newEpoch > length(allStims)
                    newEpoch = firstStimEpoch;
                end
            case 2 % Random, no interleve
                newEpoch = floor((length(allStims)-(firstStimEpoch-1))*rand)+firstStimEpoch;
            case 3 
                
                if (currEpoch ~= firstStimEpoch) % not at interleave, so go to interleave
                    newEpoch = firstStimEpoch;
                    allStims(firstStimEpoch).nextEpochOT3 = currEpoch + 1;
                else     % at interleave, so go to last epoch + 1
                    % The first time we get here, there may be no
                    % 'nextEpoch' field, at which point we just go to the
                    % epoch right after the interleave
                    if isfield(allStims(firstStimEpoch), 'nextEpochOT3') && ~isempty(allStims(firstStimEpoch).nextEpochOT3)
                        newEpoch = allStims(firstStimEpoch).nextEpochOT3;
                    else 
                        newEpoch = firstStimEpoch + 1;
                        % Set this up so that firstStimEpoch gets
                        % appropriately reset every time
                        allStims(end).nextEpoch = firstStimEpoch;
                    end
                    
                    if newEpoch == length(allStims)
                        allStims(firstStimEpoch).nextEpochOT3 = firstStimEpoch+1;
                    end
                end
            case 4
                if (currEpoch ~= firstStimEpoch) % not at interleave, so go to interleave
                    newEpoch = firstStimEpoch;
                else     % at interleave, so go to last epoch + 1
                    % In case we get here and some other function expects a
                    % well controlled random generator, we're going to
                    % store the random number generator's state and reset
                    % it once we've permuted
                    if isfield(allStims(firstStimEpoch), 'epochOrder') && ~isempty(allStims(firstStimEpoch).epochOrder)
                        newEpoch = allStims(firstStimEpoch).epochOrder(1);
                        allStims(firstStimEpoch).epochOrder(1) = [];
                    else 
                        s = rng;
                        repeatNums = [allStims(firstStimEpoch+1:end).repeats];
                        epochOrderVec = [];
                        for i = 1:length(repeatNums)
                            epochOrderVec = [epochOrderVec repmat(firstStimEpoch+i, [1, repeatNums(i)])];
                        end
                        
                        epochOrderRand = epochOrderVec(randperm(length(epochOrderVec) ));
                        
                        rng(s);
                        
                        allStims(firstStimEpoch).epochOrder = epochOrderRand(2:end);
                        newEpoch = epochOrderRand(1);
                        % Set this up so that firstStimEpoch gets
                        % appropriately reset every time
                        allStims(end).nextEpoch = firstStimEpoch;
                    end
                end
            case 5 % Randomly select next epoch out of epochs that have entryPoint set to 1
                % Randomly select epochs until we find one where entrypoint
                % is set to 1. 
                foundNext = 0;
                while foundNext == 0
                    newEpoch = floor((length(allStims)-(firstStimEpoch-1))*rand)+firstStimEpoch;
                    if allStims(newEpoch).entryPoint
                        foundNext = 1;
                    end
                end
        end
    end
    
    % I don't like this code... but for the moment it's what's being done
    % for repeating the probe stimulus >.>
    if isfield(allStims(1), 'repeatProbeDuration') && (allStims(1).totalTime - overallFrame) < allStims(1).repeatProbeDuration
        % We're assuming the probe starts at the start....
        newEpoch = 1;
        numProbeEpochs = length([allStims.repeatProbeRepeats]);
        newRepeatNums = [allStims.repeatProbeRepeats];
        newRepeatNums = num2cell(newRepeatNums);
        [allStims(1:numProbeEpochs).repeats] = deal(newRepeatNums{:});
        [allStims(1:numProbeEpochs).repeatsLeft] = deal(newRepeatNums{:});
        allStims = rmfield(allStims, 'repeatProbeDuration');
    end
    
end