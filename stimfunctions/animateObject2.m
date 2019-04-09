function [mX, mY]=animateObject2(object,frameRate,color,initPosCircle)


try
    
    AssertOpenGL;
    Screen('preference', 'verbosity', 1);
    Screen('preference', 'skipsynctests',1);
    Screen('preference', 'visualdebuglevel', 1);% 1-4
    
    KbName('unifykeynames');
    
    screennumber = max(Screen('screens'));
    w1 = Screen('openwindow',screennumber);
    
    windows=w1;
    
    w1=windows(1);
    
    
    white=WhiteIndex(w1);
    black=BlackIndex(w1);
    gray=ceil((white+black)/2);
    res=Screen('Resolution',w1);
    ifi = Screen('GetFlipInterval', w1, 100, 0.00005, 20);
    escapeKey = KbName('ESCAPE');
    returnKey = KbName('RETURN');
    
    if color
        coloris=white;
    else
        coloris=black;
    end
    height=res.height;
    width=res.width;
    switch object
        
        case 1 % rectangle
            defaultWidth=100;
            widthBar=defaultWidth;
            thicker= KbName('upArrow');
            thinner=KbName('downArrow');
            horizontal=KbName('h');
            vertical=KbName('v');
            
            type=1;
            a=0;
            b=0;
            c=0;
            d=0;
            i=0;
            
            vbl = Screen('Flip', w1);
            pause(2)
            while 1
                
                [keyIsDown,~,keyCode] = KbCheck;
                if keyIsDown
                    if keyCode(escapeKey)
                        break;
                    end
                end
                
                [mX, mY, buttons] = GetMouse(w1);
                
                
                
                if sum(buttons)
                    if type
                        a=mX-widthBar/2;
                        b=0;
                        c=mX+widthBar/2;
                        d=height;
                    else
                        a=0;
                        b=mY-widthBar/2;
                        c=width;
                        d=mY+widthBar/2;
                    end
                    pos=[a b c d];
                end
                
                if keyIsDown
                    b1=find(keyCode);
                    if length(b1)==1
                        switch b1
                            case returnKey
                                display(['**** RFx=' num2str(mX) '   RFy=' num2str(mY) ' ****']);
                                
                            case thicker
                                widthBar=widthBar+10;
                                if type
                                    a=mX-widthBar/2;
                                    b=0;
                                    c=mX+widthBar/2;
                                    d=height;
                                else
                                    a=0;
                                    b=mY-widthBar/2;
                                    c=width;
                                    d=mY+widthBar/2;
                                end
                                
                            case thinner
                                widthBar=widthBar-10;
                                if type
                                    a=mX-widthBar/2;
                                    b=0;
                                    c=mX+widthBar/2;
                                    d=height;
                                else
                                    a=0;
                                    b=mY-widthBar/2;
                                    c=width;
                                    d=mY+widthBar/2;
                                end
                                
                            case horizontal
                                type=0;
                                a=0;
                                b=mY-widthBar/2;
                                c=width;
                                d=mY+widthBar/2;
                                
                            case vertical
                                type=1;
                                a=mX-widthBar/2;
                                b=0;
                                c=mX+widthBar/2;
                                d=height;
                        end
                    end
                end
                
                if mX<-widthBar
                    mX=0;
                elseif mX>width+widthBar
                    mX=width;
                elseif mY<-widthBar
                    mY=0;
                elseif mY>height+widthBar
                    mY=height;
                end
                
                switch type
                    case 1
                        if a<-(widthBar+10)
                            a=-(widthBar+10);
                            c=a+widthBar;
                        elseif c>width+widthBar-10
                            c=width+widthBar-10;
                            a=c-widthBar;
                        end
                    case 0
                        if b<-(widthBar+10)
                            b=-(widthBar+10);
                            d=b+widthBar;
                        elseif d>height+widthBar-10
                            d=height+widthBar-10;
                            c=d-widthBar;
                        end
                end
                
                
                pos=[a, b, c, d];
                
                Screen('FillRect', w1, coloris, pos);
                
                if ~mod(i,30)
                    Screen('FillRect',w1,white,[width-100 height-100 width height])
                else
                    Screen('FillRect',w1,gray,[width-100 height-100 width height])
                end
                
                
                vbl = Screen('Flip', w1,vbl+0.5*ifi,[],[],1);
                
                i=i+1;
            end
            %end
            
        case 0 % circle
            
            white=WhiteIndex(w1);
            black=BlackIndex(w1);
            
            periodDurationInSecs=1/frameRate;% for a periodic stimulus,period is:
            halfPeriodInFrames=round(periodDurationInSecs/2/ifi);
            
            KbName('UnifyKeyNames');
            escapeKey = KbName('ESCAPE');
            
            bigger= KbName('upArrow');
            smaller=KbName('downArrow');
            
            up=30;
            down=30;
            left=30;
            right=30;
            coloris=white;
            
            aux=0;
            i=0;
            
            
            xi=initPosCircle(1);
            yi=initPosCircle(2);
            pos=[xi-left, yi-up, xi+right,yi+down];
            
            
            Screen('FillOval', w1, coloris, pos);
            vbl = Screen('Flip', w1);
            
            
            Screen('TextFont',w1, 'Helvetica');
            Screen('TextSize',w1, 20);
            Screen('TextStyle',w1,1)
            
            
            
            while 1
                
                [keyIsDown,~,keyCode] = KbCheck;
                if keyIsDown
                    if keyCode(escapeKey)
                        break;
                    end
                end
                
                if ~mod(i,halfPeriodInFrames)
                    if ~mod(aux,2)
                        coloris=white;
                    else
                        coloris=black;
                    end
                    aux=aux+1;
                end
                
                if ~mod(i,halfPeriodInFrames)
                    Screen('FillRect',w1,white,[width-100 height-100 width height])
                else
                    Screen('FillRect',w1,gray,[width-100 height-100 width height])
                end
                
                
                
                i=i+1;
                
                
                [mX, mY, buttons] = GetMouse(w1, 0);
                
                if sum(buttons)
                    pos=[mX-left, mY-up, mX+right,mY+down];
                end
                Screen('FillOval', w1, coloris, pos);
                vbl = Screen('Flip', w1,vbl+0.5*ifi,[],[],1);
                Screen('DrawText', w1, ['x=' num2str(mX) '   y=' num2str(mY)], 0, 0);
                
                if keyIsDown
                    b=find(keyCode);
                    if length(b)==1
                        switch b
                            case returnKey
                                display(['**** RFx=' num2str(mX) '   RFy=' num2str(mY) ' ****']);
                                display(['radius=' num2str(up)]);
                            case bigger
                                up=up+5;
                                down=down+5;
                                right=right+5;
                                left=left+5;
                            case smaller
                                up=up-5;
                                down=down-5;
                                right=right-5;
                                left=left-5;
                                if up<=0
                                    up=0;
                                elseif down<=0
                                    down=0;
                                elseif right<=0
                                    right=0;
                                elseif left<=0
                                    left=0;
                                end
                        end
                    end
                    pos=[mX-left, mY-up, mX+right,mY+down];
                    Screen('FillOval', w1, coloris, pos);
                    %Screen('DrawText', w1, ['x=' num2str(mX) '   y=' num2str(mY)], 960 ,540);
                    %Screen('DrawText', w1, 'Top-Left aligned, max 40 chars wide: Hit any key to continue.', 0, 0, [255, 0, 0, 255]);
                    
                    vbl = Screen('Flip', w1,vbl+0.5*ifi,[],[],1);
                    
                end
            end
            
            
        case 2 % looming
            
            cmperpix=0.026516; % cm/pix
            degperpix=2*atan((cmperpix*57.2957795)/(2*25));
            nFramesGrowth=round(0.25/ifi);
            allDiaDeg=linspace(2,20,nFramesGrowth);
            allDiaPix=allDiaDeg/degperpix;
            allRadPix=allDiaPix/2;
            
            
            
            res=Screen('Resolution',w1);
            width=res.width;
            height=res.height;
            
            xc=width/2;
            yc=height/2;
            vbl = Screen('Flip', w1);
            
            i=0;
            while 1
                
                [keyIsDown,~,keyCode] = KbCheck;
                if keyIsDown
                    if keyCode(escapeKey)
                        break;
                    end
                end
                
                for currRadIdx=1:length(allRadPix)
                    currRad=allRadPix(currRadIdx);
                    
                    [mx, my, buttons] = GetMouse(w1, 0);
                    
                    if sum(buttons)
                        xc=mx;
                        yc=my;
                    end
                    pos(1)=xc-currRad;
                    pos(2)=yc-currRad;
                    pos(3)=xc+currRad;
                    pos(4)=yc+currRad;
                    
                    
                    Screen('FillOval', w1, coloris, pos);
                    if mod(currRadIdx,2)
                        Screen('FillRect',w1,white,[width-100 height-100 width height])
                    else
                        Screen('FillRect',w1,gray,[width-100 height-100 width height])
                    end
                    
                    vbl = Screen('Flip', w1,vbl+0.5*ifi,[],[],1);
                end
                
                Screen('FillOval', w1, coloris, pos);
                Screen('FillRect',w1,gray,[width-100 height-100 width height])
                vbl = Screen('Flip', w1,vbl+0.5*ifi,[],[],1);
                WaitSecs(ifi*14);
                
                
                Screen('FillRect',w1,white,[width-100 height-100 width height])
                vbl = Screen('Flip', w1,vbl+0.5*ifi);
                
                Screen('FillRect',w1,gray,[width-100 height-100 width height])
                vbl = Screen('Flip', w1,vbl+0.5*ifi);
                WaitSecs(ifi*13);% wait 10 more frames, for a total of 12 frames (0.2 secs)
                
                
                
                if keyIsDown
                    b=find(keyCode);
                    if length(b)==1
                        switch b
                            case returnKey
                                display(['**** RFx=' num2str(mx) '   RFy=' num2str(my) '****']);
                        end
                    end
                end
                
            end
    end
    
    %Screen('CloseAll');
    Screen('Preference', 'Verbosity', 3);
    Screen('Preference', 'SkipSyncTests',0);
    Screen('Preference', 'VisualDebugLevel', 4);% 1-4
    
catch %#ok<CTCH>
    
    Screen('Preference', 'Verbosity', 3);
    Screen('Preference', 'SkipSyncTests',0);
    Screen('Preference', 'VisualDebugLevel', 4);% 1-4
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end

