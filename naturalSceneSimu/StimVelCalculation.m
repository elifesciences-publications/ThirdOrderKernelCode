function StimVelCalculation(param)

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
mainFindOutlier;
%%
% create the file to store the data of this time...
foldername = FoldernameGen(path,velocity)
for i = 1:1:nStim
    % get one image, do not use picture which has large contrast.
    badImageFlag = 1;
    while badImageFlag
        imageID = randi(imageDataMeta.n);
        if isempty(find(imageOutlier == imageID, 1))
            badImageFlag = 0;
        end
    end
    
    % one position of row
    I = LoadProcessedImage(imageID, imageDataInfo,path.image);
    % determine whether to flip the picture, balance the left and right.
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
    
    SaveStimVel(i,dat a,foldername);
end