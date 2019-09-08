function MySaveFig_Juyue(plotH,MainName,SubName,varargin)
% MySaveFig_Juyue(plotH,MainName,SubName,'nFigSave',2,'fileType',{'png','fig'});
% MySaveFig_Juyue(plotH,MainName,SubName,'nFigSave',1,'fileType',{'eps'});

nFigSave = 1;
fileType = {'jpeg'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

fileName = [MainName,'_',SubName,'_',datestr(now,'_dd_mm_yy')];
if nFigSave == 1 && strcmp(fileType{1},'jpeg')
    hgexport(plotH, fileName, hgexport('factorystyle'), 'Format', fileType{1});
else
    for ii = 1:1:nFigSave
        if strcmp(fileType{ii},'fig')
            savefig(plotH,fileName);
        elseif strcmp(fileType{ii},'eps')
            plotH.WindowStyle = 'normal';
            options.color = 'CMYK';
            export_fig(plotH,fileName,'-eps','-transparent','-painters','-nocrop',options)
        elseif strcmp(fileType{ii},'pdf')

            pos = get(gcf,'Position');
            set(gcf, 'InvertHardcopy','off','Units','Points','PaperPositionMode','Auto','PaperUnits','Points','PaperSize',[pos(3), pos(4)]);
            print(gcf,fileName,'-dpdf','-r0')

%             print('-bestfit');
%             export_fig(plotH,fileName,'-eps','-transparent','-painters','-nocrop');
        elseif strcmp(fileType{ii},'svg')
            plot2svg([fileName, '.svg'], plotH,'png');
        else
            hgexport(plotH, fileName, hgexport('factorystyle'), 'Format', fileType{ii});
        end
    end
end