function [dx, dt] = K3_Glider_Trans_Utils_Name_To_TauDx(name)
% catTitles = {'Diverging DT 1','Converging DT 1','Two Point DT 1','Elbow','Late Knight',...
%     'Early Knight','Diverging DT 2','Converging DT 2','Elbow Late Break','Elbow Early Break',...
%     'Diverging DT 3','Diverging DT 4','Convering DT 3','Converging DT 4','Two Point DT 2', ...
%     'Two Point DT 3','Two Point DT 4'};

dt = [0,0];
dx = [0,0];
% first is tau2 - tau1
% second is tau3 - tau1
% limited to third order kernel for now.
switch name
    case 'Diverging DT 1'
        dx = [0, 1];
        dt = [1, 0];
    case 'Diverging DT 2'
        dx = [0, 1];
        dt = [2, 0];
    case 'Diverging DT 3'
        dx = [0, 1];
        dt = [3, 0];
    case 'Diverging DT 4'
        dx = [0, 1];
        dt = [4, 0];
        
    case 'Converging DT 1'
        dx = [0, -1];
        dt = [1, 1];
    case 'Converging DT 2'
        dx = [0, -1];
        dt = [2, 2];
    case 'Converging DT 3'
        dx = [0, -1];
        dt = [3, 3];
    case 'Converging DT 4'
        dx = [0, -1];
        dt = [4, 4];
        
    case 'Elbow'
        dx = [0, -1];
        dt = [2, 1];
    case 'Late Knight' % changed
        dx = [0, 1];
        dt = [1,-1];
    case 'Early Knight'
        dx = [0, -1];
        dt = [1, 2];
    case 'Elbow Late Break'
        dx = [0, -1];
        dt = [3, 2];
    case 'Elbow Early Break'
        dx = [0, -1];
        dt = [3,1];
    case 'Two Point DT 1'
        dx = -1;
        dt = 1;
    case 'Two Point DT 2'
        dx = -1;
        dt = 2;
    case 'Two Point DT 3'
        dx = -1;
        dt = 3;
    case 'Two Point DT 4'
        dx = -1;
        dt = 4;
    case 'Two Point DT 5'
        dx = -1;
        dt = 5;
        
end