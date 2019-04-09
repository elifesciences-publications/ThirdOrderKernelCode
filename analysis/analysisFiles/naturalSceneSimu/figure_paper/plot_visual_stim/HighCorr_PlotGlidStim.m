function HighCorr_PlotGlidStim()
%reads in the data and analyzes the xtPlot

%% deal with inputs
%initialize vars these can be changed through varargin with the form
%func(...'varName','value')
dataPath = 'C:\Documents\data\xtplot\glider_all_for_plotting_stim\2017\05_05\07_38_21';
computeCorr = 0;
normSize = 1;

if isempty(dataPath)
    [xtPlot,params] = GetXtPlot();
else
    [xtPlot,params] = GetXtPlot(dataPath);
end

twoEyes = 0;

framesPerUp = params(1).framesPerUp;

epoch = xtPlot(:,3);
% Because there are zero epochs sometimes?
xtPlot = xtPlot(epoch>0, :);
epoch = xtPlot(:,3);
time = xtPlot(:,1);
frameNum = xtPlot(:,2);

numLevels = 2^(8/(framesPerUp/3));

inPlot = xtPlot(:,4:end-1)./(numLevels-1);
inPlot = 2*inPlot-1;

epochChange = [1; find(diff(epoch)); size(epoch,1)];
numEpochs = size(epochChange,1)-1;
highResEpoch = cell(numEpochs,1);
thisEpoch = cell(numEpochs,1);
tRes = framesPerUp*60;
epochNum = zeros(numEpochs,1);

for nn = 1:numEpochs
    thisEpoch{nn} = inPlot(epochChange(nn)+1:epochChange(nn+1),:);
    epochNum(nn,1) = epoch(epochChange(nn)+1);
    lastNeg1 = find(thisEpoch{nn}(1,:)~=-1,1,'last');
    
    if normSize == 1
        for cc = lastNeg1:size(thisEpoch{nn},2)
            if all(thisEpoch{nn}(:,cc) == -1)
                thisEpoch{nn} = thisEpoch{nn}(:,1:cc-1);
                break;
            end
        end
    end
    
    inSizeX = size(thisEpoch{nn},2); % spatial resolution of the stimulus
    inSizeT = size(thisEpoch{nn},1); % temporal resolution of the stimulus
    
    % adjust spatial resolution to 1 deg
    foldT = 1000/tRes;
    sizeT = inSizeT*foldT;
    sizeX = 360*1;
    highResEpoch{nn} = zeros(round(sizeT),sizeX);
    pixelSize = sizeX/inSizeX;
    
    for ii = 1:inSizeX
        for jj = 1:inSizeT
            highResEpoch{nn}(round(foldT*jj-foldT+1):round(foldT*jj),round((pixelSize*ii-pixelSize+1)):round((pixelSize*ii))) = thisEpoch{nn}(jj,ii);
        end
    end
end

%%
paramFile_xlsx = 'C:\Users\labuser\Documents\psycho5\paramfiles\Juyue_Glider\glider_all_for_plotting_stim.xlsx';
[num, txt] = xlsread(paramFile_xlsx);
txt = txt(3:end);

epoch_info_template = struct('which_glid', [], 'direction',[], 'polarity',[],'varDt', []);
epoch_info = repmat(epoch_info_template, [size(num, 2),1]);
for ee = 1:1:size(num,2)
    epoch_info(ee).which_glid = num(ismember(txt,'Stimulus.whichGlid'), ee);
    epoch_info(ee).direction = num(ismember(txt,'Stimulus.diagDirec'), ee);
    epoch_info(ee).polarity = num(ismember(txt,'Stimulus.pol'), ee);
    epoch_info(ee).varDt = num(ismember(txt, 'Stimulus.varDt'),ee);
end

%% you will plot and save inside this function...
epoch_name = {'divp','divn','convp','convn','divp2','divp3','early knight','elbow','early break'};
which_glid = [1,1,2,2,11,11,4,5,6];
varDt = [0,0,0,0,2,3,0,0,0];
polarity = [1,-1,1,-1,1,1,1,1,1];
direction = [1,1,1,1,1,1,1,1,1,1];
MakeFigure;
subplot(2,5,1);
config_figure();
imagesc(thisEpoch{1}(1:3:end,1:15));
for ii = 1:1:length(epoch_name)
    subplot(2,5,ii + 1);
    ax = gca;
    ax.Units = 'Inches';
    which_epoch = [epoch_info(:).which_glid] == which_glid(ii) & ...
        [epoch_info(:).polarity] ==polarity(ii) & ...
        [epoch_info(:).direction] == direction(ii) & ...
        [epoch_info(:).varDt] == varDt(ii);
    find(which_epoch)
    imagesc(thisEpoch{which_epoch}(1:3:end,1:15)); % 30 12 % That is 50 ms...
    config_figure();
end
end

function config_figure()
ax = gca;
currPos = ax.Position;
ax.Position = [currPos(1),currPos(2),1,2]; % aspect ratio needs to be there...
colormap(gray)
set(gca,'XTick',[],'YTick',[]);
ConfAxis
box on
end