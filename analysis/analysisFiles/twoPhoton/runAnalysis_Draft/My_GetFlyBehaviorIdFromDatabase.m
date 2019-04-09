function fileID  = My_GetFlyBehaviorIdFromDatabase(filepath)

try
    fileID = GetFlyBehaviorIdFromDatabase({filepath});
catch
    filepath_parts = strsplit(filepath, '/'); filepath_parts(end) = [];
    filepath_for_flyID = strjoin(filepath_parts,'/');
    fileID = GetFlyBehaviorIdFromDatabase({filepath_for_flyID});
end
end