function StimVelCalculationUniSampV(param)

path = param.path;
photoreceptor = param.photoreceptor;
image = param.image;
stim = param.stim;
velocity = param.velocity;
time = param.time;
velSampMode = param.velSampMode;

nSpS = param.computation.nSpS; % number of stimulus per save.
kernel = param.kernel;
HRC = kernel.HRC;
K2 = kernel.K2;
K3 = kernel.K3;
MC = kernel.MC;
ConvK3 = kernel.ConvK3;
PSK3 = kernel.PSK3;
AutoK2 = kernel.AutoK2;

% load the contrast image.
imageDataInfo  = dir([path.image '*.mat']);
imageDataMeta.n = length(imageDataInfo);
nVerPixel = image.param.ver.nPixel;
nStim = stim.n;
nV = length(velocity.value);

%%
% create the file to store the data of this time...

% the data should be stored by 1) spatial filter, 2)velocity value.

% write a uniform function...
% switch velSampMode
%     case 'Binary'
%         foldername = FoldernameGenV(path,velocity);
%     case 'Uniform'
%         foldername = FoldernameGenUniform(path);
%     case 'Guassian'
%         foldername = FoldernameGenGussian(path,velocity.std)
% end
foldername = FoldernameGenV(path,velocity,velSampMode);
%% calculate how to uniformly sample the data.
% calculate how many picture is available.
% fisrt, calculate how many stimulus would come from one image.
imageIDBank = 1:1:imageDataMeta.n;
% imageIDBank(imageOutlier) = [];
nImage = length(imageIDBank);
nSpI = ChoseImage(nImage,nStim);

imageSequence = randperm(nImage);

% every 1000 stimulus, the system would store stim data once.1000 might be
% too small. is your computing time cosuming? sometimes, but not always.


% there would be a large structure array which stores temporary data.
switch velSampMode
    case 'Binary'
        dataArray = cell(nV,1);
        for vv = 1:1:nV
            dataArray{vv} = cell(nSpS,1);
        end
    case 'Uniform'
        dataArray = cell(nSpS,1);
    case 'Gussian'
        dataArray = cell(nSpS,1);
end

globalCounter = 1; % globalCounter counts for each velocity, how many stimulus and result has been calculated.
storageCounter= 1; % storageCounter counts how many data has been collected for this storage unit, when it reaches nSpS, the data will be stored into file
counter = 1; % counter counts how many data unit has been calculated. the name of the data will be determined by the final number of counter.


for m = 1:1:nImage
    % first image could be
    imageID = imageSequence(m);
    I = LoadProcessedImage(imageID,imageDataInfo,path.image);
    
    for k = 1:1:nSpI(imageID);
        
        % for the same image, choose different locations randomly.
        % this is one visual stimulus for all the position and all the
        % velocity posibility.
        flipFlag = rand > 0.5;
        if flipFlag
            I = fliplr(I);
        end
        posRow = randi(nVerPixel);
        oneRow = I(posRow,:);
        pos1 = randPosition(image);
        pos2 = pos1 + photoreceptor.spatial.distance;
        % s1 is just the interpretation....
        switch velSampMode
            case 'Binary';
                nV = length(velocity.value);
                velSign = 2*((rand > 0.5) - 0.5);
                for vv = nV:1:nV
                    vel = velocity.value(vv);
                    vel = vel * velSign;
                    StimVelCalculationUtils; % 0.29 per data point.
                    dataArray{vv}{storageCounter} = data;
                end
            case 'Uniform'
                % randomly generate one velocity from uniform
                % distribution;
                vel = 2 * (rand -0.5) * velocity.maxUniform;
                StimVelCalculationUtils;
                dataArray{storageCounter} = data;
            case 'Guassian'; % for gussian distribution
                
                vel = velocity.mean + randn * velocity.std;
                StimVelCalculationUtils;
                dataArray{storageCounter} = data;
        end
        %%
        
        if storageCounter == nSpS
            switch velSampMode
                case 'Binary'
                    for vv = 1:1:nV
                        dataStore = dataArray{vv};
                        SaveStimVel(counter,dataStore,foldername{vv});
                    end
                case 'Uniform'
                    SaveStimVel(counter,dataArray,foldername);
                case 'Guassian'
                    SaveStimVel(counter,dataArray,foldername);
            end
            counter = counter + 1;
            storageCounter = 0;
        end
        storageCounter = storageCounter + 1;
        globalCounter = globalCounter + 1;
        
    end
    
end

end