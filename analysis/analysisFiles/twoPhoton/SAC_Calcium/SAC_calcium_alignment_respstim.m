function [stim_indexes, f_resp] = SAC_Timealign_resp2stimindex(resptime, stimtime)
    n_T = length(resptime);
    stim_indexes = zeros(n_T, 1);
    time_p = 1;
    for ii = 1:1:n_T
        t = resptime(ii);
        while(stimtime(time_p) < t)
            time_p = time_p + 1;
        end
        stim_indexes(ii) = time_p-1;
    end
    f_resp = 1/(mean(diff(resptime(:, 1))));

end