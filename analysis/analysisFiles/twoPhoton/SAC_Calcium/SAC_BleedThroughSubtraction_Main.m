function movie_bckg_subtracted = SAC_BleedThroughSubtraction_Main(respfolder, stimtime_file)
test_flag = 1;

%% estimate bleedthrough
% first, get the stimulus seq and timing, as well as resptime.
stimseq = SAC_Load_StimSeq(stimtime_file);
stimtime = SAC_Load_Stimtime(stimtime_file);
resptime = SAC_Load_RespTime();

% second,, get the bleedthrough kernel.
data_info = dir(fullfile(respfolder,'oim*.mat'));
n_data = length(data_info);
first_kernel = cell(n_data, 1);
for tt = 1:1:n_data
    file = fullfile(respfolder, data_info(tt).name);
    [~, raw_movie] = SAC_utils_load_raw_movie(file);
    
    first_kernel{tt} = SAC_BleedthroughSubtraction_Utils_EstimateKernel(raw_movie, resptime(:,1), stimseq(:,:,tt), stimtime(:,tt));
end

bleedthrough_kernel = mean(cat(3,first_kernel{:}), 3);

%% subtract out bleedthrough movie. load the fullmovie... file by file? no...
movie_bckg_subtracted = cell(n_data, 1);
if test_flag
    first_kernel_after_subtraction = cell(n_data, 1);
end
for tt = 1:1:n_data
    file = fullfile(respfolder, data_info(tt).name);
    [~, raw_movie] = SAC_utils_load_raw_movie(file);
    movie_bckg_subtracted{tt} = SAC_BleedthroughSubtraction_Utils_Subtraction(raw_movie, resptime(:,1), stimseq(:,:,tt), stimtime(:,tt), bleedthrough_kernel);
    
    if test_flag
        first_kernel_after_subtraction{tt} = SAC_BleedthroughSubtraction_Utils_EstimateKernel...
            (movie_bckg_subtracted{tt}, resptime(:,1), stimseq(:,:,tt), stimtime(:,tt));
    end
end
if test_flag
    bleedthrough_kernel_after_subtraction = mean(cat(3,first_kernel_after_subtraction{:}), 3);
    
    MakeFigure; 
    subplot(2,1,1);quickViewOneKernel(bleedthrough_kernel, 1); title('bleedthrough kernel'); ConfAxis; box on
    subplot(2,1,2);quickViewOneKernel(bleedthrough_kernel_after_subtraction, 1); title('after bleedthrough subtraction'); ConfAxis;box on
end
end