function [dirTypeColorRGB,edgeTypeColorRGB,DarkLightColor] = FigPlot1ColorCode()
%% there will be four colors for each different types
% you might have to come up with a better metric to do this...
dirTypeColorRGB = zeros(4,3);
% there will be four colors for four different layers.
% up/down/progressive/regressive.
dirTypeColorRGB(1,:) = [1,0,0]; % red, progressive
dirTypeColorRGB(2,:) = [0.5,0,0.9]; % purple,regressive
dirTypeColorRGB(3,:) = [0,0.8,0.8]; % turquoise Up.
dirTypeColorRGB(4,:) = [1,1,0]; % yellow. Down

DarkLightColor = zeros(2,3);
DarkLightColor(1,:) = [1,0,0]; % red;
DarkLightColor(2,:) = [0,0,1]; % blue;

edgeTypeColorRGB = zeros(4,3);
edgeTypeColorRGB(1,:) = [1,0,0]; % red(light), left/progressive
edgeTypeColorRGB(2,:) = [1,0,1]; % megenda(light), right/regressive
edgeTypeColorRGB(3,:) = [0,0,1]; % blue(dark), left/progressive
edgeTypeColorRGB(4,:) = [0,1,0]; % green(dark), right/regressive;

end