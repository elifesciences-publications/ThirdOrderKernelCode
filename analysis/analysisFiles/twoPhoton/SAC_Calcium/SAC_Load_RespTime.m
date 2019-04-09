function resptime = SAC_Load_RespTime()
    resptiming_file = 'D:\data_sac_calcium\param_info\resptime.mat';
    data = load(resptiming_file);
    resptime = data.resptime;
end