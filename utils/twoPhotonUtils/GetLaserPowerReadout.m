function powerWatts = GetLaserPowerReadout()
% Query the power meter for the laser power in watts. Note that this is not
% the laser power at the sample becuase the power meter only receives
% ~1/100th of the light that goes through the optical bench. Laser
% alignment will also affect laser power at the sample.

% Power meter communicates using the VISA protocol. See manual for possible
% commands
ni = instrhwinfo('visa','ni');
% Power meter model code is 0x8078. Find which constructor to use for this
% model (it'll have the model code in the name)
constructorNumber = find(~cellfun(@isempty,strfind(ni.ObjectConstructorName,'0x8078')),1);
if isempty(constructorNumber)
%     powerWatts = 0;
%     return;
    warning('getLaserPowerReadout:noMeter','Error: No power meter found');
    powerWatts = [];
    return;
end
vu = eval([ni.ObjectConstructorName{constructorNumber}]);
try
    fopen(vu);
    powerWatts = query(vu,':MEAS:POW?');
    fclose(vu);
    delete(vu);
catch err
    warning(err.message)
    powerWatts = [];
end