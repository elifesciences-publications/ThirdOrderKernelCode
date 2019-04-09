function velocity_sequence = Generate_VisStimVelEst_Utils_GenerateVelocitySequence(n_total_sample_points,  velocity, varargin)
seed_num  = 0;
nImage = 421;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

rng(seed_num,'twister');
nSpI = ChoseImage(nImage,n_total_sample_points); % every image has particular number of stimulus. uniformly sample from different images.
velocity_sequence = cell(nImage, 1);
for m = 1:1:nImage
    n_sample = nSpI(m);
    for nn = 1:1:n_sample
        velocity_sequence{m}(nn) = VisualStimulusGeneration_Utils_SampleOneV(velocity);
    end
end
end