function out=RFsOnScreen(flyResp,epochs,~,~,~,~,varargin)

if length(varargin)==1
    varargin=varargin{1};
end

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


% probe file
[numProbeEpochs,probeLength]=loadProbeInfo(dataPath,epochs);

% stim file
[stimTimeStamps,stimLengthOneTrial,trialStarts,stimEpochs]=loadStimInfo(dataPath,stimName,numProbeEpochs,probeLength,epochs);
nStimTrials=length(trialStarts);

% edge positions from textStimData.csv
[stimLoc,posTimeStamps]=loadBarPosInfo(dataPath,stimEpochs);
stimLocPos=stimLoc+2;
stimLocNeg=stimLoc-2;

% response time traces
respTimeTraces=zeros(ceil(stimLengthOneTrial),size(flyResp,2),nStimTrials);
for m=1:nStimTrials
    start=trialStarts(m);
    respTimeTraces(:,:,m)=flyResp(start:start+stimLengthOneTrial-1,:);
end


numROIs=size(respTimeTraces,2);

pos_screen=zeros(numROIs,4);
colors = jet(numROIs);
if length(stimEpochs)==8
    aux=[1:4;5:8];
else
    aux=[2:5;7:10];
end

for a=1
    for tt=1:numROIs
        for k=aux(a,:)
            start=stimTimeStamps(k);
            finish=stimTimeStamps(k+1);
            resp=respTimeTraces(start:finish,tt,:);
            resp=reshape(resp,size(resp,1),nStimTrials);
            auxPos11=posTimeStamps{k};
            pos=linspace(stimLocPos(auxPos11(1,1)),stimLocPos(auxPos11(1,2)-1),size(resp,1));
            if find([2 4 6 8],k)
                pos=abs(pos);
            end
            m1=mean(resp,2);
            sd1=std(resp,[],2);
            m2=mean(m1);
            sd2=std(m1);
            
            aq1=find(m1>m2+2*sd2);
            aq2=find(m1<m2-2*sd2);
            aq3=strfind(diff(aq1)',[1 1]);
            aq4=strfind(diff(aq2)',[1 1]);
            if ~isempty(aq1) && ~isempty(aq3) %&& isempty(aq5)
                [mm,b]=max(m1);
                if a==1
                    if length(stimEpochs)==8
                        pos_screen(tt,k)=pos(b);
                        dfof(tt,k)=mm;
                    else
                        pos_screen(tt,k-1)=pos(b);
                        dfof(tt,k-1)=mm;
                    end
                else
                    pos_screen(tt,k-6)=pos(b);
                    dfof(tt,k-1)=mm;
                end
            elseif ~isempty(aq2) && ~isempty(aq4) %&& isempty(aq6)
                [mm,b]=min(m1);
                if a==1
                    if length(stimEpochs)==8
                        pos_screen(tt,k)=pos(b);
                        dfof(tt,k)=mm;
                    else
                        pos_screen(tt,k-1)=pos(b);
                        dfof(tt,k-1)=mm;
                    end
                else
                    pos_screen(tt,k-6)=pos(b);
                    dfof(tt,k-1)=mm;
                end
            end
        end
    end
    
end
all_x=[];
all_y=[];
DSI_LR=[];
DSI_UD=[];
for kj=1:size(pos_screen,1)
    if sum(pos_screen(kj,:)~=[0 0 0 0])==4
        x=mean([pos_screen(kj,1) pos_screen(kj,2)]);
        all_x=[all_x x];
        
        y=mean([pos_screen(kj,3) pos_screen(kj,4)]);
        all_y=[all_y y];
        text(x,y, num2str(kj),...
            'FontSize',12, 'HorizontalAlignment', 'center', 'Color',colors(kj,:));
        hold on
        aux1=(dfof(kj,1)-dfof(kj,2))./(dfof(kj,1)+dfof(kj,2));
        DSI_LR=[DSI_LR aux1];
        aux2=(dfof(kj,3)-dfof(kj,4))./(dfof(kj,3)+dfof(kj,4));
        DSI_UD=[DSI_UD aux2];
    end
end
set(gca,'Ydir','reverse')

if ~isempty(all_x) && ~isempty(all_y) && length(all_x)>1 && length(all_y)>1
    out(1)=min(all_x);
    out(2)=max(all_x);
    out(3)=min(all_y);
    out(4)=max(all_y);
else
    out=[];
end
if ~isempty(DSI_LR) && ~isempty(DSI_UD)
    save(['DSI_LR_' filename '.mat'],'DSI_LR')
    save(['DSI_UD_' filename '.mat'],'DSI_UD')
end
