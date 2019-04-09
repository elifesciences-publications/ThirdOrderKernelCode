function [photodiodeVec, highResLinesPerFrame] = ReadInPhotodiode(imageDescription, dataPath)
% Takes in a data path and an image description and outputs the photodiode
% vector of a photodiode stream image, as well as the resolution given that
% the photodiode is being read on a per-line basis

highResLinesPerFrame = imageDescription.acq.linesPerFrame-imageDescription.acq.slowDimDiscardFlybackLine;
photoDiodePath = fullfile(dataPath,'highResPd.mat');
photodiodeVec = load(photoDiodePath);
photodiodeVec = photodiodeVec.highResPd;
photodiodeVec = photodiodeVec - mean(photodiodeVec);