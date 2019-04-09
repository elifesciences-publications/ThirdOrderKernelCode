function [powerMapInt,xIntMesh,yIntMesh] = InterpolatePowerMap(bootedPowerMaps,xMesh,yMesh,numXPoints,numYPoints)
    % interpolate the data and sample it evenly on a log-linear scale.
    % Currently the data is sampled approximately on a sqrt(2)^n scale but
    % not exactly
    
    % set up the DESIRED x and y coordinates for the power map. These
    % are the coordinates that will be used after linear interpolation
    numBoot = size(bootedPowerMaps,3);
    powerMapInt = zeros(numYPoints,numXPoints,numBoot);
    
    for bb = 1:numBoot
        powerMap = bootedPowerMaps(:,:,bb);
        % exponentially interpolate between min and max x and y
        xInt = linspace(min(min(xMesh)),max(max(xMesh)),numXPoints); % upsampled SF for interpolation
        yInt = linspace(min(min(yMesh)),max(max(yMesh)),numYPoints)'; % upsampled TF for interpolation

        % mesh grid of x and y
        [xIntMesh,yIntMesh] = meshgrid(xInt,yInt);

        % linearly interpolate the data
        powerMapTfInt = scatteredInterpolant(xMesh(:),yMesh(:),powerMap(:),'linear','none');

        % evaluate the interpolated data at the desired points
        powerMapInt(:,:,bb) = powerMapTfInt(xIntMesh,yIntMesh);
    end
end