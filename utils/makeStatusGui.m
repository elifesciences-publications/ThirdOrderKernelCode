function statusHandles = makeStatusGui()
    originalLnF = javax.swing.UIManager.getLookAndFeel;  %class
    newLnF = 'javax.swing.plaf.nimbus.NimbusLookAndFeel';  %string
    javax.swing.UIManager.setLookAndFeel(newLnF);
    figureWidth = 550;
    figureHeight = 275;
    statusGui = figure('Visible','off','Position',[0,0,figureWidth,figureHeight]);
    statusGui.ToolBar = 'none';
    statusGui.MenuBar = 'none';
    statusGui.Units = 'normalized';
    statusGui.Name = 'Run Status';
    statusGui.NumberTitle = 'off';
    movegui(statusGui,'center');
    statusGui.Visible = 'on';
    
    fontHeight = 15;
    lineOffset = 1.6*fontHeight;
    flyYString = sprintf('%-3s %-7d %-7d %-7d %-7d %-7d','Y:',0,0,0,0,0);
    flyYText = uicontrol('Style','text','String',flyYString,...
        'Position',[figureWidth/50,lineOffset + figureHeight/50,figureWidth,lineOffset],...
        'FontName','FixedWidth','FontSize',fontHeight,'FontWeight','bold');
    flyYText.Units = 'normalized';
    
    flyXString = sprintf('%-3s %-7d %-7d %-7d %-7d %-7d','X:',0,0,0,0,0);
    flyXText = uicontrol('Style','text','String',flyXString,...
        'Position',[figureWidth/50,2*lineOffset + figureHeight/50,figureWidth,lineOffset],...
        'FontName','FixedWidth','FontSize',fontHeight,'FontWeight','bold');
    flyXText.Units = 'normalized';
    
    flyLabelString = sprintf('%-3s %-7s %-7s %-7s %-7s %-7s','','Fly 1','Fly 2','Fly 3','Fly 4','Fly 5');
    flyLabelText = uicontrol('Style','text','String',flyLabelString,...
        'Position',[figureWidth/50,3*lineOffset + figureHeight/50,figureWidth,lineOffset],...
        'FontName','FixedWidth','FontSize',fontHeight,'FontWeight','bold');
    flyLabelText.Units = 'normalized';
    
    
    currentEpochText = uicontrol('Style','text','String','Current Epoch: ',...
        'Position',[2*figureWidth/50,5*lineOffset + figureHeight/50,figureWidth,lineOffset],...
        'FontSize',fontHeight,'HorizontalAlignment','Left','ForegroundColor',[30/255,30/255,30/255]);
    currentEpochText.Units = 'normalized';
    
    jProgressBarThisStim = javaObjectEDT('javax.swing.JProgressBar');
    jProgressBarThisStim.setStringPainted(true);
    uiColor = get(statusGui,'Color');
    uiColorObject = javax.swing.plaf.ColorUIResource(uiColor(1)/255,uiColor(2)/255,uiColor(2)/255);
    jProgressBarThisStim.setBackground(uiColorObject);
    jProgressBarThisStim.setMinimum(0);
    jProgressBarThisStim.setMaximum(1000);
    jProgressBarThisStim.setValue(0);
    jProgressBarThisStim.setString('');
    [hProgressBarThisStim,cProgressBarThisStim] = javacomponent(jProgressBarThisStim,...
                                                  [figureWidth/10, 7*lineOffset + figureHeight/50, 8*figureWidth/10, figureHeight/10],statusGui);
    set(cProgressBarThisStim,'units','normalized','Tag','ProgressBar');
    
    jProgressBarMultStim = javaObjectEDT('javax.swing.JProgressBar');
    jProgressBarMultStim.setStringPainted(true);
    uiColor = get(statusGui,'Color');
    uiColorObject = javax.swing.plaf.ColorUIResource(uiColor(1)/255,uiColor(2)/255,uiColor(2)/255);
    jProgressBarMultStim.setBackground(uiColorObject);
    jProgressBarMultStim.setMinimum(0);
    jProgressBarMultStim.setMaximum(0);
    jProgressBarMultStim.setValue(0);
    jProgressBarMultStim.setString('');
    [hProgressBarMultStim,cProgressBarMultStim] = javacomponent(jProgressBarMultStim,...
                                                 [figureWidth/10, 9*lineOffset + figureHeight/50, 8*figureWidth/10, figureHeight/10],statusGui);
    set(cProgressBarMultStim,'units','normalized','Tag','ProgressBar');
    
    statusHandles.progressBar = hProgressBarThisStim;
    statusHandles.progressBarMulti = jProgressBarMultStim;
    statusHandles.currentEpochText = currentEpochText;
    statusHandles.flyXText = flyXText;
    statusHandles.flyYText = flyYText;
    statusHandles.statusGui = statusGui;
    drawnow;
    % Restore the original L&F
    javax.swing.UIManager.setLookAndFeel(originalLnF);
end