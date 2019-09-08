function FindFlickKernelPath_WriteLog(fullLogName,path)
% because it is writing, so you would definitely over write that.
 if exist(fullLogName,'file')
   warning(['over writing the log : ',fullLogName]);
 end
 
% open and write.
fileID = fopen(fullLogName,'w');
% how are you going to write depends on how are you going to read.
% just write them line by line, according to your sequence. you would
% always write and read in sequence.
fprintf(fileID,'%s\n',path.flickpath);
fprintf(fileID,'%s\n',path.firstkernelpath);
fprintf(fileID,'%s\n',path.firstnoisepath);
fprintf(fileID,'%s\n',path.secondkernelpathNearest);
fprintf(fileID,'%s\n',path.secondnoisepath);
fprintf(fileID,'%s\n',path.secondkernelpathNextNearest);
% fprintf(fileID,'%s\n',path.firstOLSMatpath);
% fprintf(fileID,'%s\n',path.firstkernelpathNew);
% fprintf(fileID,'%s\n',path.secondOLSMatpath);
% fprintf(fileID,'%s\n',path.secondkernelpathNew);
fclose(fileID);

end