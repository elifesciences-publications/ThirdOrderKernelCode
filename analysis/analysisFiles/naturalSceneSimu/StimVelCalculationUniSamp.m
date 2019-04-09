function StimVelCalculationUniSamp(param)

path = param.path;
photoreceptor = param.photoreceptor;
image = param.image;
stim = param.stim;
velocity = param.velocity;
time = param.time;
mode = param.mode;

kernel = param.kernel;
HRC = kernel.HRC;
K2 = kernel.K2;
K3 = kernel.K3;

% load the preprocessed data.
imageDataInfo  = dir([path.image '*.mat']);
imageDataMeta.n = length(imageDataInfo);
nVerPixel = image.param.ver.nPixel;
nStim = stim.n;

% exclude the picture with too large contrast and reduce extreme values
% after the local contrast calculation, do you still need this step?
% if you need, what are you going to do?
% suppose not.
% it is always to look? or based on stimulus? noooooooooo
mainFindOutlier;
%%
% create the file to store the data of this time...
foldername = FoldernameGen(path,velocity);

%% calculate how to uniformly sample the data.
% calculate how many picture is available.
% fisrt, calculate how many stimulus would come from one image.
imageIDBank = 1:1:imageDataMeta.n;
imageIDBank(imageOutlier) = [];
nImage = length(imageIDBank);

nSpI = ChoseImage(nImage,nStim);
counter = 1;

for m = 1:1:nImage
    imageID = imageIDBank(m);
    I = LoadProcessedImage(imageID, imageDataInfo,path.image);
   
    for k = 1:1:nSpI(m)
        flipFlag = rand > 0.5;
        if flipFlag
            I = fliplr(I);
        end
        posRow = randi(nVerPixel);
        oneRow = I(posRow,:);
        
        % from now on, use the degree and interpolation.
        
        % s1 is the voltage signal the left receptor receives;
        % s2 is the voltage signal the right receptor receives
        % pos1 is the position of first photoreceptor in degree coordinates.
        % pos2 is the position of second photoreceptor in degree coordinates.
        % vel is a random velocity drawn from targeted distribution.
        % chose a positiion in the picture, pos1 is in degree.
        
        
        vel = randn * velocity.std;
        pos1 = randPosition(image);
        % s1 is just the interpretation....
        s1 = StimulusGenerationTrace(oneRow,pos1,vel,time,image);
        pos2 = pos1 + photoreceptor.spatial.distance;
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
        
        %% calculate the velocity and also store them...
        vest.HRC = MotionCalculatorHRC(HRC,data,time);
        [vest.K2.xy, vest.K2.sym] = MotionCalculatorK2(K2,data,time);
        [vest.K3.xxy, vest.K3.yyx, vest.K3.sym] = MotionCalculatorK3(K3,data,time);
        
        data.vest = vest;
        
        SaveStimVel(counter,data,foldername);
        counter = counter + 1; 
    end
end

% for remainder, random chose one?