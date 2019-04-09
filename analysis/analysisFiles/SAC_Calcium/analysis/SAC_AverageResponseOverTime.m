function [resp_ind_cell] = SAC_AverageResponseOverTime(resp, on_set, off_set)
%% you might have different onset and offset for different epoches..
n_cell = length(resp);
resp_ind_cell = cell(n_cell, 1);

if (length(on_set) == 1 && length(off_set) == 1)
    % all the epoches use the same length.
    for nn = 1:1:n_cell
        resp_ind_cell{nn} = mean(resp{nn}(on_set:off_set,:,:,:), 1);
    end
else
    % different epoches are integrated differently.
    % check whether the epoch is
    
    n_epoch = length(resp{1}(1,1,:,1));
    if (length(on_set) ~= n_epoch)
        error('The number of on_set is different from the number of epoches');
    end
    for nn = 1:1:n_cell
        for ee = 1:1:n_epoch
            resp_ind_cell{nn}(1,:,ee,:,:) = mean(resp{nn}(on_set(ee):off_set(ee),:,ee,:), 1);
        end
    end
    
end
end