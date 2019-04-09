function each_type = SAC_Temp_CellType(data_info, which_type_str)
% what if you care about a particular type.
% type_str = {'OnECI', 'OnV','OffECI', 'OffV'};

sac_type = [data_info(:).type];
sac_iv = {data_info(:).IV};
% n_iv_type = 2;
% n_cell_type = 2;
% n_type = n_iv_type * n_cell_type;
% each_type = cell(n_type, 1);
switch which_type_str
    case 'OnECI'
        each_type = (sac_type == 1 & cellfun(@(x) strcmp(x,'ECI'), sac_iv));
    case 'OnV'
        each_type = sac_type == 1 & cellfun(@(x) strcmp(x,'V'), sac_iv);
    case 'OffECI'
        each_type = sac_type == 2 & cellfun(@(x) strcmp(x,'ECI'), sac_iv);  
    case 'OffV'
        each_type = sac_type == 2 & cellfun(@(x) strcmp(x,'V'), sac_iv);
end