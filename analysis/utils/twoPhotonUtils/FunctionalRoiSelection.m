function mask = FunctionalRoiSelection(responses,selection)
    % get epoch index from selection here
    mask = responses(:,:,selection(1)) - responses(:,:,selection(2));
    
    mask = mask/sum(sum(mask));
end