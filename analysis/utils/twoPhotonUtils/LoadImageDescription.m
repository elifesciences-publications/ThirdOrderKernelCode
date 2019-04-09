function [imageDescription] = LoadImageDescription(dataPath)
% Takes in a data path for an image and loads up the image's description as
% saved in the .mat file

imageDescriptionPath = fullfile(dataPath,'imageDescription.mat');
try
    imageDescription = load(imageDescriptionPath);
catch loadError
    if strcmp(loadError.identifier, 'MATLAB:load:couldNotReadFile')
        warning('The image description couldn''t be loaded--this is probably because the data has yet to be aligned')
        imageDescription = [];
        return
    else
        rethrow(loadError)
    end
end
imageDescription = imageDescription.state;