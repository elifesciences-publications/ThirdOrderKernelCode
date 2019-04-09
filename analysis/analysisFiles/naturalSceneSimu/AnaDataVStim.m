function res = AnaDataVStim(param)

D = MyLoadIndV(param);
% sort D !
D = MySortD(D);
nv = length(D);
res = cell(nv,1);
% the data is stored in the 

for vv = 1:1:nv
    v = D{vv}.v;
    stimc = D{vv}.stimc;
    imageID = D{vv}.imageID;
    
    res{vv}.v = v.real;
    res{vv}.stimc = stimc;
    res{vv}.imageID = imageID;
end
end