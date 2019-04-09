function data_sequence = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_total_sample_points, varargin)
seed_num  = 0;
nImage = 421;
n_ver_pixel = 251;
n_hor_pixel = 927;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

rng(seed_num, 'twister');
nSpI = ChoseImage(nImage,n_total_sample_points); % every image has particular number of stimulus. uniformly sample from different images.
image_sequence = randperm(nImage);
% row_pos is the position of a randomly choosed row.
image_row_pos_sequence = cell(nImage, 1);
% column_pos is the position of a randomly choosed row.
image_column_pos_sequence = cell(nImage, 1);
% determine whether to flip the picture, balance the left and right.
image_flip_flag_sequence = cell(nImage, 1);
for m = 1:1:nImage
    n_sample = nSpI(m);
    image_row_pos_sequence{m} = randi(n_ver_pixel, [n_sample, 1]);
    image_column_pos_sequence{m} = randi(n_hor_pixel, [n_sample, 1]);
    image_flip_flag_sequence{m} = rand(n_sample, 1) > 0.5;
%     for nn = 1:1:n_sample
%         velocity_sequence{m}(nn) = VisualStimulusGeneration_Utils_SampleOneV(velocity);
%     end
end

data_sequence.image_sequence = image_sequence;
data_sequence.image_row_pos_sequence = image_row_pos_sequence;
data_sequence.image_column_pos_sequence = image_column_pos_sequence;
data_sequence.image_flip_flag_sequence = image_flip_flag_sequence;
data_sequence.nSpI = nSpI;
data_sequence.seed_num = seed_num;
%%
end