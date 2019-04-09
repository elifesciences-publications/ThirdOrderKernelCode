function out1=analyzeMovingBar(flyResp,epochs,params,~,dataRate,~,~,varargin)

epochs=epochs{1};
epochs=epochs(:,1);
params=params{1};
out1=[];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

numFlies=length(flyResp);
FontSize=18;
for qq=1:numFlies
    
    flyResp=flyResp{qq};
    
    % probe file
    [numProbeEpochs,probeLength]=loadProbeInfo(dataPath{qq},epochs);
    
    % stim file
    [stimTimeStamps,stimLengthOneTrial,trialStarts,stimEpochs]=loadStimInfo(dataPath{qq},stimName,numProbeEpochs,probeLength,epochs);
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
    
    dfr=ceil(numROIs/6);
    nh=size(epochsForSelectivity,2);
    if nh==1
        txt='no ROI selection';
    else
        txt=[epochsForSelectivity{iteration,1} '>' epochsForSelectivity{iteration,2}];
    end
    
    figure('Color','w','Position',[73 42 1118 550],'Name',[filename ' response panel bar ' txt])
    
    pa = panel();
    pa.pack('v',{1/15 8/15 6/15})
    pa(2).pack(1,2)
    pa(3).pack('h',{0.5/5 4/5 0.5/5})
    pa(2,1,2).pack(2,1)
    pa(2,1,1).marginright=10;
    pa(2,1,2,1,1).marginbottom=10;
    pa.marginleft=20;
    pa.marginright=20;
    pa(2).margintop=5;
    pa(3).margintop=20;
    %pa.select('all');
    %pa.identify();
    
    pa(1).select();
    htxt=title([filename ' response panel bar ' txt]);
    set(htxt,'Position',[0.5 0.2],'Interpreter','none')
    set(gca,'units','normalized')
    set(gca,'FontSize',20)
    set(gca,'XColor','w')
    set(gca,'YColor','w')
    
    pa(2,1,1).select();
    out=plotROIsOnMask_MA2(flyResp,[],[],[],[],[],[],varargin);
    axis tight
    colormap(gca,'gray')
    
    pa(2,1,2,1,1).select();
    out=RFsOnScreen(flyResp,epochs,params,[],[],[],varargin);
    xlim([0 360])
    ylim([0 153])
    extras(gca)
    set(gca,'XTick',linspace(0,360,4),'FontSize',14);
    set(gca,'XTickLabel',linspace(0,360,4),'FontSize',14);
    set(gca,'YTick',ceil(linspace(0,153,3)),'FontSize',14);
    set(gca,'YTickLabel',ceil(linspace(0,153,3)),'FontSize',14);
    rectangle('position',[0 0 360 153],'LineWidth',3)    %axis tight
    axis tight
    
    pa(2,1,2,2,1).select();
    out=RFsOnScreen(flyResp,epochs,params,[],[],[],varargin);
    if ~isempty(out)
        xlim([0.9*min(out) 1.1*max([out(1) out(2)])])
        ylim([0.9*min([out(3) out(4)]) 1.1*max([out(3) out(4)])])
        extras(gca)
        set(gca,'XTick',[round(out(1)) round(out(2))],'FontSize',14);
        set(gca,'XTickLabel',[round(out(1)) round(out(2))],'FontSize',14);
        set(gca,'YTick',[round(out(3)) round(out(4))],'FontSize',18);
        set(gca,'YTickLabel',[round(out(3)) round(out(4))],'FontSize',14);
        rectangle('position',[0.9*out(1) 0.9*out(3) 1.1*out(2)-0.9*out(1) 1.1*out(4)-0.9*out(3)],'LineWidth',3)    %axis tight
        axis tight
    else
        axis off
    end
    
    pa(3,2).select();
    time=(1:size(respTimeTraces,1))/dataRate;
    imagesc(time,1:size(respTimeTraces,2),mean(respTimeTraces,3)')
    hold on
    line([stimTimeStamps/dataRate stimTimeStamps/dataRate], [0.5 size(respTimeTraces,2)+0.5],'Color','r','LineWidth',2)
    axis tight
    extras(gca)
    xlabel('time (s)','FontSize',18)
    ylabel('ROI #','FontSize',18)
    xsd=length(stimEpochs);
    
    f=14;
    switch BW
        case 1
            switch xsd
                case 8
                    b1=-50;
                    b2=6;
                    b3=18;
                    b4=26.5;
                    b5=32.5;
                    b6=-50;
                    b7=42;
                    b8=54;
                    b9=63;
                    b10=69;
                case 10
                    b1=1.5;
                    b2=9;
                    b3=21;
                    b4=29.5;
                    b5=35.5;
                    b6=38.75;
                    b7=46.25;
                    b8=58.25;
                    b9=66.7;
                    b10=72;
            end
        case 0
            switch xsd
                case 4
                    b1=-10;
                    b2=6;
                    b3=18;
                    b4=26.5;
                    b5=32.5;
                    b6=-10;
                    b7=-10;
                    b8=-10;
                    b9=-10;
                    b10=-10;
                case 5
                    b1=1.5;
                    b2=9;
                    b3=21;
                    b4=29.5;
                    b5=34.5;
                    b6=-50;
                    b7=-50;
                    b8=-50;
                    b9=-50;
                    b10=-50;
            end
    end
    
    aa=size(respTimeTraces,2)*1.12;
    t=text(b1,aa, 'ON','Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    t=text(b2,aa, ['dark' char(10) 'regressive'],'Units','data');
    set(t,'HorizontalAlignment','center')
    set(t,'FontSize',f)
    t=text(b3,aa, ['dark' char(10) 'progressive'],'Units','data');
    set(t,'HorizontalAlignment','center')
    set(t,'FontSize',f)
    t=text(b4,aa, ['dark' char(10) 'down'],'Units','data');
    set(t,'HorizontalAlignment','center')
    set(t,'FontSize',f)
    t=text(b5,aa,['dark' char(10) 'up'],'Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    t=text(b6,aa,'OFF','Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    t=text(b7,aa,['light' char(10) 'regressive'],'Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    t=text(b8,aa,['light' char(10) 'progressive'],'Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    t=text(b9,aa,['light' char(10) 'down'],'Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    t=text(b10,aa,['light' char(10) 'up'],'Units','data');
    set(t,'FontSize',f)
    set(t,'HorizontalAlignment','center')
    
    %close all
    
    if 0
        figure('Color','w','Position',[1 1 1244 704],'Name',[filename ' right&left dark bar ' txt])
        t=annotation('textbox');
        set(t,'String',[filename ' right&left dark bar ' txt])
        set(t,'Position',[0.35 0.9 0.1 0.1])
        set(t,'EdgeColor','none')
        set(t,'FontSize',20)
        set(t,'Interpreter','none')
        
        z=annotation('textbox');
        set(z,'String','position (deg)')
        set(z,'Position',[0.45 0 0.1 0.1])
        set(z,'EdgeColor','none')
        set(z,'FontSize',20)
        set(z,'Interpreter','none')
        
        y=annotation('textbox');
        set(y,'String','df/f')
        set(y,'Position',[0.05 0.5 0.1 0.1])
        set(y,'EdgeColor','none')
        set(y,'FontSize',20)
        set(y,'Interpreter','none')
        
        rightDarkAllRois=[];
        rightDarkAllRoisSEM=[];
        leftDarkAllRois=[];
        leftDarkAllRoisSEM=[];
        upDarkAllRois=[];
        upDarkAllRoisSEM=[];
        downDarkAllRois=[];
        downDarkAllRoisSEM=[];
        
        for tt=1:numROIs
            
            k=2;% right dark bar
            start=stimTimeStamps(k);
            finish=stimTimeStamps(k+1);
            rightDark=respTimeTraces(start:finish,tt,:);
            rightDark=reshape(rightDark,size(rightDark,1),nStimTrials);
            auxPos11=posTimeStamps{k};
            pos11=linspace(stimLocPos(auxPos11(1,1)),stimLocPos(auxPos11(1,2)-1),size(rightDark,1));
            subplot(dfr,6,tt)
            shadedErrorBar(gca,pos11,mean(rightDark,2),...
                std(rightDark,[],2)/sqrt(nStimTrials),{'Color',[0 0.4470 0.7410]},1)
            axis tight
            extras(gca)
            hold on
            rightDarkAllRois=[rightDarkAllRois mean(rightDark,2)];
            rightDarkAllRoisSEM=[rightDarkAllRoisSEM std(rightDark,[],2)/sqrt(nStimTrials)];
            
            k=3;% left dark bar
            start=stimTimeStamps(k);
            finish=stimTimeStamps(k+1);
            leftDark=respTimeTraces(start:finish,tt,:);
            leftDark=reshape(leftDark,size(leftDark,1),nStimTrials);
            auxPos21=posTimeStamps{k};
            pos21=linspace(stimLocNeg(auxPos21(1,1)),stimLocNeg(auxPos21(1,2)-1),size(leftDark,1));
            pos21=abs(pos21);
            shadedErrorBar(gca,pos21,mean(leftDark,2),...
                std(leftDark,[],2)/sqrt(nStimTrials),{'Color',[0.8500 0.3250 0.0980]},1)
            axis tight
            extras(gca)
            leftDarkAllRois=[leftDarkAllRois mean(leftDark,2)];
            leftDarkAllRoisSEM=[leftDarkAllRoisSEM std(leftDark,[],2)/sqrt(nStimTrials)];
        end
        print(gcf, '-dpng', '-opengl', sprintf('-r%d',600),[filename ' right&left dark bar ' txt]);
        close all
        
        figure('Color','w','Position',[1 1 1244 704],'Name',[filename ' up&down dark bar ' txt])
        t=annotation('textbox');
        set(t,'String',[filename ' up&down dark bar ' txt])
        set(t,'Position',[0.35 0.9 0.1 0.1])
        set(t,'EdgeColor','none')
        set(t,'FontSize',20)
        set(t,'Interpreter','none')
        
        z=annotation('textbox');
        set(z,'String','position (deg)')
        set(z,'Position',[0.45 0 0.1 0.1])
        set(z,'EdgeColor','none')
        set(z,'FontSize',20)
        set(z,'Interpreter','none')
        
        y=annotation('textbox');
        set(y,'String','df/f')
        set(y,'Position',[0.05 0.5 0.1 0.1])
        set(y,'EdgeColor','none')
        set(y,'FontSize',20)
        set(y,'Interpreter','none')
        
        for tt=1:numROIs
            k=4;% down dark bar
            start=stimTimeStamps(k);
            finish=stimTimeStamps(k+1)-1;
            downDark=respTimeTraces(start:finish,tt,:);
            downDark=reshape(downDark,size(downDark,1),nStimTrials);
            auxPos31=posTimeStamps{k};
            pos31=linspace(stimLocPos(auxPos31(1,1)),stimLocPos(auxPos31(1,2)-1),size(downDark,1));
            subplot(dfr,6,tt)
            shadedErrorBar(gca,pos31,mean(downDark,2),...
                std(downDark,[],2)/sqrt(nStimTrials),{'Color',[0 0.4470 0.7410]},1)
            axis tight
            extras(gca)
            hold on
            downDarkAllRois=[downDarkAllRois mean(downDark,2)];
            downDarkAllRoisSEM=[downDarkAllRoisSEM std(downDark,[],2)/sqrt(nStimTrials)];
            
            
            k=5;% up dark bar
            start=stimTimeStamps(k);
            finish=stimTimeStamps(k+1);
            upDark=respTimeTraces(start:finish,tt,:);
            upDark=reshape(upDark,size(upDark,1),nStimTrials);
            auxPos41=posTimeStamps{k};
            pos41=linspace(stimLocNeg(auxPos41(1,1)),stimLocNeg(auxPos41(1,2)-1),size(upDark,1));
            pos41=abs(pos41);
            shadedErrorBar(gca,pos41,mean(upDark,2),...
                std(upDark,[],2)/sqrt(nStimTrials),{'Color',[0.8500 0.3250 0.0980]},1)
            axis tight
            extras(gca)
            upDarkAllRois=[upDarkAllRois mean(upDark,2)];
            upDarkAllRoisSEM=[upDarkAllRoisSEM std(upDark,[],2)/sqrt(nStimTrials)];
        end
        print(gcf, '-dpng', '-opengl', sprintf('-r%d',600),[filename ' up&down dark bar ' txt]);
        close
        
        figure('Color','w','Position',[1 1 683 697],'Name',[filename ' dark bar ' txt])
        t=annotation('textbox');
        set(t,'String',[filename ' dark bar ' txt])
        set(t,'Position',[0.25 0.9 0.1 0.1])
        set(t,'EdgeColor','none')
        set(t,'FontSize',20)
        set(t,'Interpreter','none')
        
        pa=panel;
        pa.pack(2,2);
        pa.margin=20;
        
        pa(1,1).select();
        imagesc(pos11,1:size(rightDarkAllRois,2),rightDarkAllRois')
        axis tight
        extras(gca)
        title('right','FontSize',FontSize)
        set(gca,'XColor','none','FontSize',FontSize)
        ylabel('ROI #','FontSize',FontSize)
        
        pa(2,1).select();
        imagesc(pos21,1:size(leftDarkAllRois,2),leftDarkAllRois')
        axis tight
        extras(gca)
        title('left','FontSize',FontSize)
        xlabel('position (deg)','FontSize',FontSize)
        ylabel('ROI #','FontSize',FontSize)
        set(gca,'FontSize',FontSize)
        
        pa(1,2).select();
        imagesc(pos31,1:size(upDarkAllRois,2),fliplr(upDarkAllRois'))
        axis tight
        extras(gca)
        title('down','FontSize',FontSize)
        set(gca,'XColor','none','FontSize',FontSize)
        set(gca,'YColor','none','FontSize',FontSize)
        
        pa(2,2).select();
        imagesc(pos41,1:size(downDarkAllRois,2),fliplr(downDarkAllRois'))
        axis tight
        extras(gca)
        title('up','FontSize',FontSize)
        xlabel('position (deg)','FontSize',FontSize)
        set(gca,'YColor','none','FontSize',FontSize)
        
        print(gcf, '-dpng', '-opengl', sprintf('-r%d',600),[filename ' dark bar ' txt]);
        close
        
        if BW
            
            figure('Color','w','Position',[1 1 1244 704],'Name',[filename ' right&left light bar ' txt])
            t=annotation('textbox');
            set(t,'String',[filename ' right&left light bar ' txt])
            set(t,'Position',[0.35 0.9 0.1 0.1])
            set(t,'EdgeColor','none')
            set(t,'FontSize',20)
            set(t,'Interpreter','none')
            
            z=annotation('textbox');
            set(z,'String','position (deg)')
            set(z,'Position',[0.45 0 0.1 0.1])
            set(z,'EdgeColor','none')
            set(z,'FontSize',20)
            set(z,'Interpreter','none')
            
            y=annotation('textbox');
            set(y,'String','df/f')
            set(y,'Position',[0.05 0.5 0.1 0.1])
            set(y,'EdgeColor','none')
            set(y,'FontSize',20)
            set(y,'Interpreter','none')
            
            
            rightLightAllRois=[];
            rightLightAllRoisSEM=[];
            leftLightAllRois=[];
            leftLightAllRoisSEM=[];
            upLightAllRois=[];
            upLightAllRoisSEM=[];
            downLightAllRois=[];
            downLightAllRoisSEM=[];
            
            
            for tt=1:numROIs
                
                k=7;% right light bar
                start=stimTimeStamps(k);
                finish=stimTimeStamps(k+1);
                rightLight=respTimeTraces(start:finish,tt,:);
                rightLight=reshape(rightLight,size(rightLight,1),nStimTrials);
                auxPos12=posTimeStamps{k};
                pos12=linspace(stimLocPos(auxPos12(1,1)),stimLocPos(auxPos12(1,2)-1),size(rightLight,1));
                subplot(dfr,6,tt)
                shadedErrorBar(gca,pos12,mean(rightLight,2),...
                    std(rightLight,[],2)/sqrt(nStimTrials),{'Color',[0 0.4470 0.7410]},1)
                axis tight
                extras(gca)
                hold on
                rightLightAllRois=[rightLightAllRois mean(rightLight,2)];
                rightLightAllRoisSEM=[rightLightAllRoisSEM std(rightLight,[],2)/sqrt(nStimTrials)];
                
                
                k=8;% left light bar
                start=stimTimeStamps(k)+1;
                finish=stimTimeStamps(k+1);
                leftLight=respTimeTraces(start:finish,tt,:);
                leftLight=reshape(leftLight,size(leftLight,1),nStimTrials);
                auxPos22=posTimeStamps{k};
                pos22=linspace(stimLocNeg(auxPos22(1,1)),stimLocNeg(auxPos22(1,2)-1),size(leftLight,1));
                pos22=abs(pos22);
                shadedErrorBar(gca,pos22,mean(leftLight,2),...
                    std(leftLight,[],2)/sqrt(nStimTrials),{'Color',[0.8500 0.3250 0.0980]},1)
                axis tight
                extras(gca)
                leftLightAllRois=[leftLightAllRois mean(leftLight,2)];
                leftLightAllRoisSEM=[leftLightAllRoisSEM std(leftLight,[],2)/sqrt(nStimTrials)];
            end
            print(gcf, '-dpng', '-opengl', sprintf('-r%d',600),[filename ' right&left light bar ' txt]);
            close
            
            figure('Color','w','Position',[1 1 1244 704],'Name',[filename ' up&down light bar ' txt])
            t=annotation('textbox');
            set(t,'String',[filename ' up&down light bar ' txt])
            set(t,'Position',[0.35 0.9 0.1 0.1])
            set(t,'EdgeColor','none')
            set(t,'FontSize',20)
            set(t,'Interpreter','none')
            
            z=annotation('textbox');
            set(z,'String','position (deg)')
            set(z,'Position',[0.45 0 0.1 0.1])
            set(z,'EdgeColor','none')
            set(z,'FontSize',20)
            set(z,'Interpreter','none')
            
            y=annotation('textbox');
            set(y,'String','df/f')
            set(y,'Position',[0.05 0.5 0.1 0.1])
            set(y,'EdgeColor','none')
            set(y,'FontSize',20)
            set(y,'Interpreter','none')
            
            
            for tt=1:numROIs
                k=9;% down light bar
                start=stimTimeStamps(k);
                finish=stimTimeStamps(k+1)-1;
                downLight=respTimeTraces(start:finish,tt,:);
                downLight=reshape(downLight,size(downLight,1),nStimTrials);
                auxPos32=posTimeStamps{k};
                pos32=linspace(stimLocPos(auxPos32(1,1)),stimLocPos(auxPos32(1,2)-1),size(downLight,1));
                subplot(dfr,6,tt)
                shadedErrorBar(gca,pos32,mean(downLight,2),...
                    std(downLight,[],2)/sqrt(nStimTrials),{'Color',[0 0.4470 0.7410]},1)
                hold on
                axis tight
                extras(gca)
                downLightAllRois=[downLightAllRois mean(downLight,2)];
                downLightAllRoisSEM=[downLightAllRoisSEM std(downLight,[],2)/sqrt(nStimTrials)];
                
                k=10;% up light bar
                start=stimTimeStamps(k)+1;
                finish=stimTimeStamps(k+1)-1;
                upLight=respTimeTraces(start:finish,tt,:);
                upLight=reshape(upLight,size(upLight,1),nStimTrials);
                auxPos42=posTimeStamps{k};
                pos42=linspace(stimLocPos(auxPos42(1,1)),stimLocPos(auxPos42(1,2)-1),size(upLight,1));
                pos42=abs(pos42);
                shadedErrorBar(gca,pos42,mean(upLight,2),...
                    std(upLight,[],2)/sqrt(nStimTrials),{'Color',[0.8500 0.3250 0.0980]},1)
                axis tight
                extras(gca)
                upLightAllRois=[upLightAllRois mean(upLight,2)];
                upLightAllRoisSEM=[upLightAllRoisSEM std(upLight,[],2)/sqrt(nStimTrials)];
            end
            print(gcf, '-dpng', '-opengl', sprintf('-r%d',600),[filename ' up&down light bar ' txt]);
            close
            
            figure('Color','w','Position',[1 1 683 697],'Name',[filename ' light bar ' txt])
            t=annotation('textbox');
            set(t,'String',[filename ' light bar ' txt])
            set(t,'Position',[0.25 0.9 0.1 0.1])
            set(t,'EdgeColor','none')
            set(t,'FontSize',20)
            set(t,'Interpreter','none')
            
            pa=panel;
            pa.pack(2,2);
            pa.margin=20;
            pa(1,1).select();
            imagesc(pos11,1:size(rightLightAllRois,2),rightLightAllRois')
            axis tight
            extras(gca)
            title('right','FontSize',FontSize)
            set(gca,'XColor','none','FontSize',FontSize)
            ylabel('ROI #','FontSize',FontSize)
            
            pa(2,1).select();
            imagesc(pos21,1:size(leftLightAllRois,2),leftLightAllRois')
            axis tight
            extras(gca)
            title('left','FontSize',FontSize)
            xlabel('position (deg)','FontSize',FontSize)
            ylabel('ROI #','FontSize',FontSize)
            set(gca,'FontSize',FontSize)
            
            pa(1,2).select();
            imagesc(pos31,1:size(upLightAllRois,2),flip(upLightAllRois'))
            axis tight
            extras(gca)
            title('down','FontSize',FontSize)
            set(gca,'XColor','none','FontSize',FontSize)
            set(gca,'YColor','none','FontSize',FontSize)
            
            pa(2,2).select();
            imagesc(pos41,1:size(downLightAllRois,2),fliplr(downLightAllRois'))
            axis tight
            extras(gca)
            title('up','FontSize',FontSize)
            xlabel('position (deg)','FontSize',FontSize)
            set(gca,'YColor','none','FontSize',FontSize)
            print(gcf, '-dpng', '-opengl', sprintf('-r%d',600),[filename ' light bar ' txt]);
            close
        end
    end
end





