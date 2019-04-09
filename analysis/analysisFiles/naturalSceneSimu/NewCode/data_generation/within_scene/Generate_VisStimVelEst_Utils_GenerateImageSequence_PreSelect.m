function data_sequence_image = Generate_VisStimVelEst_Utils_GenerateImageSequence_PreSelect(image_ID_use, image_row_use)
n_image = 421;
data_sequence_image.image_sequence = 1:n_image;
data_sequence_image.image_row_pos_sequence = cell(n_image, 1);
data_sequence_image.image_flip_flag_sequence = cell(n_image, 1);
data_sequence_image.nSpI = zeros(n_image, 1);
data_sequence_image.image_column_pos_sequence = cell(n_image, 1); % might not be useful at all. still

for ii = 1:1:length(image_ID_use)
    image_ID = image_ID_use(ii);
    data_sequence_image.image_flip_flag_sequence{image_ID} = [data_sequence_image.image_flip_flag_sequence{image_ID}, false];
    data_sequence_image.image_row_pos_sequence{image_ID} = [data_sequence_image.image_row_pos_sequence{image_ID}, image_row_use(ii)];
    data_sequence_image.nSpI(image_ID) = data_sequence_image.nSpI(image_ID) + 1;
end
