function Z =twoPhotonFlattener(Z)
%This function will take in images from a tif file specified by the user
%(tif file should have been created by a scanimage loop or grab command)
%and output the result of flattening all the images together into one two
%dimensional image. It will then output the image as a TIF with _flattened
%appended to the original filename

% Receive input variables
inputsRequired = {'flattening_method', 'fn', 'path'};
loadFlexibleInputs(Z, inputsRequired)


if exist('flattening_method', 'var') && strcmp(flattening_method, 'mean')
    outputImage = mean(Z.grab.imgFrames, 3);
else
    %Taking the maximum is the default approach for flattening
    outputImage = max(Z.grab.imgFrames, [], 3);
end

newFile = fullfile(Z.params.pathName, [fn(1:end-4) '_flattened.tif']);
imwrite(outputImage/max(outputImage(:)), newFile, 'tif'); 