function [red, green] = SAC_utils_load_raw_movie_5D_movie(file)
    data = load(file);
    green = double(squeeze(data.stim.frames(:,:,2,:,:)));
    red   = double(squeeze(data.stim.frames(:,:,1,:,:)));
end