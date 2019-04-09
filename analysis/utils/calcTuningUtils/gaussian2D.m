function z = gaussian2D(par,xy,angle)
    if nargin < 3
        angle = [];
    end
    
    % par is [amplitude xStd yStd xOffset yOffset zOffset angle]
    if isempty(angle)
        % compute 2D gaussian
        z = par(6) + ...
        par(1)*exp(-(((xy{1}-par(4)).*cosd(par(7))+(xy{2}-par(5)).*sind(par(7)))./par(2)).^2-...
        ((-(xy{1}-par(4)).*sind(par(7))+(xy{2}-par(5)).*cosd(par(7)))./par(3)).^2);
    else
        z = par(6) + ...
        par(1)*exp(-(((xy{1}-par(4)).*cosd(angle)+(xy{2}-par(5)).*sind(angle))./par(2)).^2-...
        ((-(xy{1}-par(4)).*sind(angle)+(xy{2}-par(5)).*cosd(angle))./par(3)).^2);
    end
end