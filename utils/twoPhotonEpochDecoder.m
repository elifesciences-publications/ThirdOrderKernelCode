function [epoch_number, epoch_boundary_inds] = twoPhotonEpochDecoder(roi_clean_data, epoch_code_starts, epoch_code_ends, flash_length)

epoch_code_lengths = epoch_code_ends-epoch_code_starts+1;
epoch_number = zeros(length(epoch_code_lengths)-1,1);
epoch_boundary_inds = zeros(length(epoch_code_lengths)-1,2);

% The minus one is in here because the last epoch doesn't complete (this is
% still the case for the new method of ending runs with 20 flashes because
% this last epoch *also* doesn't complete (technically))
for i = 1:length(epoch_code_lengths)-1
    code_length = epoch_code_lengths(i);
    epoch_start = epoch_code_starts(i)-1;
    %We subtract one because the epoch ends right *before* the next one
    %starts
%     if i == length(epoch_code_lengths);
%         epoch_end = length(roi_clean_data)-1;
%     else
        epoch_end = epoch_code_starts(i+1)-1;
%     end
    %Though flash_lengths may change, code_length in general should be
    %small enough that the rounded value will indicate the number of frames
    bins = round(code_length/flash_length);
    bin = 1;
    
    %We still want to split it as evenly as possible along said number of
    %frames, so we're redividing and rounding (I'm actually not sure if
    %this will ever come up with a different number...)
    frame_length = round(code_length/bins);
    code = '';
    
    while bin <= bins
        inds = epoch_start+frame_length*(bin-1):epoch_start+frame_length*bin;
        diffIntensity = (roi_clean_data(inds(2))-roi_clean_data(inds(1)))/2;
        meanIntensity = mean(roi_clean_data(inds));
        if meanIntensity >= 0.5 && diffIntensity >= 0;
            code = [code '1'];
        else
            code = [code '0'];
        end
        bin = bin+1;
    end
    %Ignore the first two and the last one (they're part of the boundary
    %for encoding the code)
    if length(code)>54
        % Something's gone wrong if we're in here, but at least we can
        % prevent an error with bin2dec!
        warning('Something went wrong and you got a really long epoch code during a presentation!!');
        code = code(1:54);
    elseif length(code)<3
        warning('Something went wrong and you got a really short epoch code during a presentation!!');
        continue
    end
    epoch_number(i) = bin2dec(code(2:end-1));
    epoch_boundary_inds(i, :) = [epoch_start epoch_end];
end
        