function [ESI, DSI] = MyHHCA_Untils_ESIDSI_Calculation(edgeTrace)
% every edge has 156.
t_oneedge = 156; % hard coding. very dangerous. 
trace = zeros(t_oneedge,4);
% first, split the trace into
nEdge = 4; % only
for ii = 1:1:nEdge
    trace(:,ii) = edgeTrace((ii - 1) * t_oneedge + 1: ii * t_oneedge);
end
% edgeTypesStrEye = {'Progressive Light','Regressive Light','Progressive Dark','Regressive Dark','Progressive','Regressive','Up','Down'};

% get value for 4 edges and then compute the dsi and esi
value = zeros(nEdge,1);
for ee = 1:1:nEdge
    value(ee) =  percentileThresh(trace(:,ee),0.99) -  percentileThresh(trace(:,ee),0.50);
end

edgeProLeft = max(value([1,3]));
edgeRegRight = max(value([2,4]));
lightValue = max(value(1:2));
darkValue = max(value(3:4));


DSI = (edgeProLeft - edgeRegRight)/(edgeProLeft + edgeRegRight);
ESI = (lightValue - darkValue)/(lightValue + darkValue);
end