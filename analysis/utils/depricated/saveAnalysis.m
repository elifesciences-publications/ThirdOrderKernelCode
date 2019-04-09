function saveAnalysis(D)
    %make the folder
    D.paths.analysisFolder = ['d:/documents/analysis/' D.handles.analysisFilename(1:end-2) datestr(now,'/yyyy/mm_dd/HH_MM_SS')];
    mkdir(D.paths.analysisFolder);
    
    %save folder paths
    save([D.paths.analysisFolder '/Paths.mat'],'-struct','D','paths');
    
    %save the figures generated
    for ii = 1:length(D.figures)
        if ~exist([D.paths.analysisFolder '/figures/' D.figures{ii}.folder],'file')
            mkdir([D.paths.analysisFolder '/figures/' D.figures{ii}.folder]);
        end
        saveas(D.figures{ii}.handle,[D.paths.analysisFolder '/figures/' D.figures{ii}.folder '/' D.figures{ii}.title],'fig');
        
        %close figures after saving if they are invisible
        if strcmp(get(D.figures{ii}.handle,'visible'),'off')
            close(D.figures{ii}.handle);
        end
    end
    
    %save meta figures generated
    if D.runMeta
        for ii = 1:length(D.meta.figures)
            if ~exist([D.paths.analysisFolder '/figures/' D.meta.figures{ii}.folder],'file')
                mkdir([D.paths.analysisFolder '/figures/' D.meta.figures{ii}.folder]);
            end
            saveas(D.meta.figures{ii}.handle,[D.paths.analysisFolder '/figures/' D.meta.figures{ii}.folder '/' D.meta.figures{ii}.title],'fig');

            %close figures after saving if they are invisible
            if strcmp(get(D.meta.figures{ii}.handle,'visible'),'off')
                close(D.meta.figures{ii}.handle);
            end
        end
    end
    
    %save the analysis file used
    copyfile([D.paths.analysisFile D.handles.analysisFilename '.m'],D.paths.analysisFolder);
    
    %copy and zip the utils folder that was used
    zip([D.paths.analysisFolder '/utils'],'d:/documents/matlab/psycho5/analysis/utils/');
    
    zip([D.paths.analysisFolder '/figures.zip'],[D.paths.analysisFolder '/figures/']);
    rmdir([D.paths.analysisFolder '/figures/'],'s');
end