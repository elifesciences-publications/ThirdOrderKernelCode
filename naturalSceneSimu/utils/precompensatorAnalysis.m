function precompensatorAnalysis

original_dir = pwd;
cd(uigetdir('D:\data', 'Choose a Folder of Images for which to Plot Compensation Info')); %get to the pictures
listing = dir;

listing(1:2) = []; %get rid of current and parent directory

addpath(genpath('C:\Users\ClarkLab\flyCode\psycho5')); %we want the twoPhoton functions


mtrPos = zeros(1, length(listing));
totalIntensity = zeros(1, length(listing));
acquisition = zeros(1, length(listing));

byRandom = false;

if byRandom
    loopedOnce = false;
end
for x = 1:1000
    disp(x);
    for fileNum = 1:length(listing)
        filename = listing(fileNum).name;
        if byRandom
            if ~loopedOnce
                [imgFrames, fn, path] = twoPhotonImageParser(filename);
                imgFramesAll(:, :, :, fileNum) = imgFrames;
            else
                imgFrames = imgFramesAll(:, :, :, fileNum);
            end
        else
            [imgFrames, fn, path] = twoPhotonImageParser(filename);
        end
        if byRandom
            [r, c, inds] = size(imgFrames);
            ind = ceil(inds*rand(1, 25));
            my_frame = imgFrames(:, :, ind);
            totalIntensity(x, fileNum) = sum(my_frame(:));
        else
            my_frames = imgFrames(:, :, :);
            totalIntensity(x, fileNum) = sum(my_frames(:));
        end
        filename(filename == '_') = '.';
        mtrPos(x, fileNum) = str2double(filename(1:5));
        
        acquisition(x, fileNum) = str2double(filename(end-5:end-4));
        
    end
    if byRandom
        if ~loopedOnce
            loopedOnce = true;
        end
    else
        %only do it once if not doing the random sampling
        break;
    end
end

cd(original_dir);
figure
plot(mtrPos, totalIntensity, '-*');