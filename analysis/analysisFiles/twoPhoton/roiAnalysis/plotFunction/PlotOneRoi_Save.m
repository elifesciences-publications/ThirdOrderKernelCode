function PlotOneRoi_Save(plotH,MainName,SubName)
%     fileName = [MainName,'_',filename,'_',datestr(now,'_dd_mm_yy')];
%     % there is a small function to find what is the proper name for
%     % this figure;
%     
%     d = dir; % open current foler... 
%     if ~isempty(d)
%         nfile = length(d);
%     end
%     remove = [];
%     for i = 1:1:nfile
%         if strcmp(d(i).name,'.') || strcmp(d(i).name,'..')
%             remove = [remove,i];
%         end
%     end
%     d(remove) = [];
%     nfile =length(d);
%     
%     count = 0;
%     for i = 1:1:nfile
%         if ~isempty(strfind(d(i).name, fileName)) && ~isempty(strfind(d(i).name, SubName));
%             count = count + 1;
%         end
%     end
%     fileNameNew = [fileName,'_',num2str(count + 1),'_',SubName, '.jpg'];
%     
%     fileName = [MainName,'_',SubName,'_',datestr(now,'_dd_mm_yy'),'.jpg',];
    fileName = [MainName,'_',SubName,'_',datestr(now,'_dd_mm_yy')];
    % check how many pictures are named this way in current folder.
%     plotH.PaperPosistion = [0,0,1000,1000];
%     saveas(plotH,fileName);
    hgexport(plotH, fileName, hgexport('factorystyle'), 'Format', 'jpeg');
%     prinf()
end
