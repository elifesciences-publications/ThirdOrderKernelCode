function ensemble_scrambling_utils_generate_image_set(seed_num, n_image_per_set, storage_folder,  scene_name)
data_sequence_image_421 = Generate_VisStimVelEst_Utils_GenerateImageSequence(n_image_per_set, 'seed_num', seed_num);
data_sequence_image = tansfer_data_sequence_421_to_vector(data_sequence_image_421);
%%
rng(seed_num)
NFFT = 927;
n_lambda = (NFFT - 1)/2;
% do permutation of 1000 for n_lambda. Every point in power spectrum
% distribution got picked.
perm_num = zeros(n_lambda, n_image_per_set);
for ii = 1:1:n_lambda
    perm_num(ii, :) = randperm(n_image_per_set);
end

image_sequence = data_sequence_image.image_sequence(perm_num);
row_sequence = data_sequence_image.image_row_pos_sequence(perm_num);


I = zeros(n_image_per_set, 927); % hard coded some numbers.
parfor ii = 1:1:n_image_per_set
    I(ii, :) = ensemble_scrambling_utils_generate_one_image(seed_num, ...
        'image_sequence', image_sequence(:,ii),'row_sequence',row_sequence(:,ii));
end
save(fullfile(storage_folder, scene_name),'I');
end
