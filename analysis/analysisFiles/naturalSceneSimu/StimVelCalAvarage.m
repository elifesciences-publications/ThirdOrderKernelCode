function StimVelCalAvarage(param)

path = param.path;
photoreceptor = param.photoreceptor;
image = param.image;
stim = param.stim;
velocity = param.velocity;
time = param.time;
nSpS = param.computation.nSpS;

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
foldername = FoldernameGenV(path,velocity);
%% calculate how to uniformly sample the data.
% calculate how many picture is available.
% fisrt, calculate how many stimulus would come from one image.
imageIDBank = 1:1:imageDataMeta.n;
% imageIDBank(imageOutlier) = [];
nImage = length(imageIDBank);
nSpI = ChoseImage(nImage,nStim);

imageSequence = randperm(nImage);

% every 1000 stimulus, the system would store stim data once.
% there would be a large structure array which stores temporary data.

dataArray = cell(nV,1);
for vv = 1:1:nV
    dataArray{vv} = cell(nSpS,1);
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
        
        velSign = 2*((rand > 0.5) - 0.5);        
        for vv = 1:1:nV
            vel = velocity.value(vv);
            vel = vel * velSign;
            s1 = StimulusGenerationTrace(oneRow,pos1,vel,time,image);
            s2 = StimulusGenerationTrace(oneRow,pos2,vel,time,image);
            
            %% store the data s1, s2, pos1, pos2, vel, imageID,posRow,
            data.ImageID = imageID;
            data.posRow = posRow;
            data.pos1 = pos1;
            data.pos2 = pos2;
            data.s1 = s1;
            data.s2 = s2;
            data.vel = vel;
            data.flipFlag = flipFlag;
            
            %%
            %% calculate the velocity and also store them...
            % do not forgot the restore this term.
            % calculate the motion over time, and over a small area...
            % for this one, do not calculate HRC at all..., all the data
            
           
            [vest.K2.xy, vest.K2.sym] = MotionCalculatorK2(K2,data,time);
            [vest.K3.xxy, vest.K3.yyx, vest.K3.sym] = MotionCalculatorK3(K3,data,time);
           
            % the HRC, converging K3, past skew K3, and autocorrelation are
            % all stored in the MC.
            %
            %disp(foldername{vv});
            
            dataArray{vv}{storageCounter} = data;
        end
        %%
        if storageCounter == nSpS
            for vv = 1:1:nV
                dataStore = dataArray{vv};
                SaveStimVel(counter,dataStore,foldername{vv});
            end
            counter = counter + 1;
            storageCounter = 0;
        end
        storageCounter = storageCounter + 1;
        globalCounter = globalCounter + 1;
        
    end
    
end

end