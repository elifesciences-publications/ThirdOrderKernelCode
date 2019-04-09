clear
clc
filepathAllNonRep = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_60hz', 'GC6f', '','','date', '>', '2015-06-01');
filepathAllRep = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','<','2016-06-18');
filepathAllRepNewest = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date','>=','2016-06-18','date','<','2016-06-19'); % 
filepathAll = [filepathAllRep;filepathAllNonRep;filepathAllRepNewest];

% copyfile('source', 'destination');
store_path = 'E:\twop_data\';

for ff = 2:1:length(filepathAll)
folder_this = filepathAll{ff};
% get the relative_path 
folder_this_relative = folder_this(11:end);
copyfile(folder_this, [store_path, folder_this_relative]);
end
% 

