function  stim_binned = SAC_Temp_BinStimulus(stim, size_each_bin)
switch size_each_bin
    case 2
        stim_binned = zeros(size(stim, 1), 5);
        for ii = 1:1:5
            stim_binned(:, ii) = sum(stim(:,(ii - 1) * size_each_bin + 1 : ii * size_each_bin),2 );
        end
        
    case 3
        stim_binned = zeros(size(stim, 1), 3);
        stim = stim(:,2:10); % ignore the first column.
        for ii = 1:1:3
            stim_binned(:, ii) = sum(stim(:,(ii - 1) * size_each_bin + 1 : ii * size_each_bin),2 );
        end
end

